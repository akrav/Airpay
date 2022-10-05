module 0x1::Vault {
    use std::signer;
    use std::option;
    use std::string;

    use aptos_framework::coin;
    use aptos_framework::timestamp;


    const MODULE_ADMIN: address = @hypermatter;
    const MINIMUM_LIQUIDITY: u128 = 1000;
    const BALANCE_MAX: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // 2**112

    // List of errors
    const ERROR_ONLY_ADMIN: u64 = 0;
    const ERROR_ALREADY_INITIALIZED: u64 = 1;
    const ERROR_NOT_CREATOR: u64 = 2;
    const ERROR_ALREADY_LOCKED: u64 = 3;
    const ERROR_INSUFFICIENT_LIQUIDITY_MINTED: u64 = 4;
    const ERROR_OVERFLOW: u64 = 5;
    const ERROR_INSUFFICIENT_AMOUNT: u64 = 6;
    const ERROR_INSUFFICIENT_LIQUIDITY: u64 = 7;
    const ERROR_INVALID_AMOUNT: u64 = 8;
    const ERROR_TOKENS_NOT_SORTED: u64 = 9;
    const ERROR_INSUFFICIENT_LIQUIDITY_BURNED: u64 = 10;
    const ERROR_INSUFFICIENT_TOKEN0_AMOUNT: u64 = 11;
    const ERROR_INSUFFICIENT_TOKEN1_AMOUNT: u64 = 12;
    const ERROR_INSUFFICIENT_OUTPUT_AMOUNT: u64 = 13;
    const ERROR_INSUFFICIENT_INPUT_AMOUNT: u64 = 14;
    const ERROR_K: u64 = 15;
    const ERROR_X_NOT_REGISTERED: u64 = 16;
    const ERROR_Y_NOT_REGISTERED: u64 = 16;

    /// The LP Token type
    struct LPToken<phantom X, phantom Y> has key {}

    #[method(quote_x_to_y_after_fees, quote_y_to_x_after_fees)]
    /// Stores the metadata required for the token pairs
    struct TokenPairMetadata<phantom X, phantom Y> has key {
        /// Lock for mint and burn
        locked: bool,
        /// The admin of the token pair
        creator: address,
        /// The address to transfer mint fees to
        fee_to: address,
        /// Whether we are charging a fee for mint/burn
        fee_on: bool,
        /// It's reserve_x * reserve_y, as of immediately after the most recent liquidity event
        k_last: u128,
        /// The LP token
        lp: coin::Coin<LPToken<X, Y>>,
        /// T0 token balance
        balance_x: coin::Coin<X>,
        /// T1 token balance
        balance_y: coin::Coin<Y>,
        /// Mint capacity of LP Token
        mint_cap: coin::MintCapability<LPToken<X, Y>>,
        /// Burn capacity of LP Token
        burn_cap: coin::BurnCapability<LPToken<X, Y>>,
        /// Freeze capacity of LP Token
        freeze_cap: coin::FreezeCapability<LPToken<X, Y>>,
    }

    /// Stores the reservation info required for the token pairs
    struct TokenPairReserve<phantom X, phantom Y> has key {
        reserve_x: u64,
        reserve_y: u64,
        block_timestamp_last: u64
    }

    // ================= Init functions ========================
    /// Create the specified token pair
    public fun create_token_pair<X, Y>(
        admin: &signer,
        fee_to: address,
        fee_on: bool,
        lp_name: vector<u8>,
        lp_symbol: vector<u8>,
        decimals: u8,
    ) {
        let sender_addr = signer::address_of(admin);
        assert!(sender_addr == MODULE_ADMIN, ERROR_NOT_CREATOR);

        assert!(!exists<TokenPairReserve<X, Y>>(sender_addr), ERROR_ALREADY_INITIALIZED);
        assert!(!exists<TokenPairReserve<Y, X>>(sender_addr), ERROR_ALREADY_INITIALIZED);

        // now we init the LP token
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<LPToken<X, Y>>(
            admin,
            string::utf8(lp_name),
            string::utf8(lp_symbol),
            decimals,
            true
        );

        move_to<TokenPairReserve<X, Y>>(
            admin,
            TokenPairReserve {
                reserve_x: 0,
                reserve_y: 0,
                block_timestamp_last: 0
            }
        );

        move_to<TokenPairMetadata<X, Y>>(
            admin,
            TokenPairMetadata {
                locked: false,
                creator: sender_addr,
                fee_to,
                fee_on,
                k_last: 0,
                lp: coin::zero<LPToken<X, Y>>(),
                balance_x: coin::zero<X>(),
                balance_y: coin::zero<Y>(),
                mint_cap,
                burn_cap,
                freeze_cap,
            }
        );

        // create LP CoinStore for admin, which is needed as a lock for minimum_liquidity
        coin::register<LPToken<X,Y>>(admin);
    }

    /// The init process for a sender. One must call this function first
    /// before interacting with the mint/burn.
    public fun register_account<X, Y>(sender: &signer) {
        coin::register<LPToken<X, Y>>(sender);
    }

    // ====================== Getters ===========================
    /// Get the current reserves of T0 and T1 with the latest updated timestamp
    public fun get_reserves<X, Y>(): (u64, u64, u64) acquires TokenPairReserve {
        let reserve = borrow_global<TokenPairReserve<X, Y>>(MODULE_ADMIN);
        (
            reserve.reserve_x,
            reserve.reserve_y,
            reserve.block_timestamp_last
        )
    }

    /// Obtain the LP token balance of `addr`.
    /// This method can only be used to check other users' balance.
    public fun lp_balance<X, Y>(addr: address): u64 {
        coin::balance<LPToken<X, Y>>(addr)
    }

    /// The amount of balance currently in pools of the liquidity pair
    public fun token_balances<X, Y>(): (u64, u64) acquires TokenPairMetadata {
        let meta =
            borrow_global<TokenPairMetadata<X, Y>>(MODULE_ADMIN);
        token_balances_metadata<X, Y>(meta)
    }

    fun check_coin_store<X>(sender: &signer) {
        if (!coin::is_account_registered<X>(signer::address_of(sender))) {
            coin::register<X>(sender);
        };
    }


    fun update<X, Y>(balance_x: u64, balance_y: u64, reserve: &mut TokenPairReserve<X, Y>) {
        assert!(
            (balance_x as u128) <= BALANCE_MAX && (balance_y as u128) <= BALANCE_MAX,
            ERROR_OVERFLOW
        );

        let block_timestamp = timestamp::now_seconds() % 0xFFFFFFFF;
        // TODO
        // let time_elapsed = block_timestamp - timestamp_last; // overflow is desired
        // if (time_elapsed > 0 && reserve_x != 0 && reserve_y != 0) {
        //      price0CumulativeLast += uint(UQ112x112.encode(_reserve_y).uqdiv(_reserve_x)) * timeElapsed;
        //      price1CumulativeLast += uint(UQ112x112.encode(_reserve_x).uqdiv(_reserve_y)) * timeElapsed;
        //  }

        reserve.reserve_x = balance_x;
        reserve.reserve_y = balance_y;
        reserve.block_timestamp_last = block_timestamp;
    }

    fun token_balances_metadata<X, Y>(metadata: &TokenPairMetadata<X, Y>): (u64, u64) {
        (
            coin::value(&metadata.balance_x),
            coin::value(&metadata.balance_y)
        )
    }

    /// Get the total supply of LP Tokens
    fun total_lp_supply<X, Y>(): u128 {
        option::get_with_default(
            &coin::supply<LPToken<X, Y>>(),
            0u128
        )
    }

    /// Mint LP Tokens to account
    fun mint_lp_to<X, Y>(
        to: address,
        amount: u64,
        mint_cap: &coin::MintCapability<LPToken<X, Y>>
    ) {
        let coins = coin::mint<LPToken<X, Y>>(amount, mint_cap);
        coin::deposit(to, coins);
    }

    /// Mint LP Tokens to account
    fun mint_lp<X, Y>(amount: u64, mint_cap: &coin::MintCapability<LPToken<X, Y>>): coin::Coin<LPToken<X, Y>> {
        coin::mint<LPToken<X, Y>>(amount, mint_cap)
    }

    /// Burn LP tokens held in this contract, i.e. TokenPairMetadata.lp
    fun burn_lp<X, Y>(
        amount: u64,
        metadata: &mut TokenPairMetadata<X, Y>
    ) {
        assert!(coin::value(&metadata.lp) >= amount, ERROR_INSUFFICIENT_LIQUIDITY);
        let coins = coin::extract(&mut metadata.lp, amount);
        coin::burn<LPToken<X, Y>>(coins, &metadata.burn_cap);
    }



    fun deposit_x<X, Y>(amount: coin::Coin<X>) acquires TokenPairMetadata {
        let metadata =
            borrow_global_mut<TokenPairMetadata<X, Y>>(MODULE_ADMIN);
        coin::merge(&mut metadata.balance_x, amount);
    }

    fun deposit_y<X, Y>(amount: coin::Coin<Y>) acquires TokenPairMetadata {
        let metadata =
            borrow_global_mut<TokenPairMetadata<X, Y>>(MODULE_ADMIN);
        coin::merge(&mut metadata.balance_y, amount);
    }

    /// Extract `amount` from this contract
    fun extract_x<X, Y>(amount: u64, metadata: &mut TokenPairMetadata<X, Y>): coin::Coin<X> {
        assert!(coin::value<X>(&metadata.balance_x) > amount, ERROR_INSUFFICIENT_AMOUNT);
        coin::extract(&mut metadata.balance_x, amount)
    }

    /// Extract `amount` from this contract
    fun extract_y<X, Y>(amount: u64, metadata: &mut TokenPairMetadata<X, Y>): coin::Coin<Y> {
        assert!(coin::value<Y>(&metadata.balance_y) > amount, ERROR_INSUFFICIENT_AMOUNT);
        coin::extract(&mut metadata.balance_y, amount)
    }

    /// Transfer `amount` from this contract to `recipient`
    fun transfer_x<X, Y>(amount: u64, recipient: address, metadata: &mut TokenPairMetadata<X, Y>) {
        let coins = extract_x(amount, metadata);
        coin::deposit(recipient, coins);
    }

    /// Transfer `amount` from this contract to `recipient`
    fun transfer_y<X, Y>(amount: u64, recipient: address, metadata: &mut TokenPairMetadata<X, Y>) {
        let coins = extract_y(amount, metadata);
        coin::deposit(recipient, coins);
    }


    //
    // // ================ Tests ================
    // #[test_only]
    // struct Token0 has key {}
    //
    // #[test_only]
    // struct Token1 has key {}
    //
    // #[test_only]
    // struct CapContainer<phantom T: key> has key {
    //     mc: coin::MintCapability<T>,
    //     bc: coin::BurnCapability<T>,
    //     fc: coin::FreezeCapability<T>,
    // }
    //
    // #[test_only]
    // fun mint_lp_to_self<X, Y>(amount: u64) acquires TokenPairMetadata {
    //     let metadata = borrow_global_mut<TokenPairMetadata<X, Y>>(@hypermatter);
    //     coin::merge(
    //         &mut metadata.lp,
    //         coin::mint(amount, &metadata.mint_cap)
    //     );
    // }
    //
    // #[test_only]
    // fun issue_token<T: key>(admin: &signer, to: &signer, name: vector<u8>, total_supply: u64) {
    //     let (bc, fc, mc) = coin::initialize<T>(
    //         admin,
    //         string::utf8(name),
    //         string::utf8(name),
    //         8,
    //         true
    //     );
    //
    //     coin::register<T>(admin);
    //     coin::register<T>(to);
    //
    //     let a = coin::mint(total_supply, &mc);
    //     coin::deposit(signer::address_of(to), a);
    //     move_to<CapContainer<T>>(admin, CapContainer{ mc, bc, fc });
    // }
    //
    // #[test(admin = @hypermatter)]
    // public fun init_works(admin: &signer) {
    //     use aptos_framework::aptos_account;
    //     aptos_account::create_account(signer::address_of(admin));
    //     let fee_to = signer::address_of(admin);
    //     create_token_pair<Token0, Token1>(
    //         admin,
    //         fee_to,
    //         true,
    //         b"name",
    //         b"symbol",
    //         8,
    //     );
    // }


}