// module zaptos_admin::staptos_coin {
//
//     // Not used in this example
//     use std::signer;
//     use std::string;
//
//
//     use aptos_framework::coin::{Self, MintCapability, BurnCapability, Coin};
//
//     friend zaptos_admin::zaptos_stake;
//     #[test_only]
//     friend zaptos_admin::staptos_coin_tests;
//
//     // For Errors Readability.
//
//     /// When capability is missed on account.
//     const ERR_CAP_MISSED: u64 = 100;
//
//     /// When capability already exists on account.
//     const ERR_CAP_EXISTS: u64 = 101;
//
//
//
//
//     /// Represents new user coin.
//     /// Indeeed this type will be used as CoinType for your new coin.
//     struct ST_APTOS {}
//
//     //CapType is a generic type with the store ability. They could have wrote <T: store>.
//     /// The struct to store capability: mint and burn.
//     struct Capability<CapType: store> has key {
//         cap: CapType
//     }
//
//     // A Struct that tells says the ST_APTOS coin has the ability to be minted and to be burned
//     struct CapabilityStorage has key {
//         mint_cap: MintCapability<ST_APTOS>,
//         burn_cap: BurnCapability<ST_APTOS>,
//     }
//
//     /// Creates a new Coin with given `CoinType` and returns minting/burning capabilities.
//     /// The given signer also becomes the account hosting the information  about the coin
//     /// Initializing `stAPT` as coin in Aptos network.
//     public fun initialize_internal(account: &signer) {
//         let (burn_cap, freeze_cap, mint_cap) = coin::initialize<ST_APTOS>(
//             account,
//             string::utf8(b"stAPT"), // Name
//             string::utf8(b"stAPT"), // Symbol
//             6, // Decimals
//             true, //monitor_supply or parallelizable look here for definition: https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/framework/aptos-framework/sources/coin.move
//         );
//
//         // Store mint and burn capabilities under user account.
//         let storage = CapabilityStorage { mint_cap, burn_cap };
//
//         // Store the minting and burning ability information under the signer's account
//         move_to(account, storage);
//     }
//
//     // ToDo: check whether this is safe!!
//     public(friend) fun mint(amount: u64): Coin<ST_APTOS> acquires CapabilityStorage {
//         let storage = borrow_global<CapabilityStorage>(@zaptos_admin);
//         let coins = coin::mint(amount, &storage.mint_cap);
//         return coins
//     }
//
//     public(friend) fun burn(coins: Coin<ST_APTOS>) acquires CapabilityStorage {
//         let storage = borrow_global<CapabilityStorage>(@zaptos_admin);
//         coin::burn(coins, &storage.burn_cap);
//     }
//
//     /// Similar to `initialize_internal` but can be executed as script.
//     public entry fun initialize(account: &signer) {
//         initialize_internal(account);
//     }
//
//     /// Extract mint or burn capability from user account.
//     /// Returns extracted capability.
//     public fun extract_capability<CapType: store>(account: &signer): CapType acquires Capability {
//         let account_addr = signer::address_of(account);
//
//         // Check if capability stored under account.
//         assert!(exists<Capability<CapType>>(account_addr), ERR_CAP_MISSED);
//
//         // Get capability stored under account.
//         let Capability { cap } = move_from<Capability<CapType>>(account_addr);
//         cap
//     }
//
//     /// Put mint or burn `capability` under user account.
//     public fun put_capability<CapType: store>(account: &signer, capability: CapType) {
//         let account_addr = signer::address_of(account);
//
//         // Check if capability doesn't exist under account so we can store.
//         assert!(!exists<Capability<CapType>>(account_addr), ERR_CAP_EXISTS);
//
//         // Store capability.
//         move_to(account, Capability<CapType> {
//             cap: capability
//         });
//     }
// }