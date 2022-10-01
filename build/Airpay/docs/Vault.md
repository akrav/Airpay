
<a name="0x1_Vault"></a>

# Module `0x1::Vault`



-  [Resource `LPToken`](#0x1_Vault_LPToken)
-  [Resource `TokenPairMetadata`](#0x1_Vault_TokenPairMetadata)
-  [Resource `TokenPairReserve`](#0x1_Vault_TokenPairReserve)
-  [Constants](#@Constants_0)
-  [Function `create_token_pair`](#0x1_Vault_create_token_pair)
-  [Function `register_account`](#0x1_Vault_register_account)
-  [Function `get_reserves`](#0x1_Vault_get_reserves)
-  [Function `lp_balance`](#0x1_Vault_lp_balance)
-  [Function `token_balances`](#0x1_Vault_token_balances)
-  [Function `check_coin_store`](#0x1_Vault_check_coin_store)
-  [Function `update`](#0x1_Vault_update)
-  [Function `token_balances_metadata`](#0x1_Vault_token_balances_metadata)
-  [Function `total_lp_supply`](#0x1_Vault_total_lp_supply)
-  [Function `mint_lp_to`](#0x1_Vault_mint_lp_to)
-  [Function `mint_lp`](#0x1_Vault_mint_lp)
-  [Function `burn_lp`](#0x1_Vault_burn_lp)
-  [Function `deposit_x`](#0x1_Vault_deposit_x)
-  [Function `deposit_y`](#0x1_Vault_deposit_y)
-  [Function `extract_x`](#0x1_Vault_extract_x)
-  [Function `extract_y`](#0x1_Vault_extract_y)
-  [Function `transfer_x`](#0x1_Vault_transfer_x)
-  [Function `transfer_y`](#0x1_Vault_transfer_y)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::timestamp</a>;
</code></pre>



<a name="0x1_Vault_LPToken"></a>

## Resource `LPToken`

The LP Token type


<pre><code><b>struct</b> <a href="Vault.md#0x1_Vault_LPToken">LPToken</a>&lt;X, Y&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x1_Vault_TokenPairMetadata"></a>

## Resource `TokenPairMetadata`

Stores the metadata required for the token pairs


<pre><code><b>struct</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a>&lt;X, Y&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>locked: bool</code>
</dt>
<dd>
 Lock for mint and burn
</dd>
<dt>
<code>creator: <b>address</b></code>
</dt>
<dd>
 The admin of the token pair
</dd>
<dt>
<code>fee_to: <b>address</b></code>
</dt>
<dd>
 The address to transfer mint fees to
</dd>
<dt>
<code>fee_on: bool</code>
</dt>
<dd>
 Whether we are charging a fee for mint/burn
</dd>
<dt>
<code>k_last: u128</code>
</dt>
<dd>
 It's reserve_x * reserve_y, as of immediately after the most recent liquidity event
</dd>
<dt>
<code>lp: <a href="_Coin">coin::Coin</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">Vault::LPToken</a>&lt;X, Y&gt;&gt;</code>
</dt>
<dd>
 The LP token
</dd>
<dt>
<code>balance_x: <a href="_Coin">coin::Coin</a>&lt;X&gt;</code>
</dt>
<dd>
 T0 token balance
</dd>
<dt>
<code>balance_y: <a href="_Coin">coin::Coin</a>&lt;Y&gt;</code>
</dt>
<dd>
 T1 token balance
</dd>
<dt>
<code>mint_cap: <a href="_MintCapability">coin::MintCapability</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">Vault::LPToken</a>&lt;X, Y&gt;&gt;</code>
</dt>
<dd>
 Mint capacity of LP Token
</dd>
<dt>
<code>burn_cap: <a href="_BurnCapability">coin::BurnCapability</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">Vault::LPToken</a>&lt;X, Y&gt;&gt;</code>
</dt>
<dd>
 Burn capacity of LP Token
</dd>
<dt>
<code>freeze_cap: <a href="_FreezeCapability">coin::FreezeCapability</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">Vault::LPToken</a>&lt;X, Y&gt;&gt;</code>
</dt>
<dd>
 Freeze capacity of LP Token
</dd>
</dl>


</details>

<a name="0x1_Vault_TokenPairReserve"></a>

## Resource `TokenPairReserve`

Stores the reservation info required for the token pairs


<pre><code><b>struct</b> <a href="Vault.md#0x1_Vault_TokenPairReserve">TokenPairReserve</a>&lt;X, Y&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>reserve_x: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>reserve_y: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>block_timestamp_last: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x1_Vault_BALANCE_MAX"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_BALANCE_MAX">BALANCE_MAX</a>: u128 = 5192296858534827628530496329220095;
</code></pre>



<a name="0x1_Vault_ERROR_ALREADY_INITIALIZED"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_ALREADY_INITIALIZED">ERROR_ALREADY_INITIALIZED</a>: u64 = 1;
</code></pre>



<a name="0x1_Vault_ERROR_ALREADY_LOCKED"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_ALREADY_LOCKED">ERROR_ALREADY_LOCKED</a>: u64 = 3;
</code></pre>



<a name="0x1_Vault_ERROR_INSUFFICIENT_AMOUNT"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_INSUFFICIENT_AMOUNT">ERROR_INSUFFICIENT_AMOUNT</a>: u64 = 6;
</code></pre>



<a name="0x1_Vault_ERROR_INSUFFICIENT_INPUT_AMOUNT"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_INSUFFICIENT_INPUT_AMOUNT">ERROR_INSUFFICIENT_INPUT_AMOUNT</a>: u64 = 14;
</code></pre>



<a name="0x1_Vault_ERROR_INSUFFICIENT_LIQUIDITY"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_INSUFFICIENT_LIQUIDITY">ERROR_INSUFFICIENT_LIQUIDITY</a>: u64 = 7;
</code></pre>



<a name="0x1_Vault_ERROR_INSUFFICIENT_LIQUIDITY_BURNED"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_INSUFFICIENT_LIQUIDITY_BURNED">ERROR_INSUFFICIENT_LIQUIDITY_BURNED</a>: u64 = 10;
</code></pre>



<a name="0x1_Vault_ERROR_INSUFFICIENT_LIQUIDITY_MINTED"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_INSUFFICIENT_LIQUIDITY_MINTED">ERROR_INSUFFICIENT_LIQUIDITY_MINTED</a>: u64 = 4;
</code></pre>



<a name="0x1_Vault_ERROR_INSUFFICIENT_OUTPUT_AMOUNT"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_INSUFFICIENT_OUTPUT_AMOUNT">ERROR_INSUFFICIENT_OUTPUT_AMOUNT</a>: u64 = 13;
</code></pre>



<a name="0x1_Vault_ERROR_INSUFFICIENT_TOKEN0_AMOUNT"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_INSUFFICIENT_TOKEN0_AMOUNT">ERROR_INSUFFICIENT_TOKEN0_AMOUNT</a>: u64 = 11;
</code></pre>



<a name="0x1_Vault_ERROR_INSUFFICIENT_TOKEN1_AMOUNT"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_INSUFFICIENT_TOKEN1_AMOUNT">ERROR_INSUFFICIENT_TOKEN1_AMOUNT</a>: u64 = 12;
</code></pre>



<a name="0x1_Vault_ERROR_INVALID_AMOUNT"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_INVALID_AMOUNT">ERROR_INVALID_AMOUNT</a>: u64 = 8;
</code></pre>



<a name="0x1_Vault_ERROR_K"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_K">ERROR_K</a>: u64 = 15;
</code></pre>



<a name="0x1_Vault_ERROR_NOT_CREATOR"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_NOT_CREATOR">ERROR_NOT_CREATOR</a>: u64 = 2;
</code></pre>



<a name="0x1_Vault_ERROR_ONLY_ADMIN"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_ONLY_ADMIN">ERROR_ONLY_ADMIN</a>: u64 = 0;
</code></pre>



<a name="0x1_Vault_ERROR_OVERFLOW"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_OVERFLOW">ERROR_OVERFLOW</a>: u64 = 5;
</code></pre>



<a name="0x1_Vault_ERROR_TOKENS_NOT_SORTED"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_TOKENS_NOT_SORTED">ERROR_TOKENS_NOT_SORTED</a>: u64 = 9;
</code></pre>



<a name="0x1_Vault_ERROR_X_NOT_REGISTERED"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_X_NOT_REGISTERED">ERROR_X_NOT_REGISTERED</a>: u64 = 16;
</code></pre>



<a name="0x1_Vault_ERROR_Y_NOT_REGISTERED"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_ERROR_Y_NOT_REGISTERED">ERROR_Y_NOT_REGISTERED</a>: u64 = 16;
</code></pre>



<a name="0x1_Vault_MINIMUM_LIQUIDITY"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_MINIMUM_LIQUIDITY">MINIMUM_LIQUIDITY</a>: u128 = 1000;
</code></pre>



<a name="0x1_Vault_MODULE_ADMIN"></a>



<pre><code><b>const</b> <a href="Vault.md#0x1_Vault_MODULE_ADMIN">MODULE_ADMIN</a>: <b>address</b> = 1;
</code></pre>



<a name="0x1_Vault_create_token_pair"></a>

## Function `create_token_pair`

Create the specified token pair


<pre><code><b>public</b> <b>fun</b> <a href="Vault.md#0x1_Vault_create_token_pair">create_token_pair</a>&lt;X, Y&gt;(admin: &<a href="">signer</a>, fee_to: <b>address</b>, fee_on: bool, lp_name: <a href="">vector</a>&lt;u8&gt;, lp_symbol: <a href="">vector</a>&lt;u8&gt;, decimals: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vault.md#0x1_Vault_create_token_pair">create_token_pair</a>&lt;X, Y&gt;(
    admin: &<a href="">signer</a>,
    fee_to: <b>address</b>,
    fee_on: bool,
    lp_name: <a href="">vector</a>&lt;u8&gt;,
    lp_symbol: <a href="">vector</a>&lt;u8&gt;,
    decimals: u8,
) {
    <b>let</b> sender_addr = <a href="_address_of">signer::address_of</a>(admin);
    <b>assert</b>!(sender_addr == <a href="Vault.md#0x1_Vault_MODULE_ADMIN">MODULE_ADMIN</a>, <a href="Vault.md#0x1_Vault_ERROR_NOT_CREATOR">ERROR_NOT_CREATOR</a>);

    <b>assert</b>!(!<b>exists</b>&lt;<a href="Vault.md#0x1_Vault_TokenPairReserve">TokenPairReserve</a>&lt;X, Y&gt;&gt;(sender_addr), <a href="Vault.md#0x1_Vault_ERROR_ALREADY_INITIALIZED">ERROR_ALREADY_INITIALIZED</a>);
    <b>assert</b>!(!<b>exists</b>&lt;<a href="Vault.md#0x1_Vault_TokenPairReserve">TokenPairReserve</a>&lt;Y, X&gt;&gt;(sender_addr), <a href="Vault.md#0x1_Vault_ERROR_ALREADY_INITIALIZED">ERROR_ALREADY_INITIALIZED</a>);

    // now we init the LP token
    <b>let</b> (burn_cap, freeze_cap, mint_cap) = <a href="_initialize">coin::initialize</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">LPToken</a>&lt;X, Y&gt;&gt;(
        admin,
        <a href="_utf8">string::utf8</a>(lp_name),
        <a href="_utf8">string::utf8</a>(lp_symbol),
        decimals,
        <b>true</b>
    );

    <b>move_to</b>&lt;<a href="Vault.md#0x1_Vault_TokenPairReserve">TokenPairReserve</a>&lt;X, Y&gt;&gt;(
        admin,
        <a href="Vault.md#0x1_Vault_TokenPairReserve">TokenPairReserve</a> {
            reserve_x: 0,
            reserve_y: 0,
            block_timestamp_last: 0
        }
    );

    <b>move_to</b>&lt;<a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a>&lt;X, Y&gt;&gt;(
        admin,
        <a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a> {
            locked: <b>false</b>,
            creator: sender_addr,
            fee_to,
            fee_on,
            k_last: 0,
            lp: <a href="_zero">coin::zero</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">LPToken</a>&lt;X, Y&gt;&gt;(),
            balance_x: <a href="_zero">coin::zero</a>&lt;X&gt;(),
            balance_y: <a href="_zero">coin::zero</a>&lt;Y&gt;(),
            mint_cap,
            burn_cap,
            freeze_cap,
        }
    );

    // create LP CoinStore for admin, which is needed <b>as</b> a lock for minimum_liquidity
    <a href="_register">coin::register</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">LPToken</a>&lt;X,Y&gt;&gt;(admin);
}
</code></pre>



</details>

<a name="0x1_Vault_register_account"></a>

## Function `register_account`

The init process for a sender. One must call this function first
before interacting with the mint/burn.


<pre><code><b>public</b> <b>fun</b> <a href="Vault.md#0x1_Vault_register_account">register_account</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vault.md#0x1_Vault_register_account">register_account</a>&lt;X, Y&gt;(sender: &<a href="">signer</a>) {
    <a href="_register">coin::register</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">LPToken</a>&lt;X, Y&gt;&gt;(sender);
}
</code></pre>



</details>

<a name="0x1_Vault_get_reserves"></a>

## Function `get_reserves`

Get the current reserves of T0 and T1 with the latest updated timestamp


<pre><code><b>public</b> <b>fun</b> <a href="Vault.md#0x1_Vault_get_reserves">get_reserves</a>&lt;X, Y&gt;(): (u64, u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vault.md#0x1_Vault_get_reserves">get_reserves</a>&lt;X, Y&gt;(): (u64, u64, u64) <b>acquires</b> <a href="Vault.md#0x1_Vault_TokenPairReserve">TokenPairReserve</a> {
    <b>let</b> reserve = <b>borrow_global</b>&lt;<a href="Vault.md#0x1_Vault_TokenPairReserve">TokenPairReserve</a>&lt;X, Y&gt;&gt;(<a href="Vault.md#0x1_Vault_MODULE_ADMIN">MODULE_ADMIN</a>);
    (
        reserve.reserve_x,
        reserve.reserve_y,
        reserve.block_timestamp_last
    )
}
</code></pre>



</details>

<a name="0x1_Vault_lp_balance"></a>

## Function `lp_balance`

Obtain the LP token balance of <code>addr</code>.
This method can only be used to check other users' balance.


<pre><code><b>public</b> <b>fun</b> <a href="Vault.md#0x1_Vault_lp_balance">lp_balance</a>&lt;X, Y&gt;(addr: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vault.md#0x1_Vault_lp_balance">lp_balance</a>&lt;X, Y&gt;(addr: <b>address</b>): u64 {
    <a href="_balance">coin::balance</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">LPToken</a>&lt;X, Y&gt;&gt;(addr)
}
</code></pre>



</details>

<a name="0x1_Vault_token_balances"></a>

## Function `token_balances`

The amount of balance currently in pools of the liquidity pair


<pre><code><b>public</b> <b>fun</b> <a href="Vault.md#0x1_Vault_token_balances">token_balances</a>&lt;X, Y&gt;(): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="Vault.md#0x1_Vault_token_balances">token_balances</a>&lt;X, Y&gt;(): (u64, u64) <b>acquires</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a> {
    <b>let</b> meta =
        <b>borrow_global</b>&lt;<a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a>&lt;X, Y&gt;&gt;(<a href="Vault.md#0x1_Vault_MODULE_ADMIN">MODULE_ADMIN</a>);
    <a href="Vault.md#0x1_Vault_token_balances_metadata">token_balances_metadata</a>&lt;X, Y&gt;(meta)
}
</code></pre>



</details>

<a name="0x1_Vault_check_coin_store"></a>

## Function `check_coin_store`



<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_check_coin_store">check_coin_store</a>&lt;X&gt;(sender: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_check_coin_store">check_coin_store</a>&lt;X&gt;(sender: &<a href="">signer</a>) {
    <b>if</b> (!<a href="_is_account_registered">coin::is_account_registered</a>&lt;X&gt;(<a href="_address_of">signer::address_of</a>(sender))) {
        <a href="_register">coin::register</a>&lt;X&gt;(sender);
    };
}
</code></pre>



</details>

<a name="0x1_Vault_update"></a>

## Function `update`



<pre><code><b>fun</b> <b>update</b>&lt;X, Y&gt;(balance_x: u64, balance_y: u64, reserve: &<b>mut</b> <a href="Vault.md#0x1_Vault_TokenPairReserve">Vault::TokenPairReserve</a>&lt;X, Y&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <b>update</b>&lt;X, Y&gt;(balance_x: u64, balance_y: u64, reserve: &<b>mut</b> <a href="Vault.md#0x1_Vault_TokenPairReserve">TokenPairReserve</a>&lt;X, Y&gt;) {
    <b>assert</b>!(
        (balance_x <b>as</b> u128) &lt;= <a href="Vault.md#0x1_Vault_BALANCE_MAX">BALANCE_MAX</a> && (balance_y <b>as</b> u128) &lt;= <a href="Vault.md#0x1_Vault_BALANCE_MAX">BALANCE_MAX</a>,
        <a href="Vault.md#0x1_Vault_ERROR_OVERFLOW">ERROR_OVERFLOW</a>
    );

    <b>let</b> block_timestamp = <a href="_now_seconds">timestamp::now_seconds</a>() % 0xFFFFFFFF;
    // TODO
    // <b>let</b> time_elapsed = block_timestamp - timestamp_last; // overflow is desired
    // <b>if</b> (time_elapsed &gt; 0 && reserve_x != 0 && reserve_y != 0) {
    //      price0CumulativeLast += uint(UQ112x112.encode(_reserve_y).uqdiv(_reserve_x)) * timeElapsed;
    //      price1CumulativeLast += uint(UQ112x112.encode(_reserve_x).uqdiv(_reserve_y)) * timeElapsed;
    //  }

    reserve.reserve_x = balance_x;
    reserve.reserve_y = balance_y;
    reserve.block_timestamp_last = block_timestamp;
}
</code></pre>



</details>

<a name="0x1_Vault_token_balances_metadata"></a>

## Function `token_balances_metadata`



<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_token_balances_metadata">token_balances_metadata</a>&lt;X, Y&gt;(metadata: &<a href="Vault.md#0x1_Vault_TokenPairMetadata">Vault::TokenPairMetadata</a>&lt;X, Y&gt;): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_token_balances_metadata">token_balances_metadata</a>&lt;X, Y&gt;(metadata: &<a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a>&lt;X, Y&gt;): (u64, u64) {
    (
        <a href="_value">coin::value</a>(&metadata.balance_x),
        <a href="_value">coin::value</a>(&metadata.balance_y)
    )
}
</code></pre>



</details>

<a name="0x1_Vault_total_lp_supply"></a>

## Function `total_lp_supply`

Get the total supply of LP Tokens


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_total_lp_supply">total_lp_supply</a>&lt;X, Y&gt;(): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_total_lp_supply">total_lp_supply</a>&lt;X, Y&gt;(): u128 {
    <a href="_get_with_default">option::get_with_default</a>(
        &<a href="_supply">coin::supply</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">LPToken</a>&lt;X, Y&gt;&gt;(),
        0u128
    )
}
</code></pre>



</details>

<a name="0x1_Vault_mint_lp_to"></a>

## Function `mint_lp_to`

Mint LP Tokens to account


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_mint_lp_to">mint_lp_to</a>&lt;X, Y&gt;(<b>to</b>: <b>address</b>, amount: u64, mint_cap: &<a href="_MintCapability">coin::MintCapability</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">Vault::LPToken</a>&lt;X, Y&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_mint_lp_to">mint_lp_to</a>&lt;X, Y&gt;(
    <b>to</b>: <b>address</b>,
    amount: u64,
    mint_cap: &<a href="_MintCapability">coin::MintCapability</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">LPToken</a>&lt;X, Y&gt;&gt;
) {
    <b>let</b> coins = <a href="_mint">coin::mint</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">LPToken</a>&lt;X, Y&gt;&gt;(amount, mint_cap);
    <a href="_deposit">coin::deposit</a>(<b>to</b>, coins);
}
</code></pre>



</details>

<a name="0x1_Vault_mint_lp"></a>

## Function `mint_lp`

Mint LP Tokens to account


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_mint_lp">mint_lp</a>&lt;X, Y&gt;(amount: u64, mint_cap: &<a href="_MintCapability">coin::MintCapability</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">Vault::LPToken</a>&lt;X, Y&gt;&gt;): <a href="_Coin">coin::Coin</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">Vault::LPToken</a>&lt;X, Y&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_mint_lp">mint_lp</a>&lt;X, Y&gt;(amount: u64, mint_cap: &<a href="_MintCapability">coin::MintCapability</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">LPToken</a>&lt;X, Y&gt;&gt;): <a href="_Coin">coin::Coin</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">LPToken</a>&lt;X, Y&gt;&gt; {
    <a href="_mint">coin::mint</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">LPToken</a>&lt;X, Y&gt;&gt;(amount, mint_cap)
}
</code></pre>



</details>

<a name="0x1_Vault_burn_lp"></a>

## Function `burn_lp`

Burn LP tokens held in this contract, i.e. TokenPairMetadata.lp


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_burn_lp">burn_lp</a>&lt;X, Y&gt;(amount: u64, metadata: &<b>mut</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">Vault::TokenPairMetadata</a>&lt;X, Y&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_burn_lp">burn_lp</a>&lt;X, Y&gt;(
    amount: u64,
    metadata: &<b>mut</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a>&lt;X, Y&gt;
) {
    <b>assert</b>!(<a href="_value">coin::value</a>(&metadata.lp) &gt;= amount, <a href="Vault.md#0x1_Vault_ERROR_INSUFFICIENT_LIQUIDITY">ERROR_INSUFFICIENT_LIQUIDITY</a>);
    <b>let</b> coins = <a href="_extract">coin::extract</a>(&<b>mut</b> metadata.lp, amount);
    <a href="_burn">coin::burn</a>&lt;<a href="Vault.md#0x1_Vault_LPToken">LPToken</a>&lt;X, Y&gt;&gt;(coins, &metadata.burn_cap);
}
</code></pre>



</details>

<a name="0x1_Vault_deposit_x"></a>

## Function `deposit_x`



<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_deposit_x">deposit_x</a>&lt;X, Y&gt;(amount: <a href="_Coin">coin::Coin</a>&lt;X&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_deposit_x">deposit_x</a>&lt;X, Y&gt;(amount: <a href="_Coin">coin::Coin</a>&lt;X&gt;) <b>acquires</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a> {
    <b>let</b> metadata =
        <b>borrow_global_mut</b>&lt;<a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a>&lt;X, Y&gt;&gt;(<a href="Vault.md#0x1_Vault_MODULE_ADMIN">MODULE_ADMIN</a>);
    <a href="_merge">coin::merge</a>(&<b>mut</b> metadata.balance_x, amount);
}
</code></pre>



</details>

<a name="0x1_Vault_deposit_y"></a>

## Function `deposit_y`



<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_deposit_y">deposit_y</a>&lt;X, Y&gt;(amount: <a href="_Coin">coin::Coin</a>&lt;Y&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_deposit_y">deposit_y</a>&lt;X, Y&gt;(amount: <a href="_Coin">coin::Coin</a>&lt;Y&gt;) <b>acquires</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a> {
    <b>let</b> metadata =
        <b>borrow_global_mut</b>&lt;<a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a>&lt;X, Y&gt;&gt;(<a href="Vault.md#0x1_Vault_MODULE_ADMIN">MODULE_ADMIN</a>);
    <a href="_merge">coin::merge</a>(&<b>mut</b> metadata.balance_y, amount);
}
</code></pre>



</details>

<a name="0x1_Vault_extract_x"></a>

## Function `extract_x`

Extract <code>amount</code> from this contract


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_extract_x">extract_x</a>&lt;X, Y&gt;(amount: u64, metadata: &<b>mut</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">Vault::TokenPairMetadata</a>&lt;X, Y&gt;): <a href="_Coin">coin::Coin</a>&lt;X&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_extract_x">extract_x</a>&lt;X, Y&gt;(amount: u64, metadata: &<b>mut</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a>&lt;X, Y&gt;): <a href="_Coin">coin::Coin</a>&lt;X&gt; {
    <b>assert</b>!(<a href="_value">coin::value</a>&lt;X&gt;(&metadata.balance_x) &gt; amount, <a href="Vault.md#0x1_Vault_ERROR_INSUFFICIENT_AMOUNT">ERROR_INSUFFICIENT_AMOUNT</a>);
    <a href="_extract">coin::extract</a>(&<b>mut</b> metadata.balance_x, amount)
}
</code></pre>



</details>

<a name="0x1_Vault_extract_y"></a>

## Function `extract_y`

Extract <code>amount</code> from this contract


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_extract_y">extract_y</a>&lt;X, Y&gt;(amount: u64, metadata: &<b>mut</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">Vault::TokenPairMetadata</a>&lt;X, Y&gt;): <a href="_Coin">coin::Coin</a>&lt;Y&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_extract_y">extract_y</a>&lt;X, Y&gt;(amount: u64, metadata: &<b>mut</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a>&lt;X, Y&gt;): <a href="_Coin">coin::Coin</a>&lt;Y&gt; {
    <b>assert</b>!(<a href="_value">coin::value</a>&lt;Y&gt;(&metadata.balance_y) &gt; amount, <a href="Vault.md#0x1_Vault_ERROR_INSUFFICIENT_AMOUNT">ERROR_INSUFFICIENT_AMOUNT</a>);
    <a href="_extract">coin::extract</a>(&<b>mut</b> metadata.balance_y, amount)
}
</code></pre>



</details>

<a name="0x1_Vault_transfer_x"></a>

## Function `transfer_x`

Transfer <code>amount</code> from this contract to <code>recipient</code>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_transfer_x">transfer_x</a>&lt;X, Y&gt;(amount: u64, recipient: <b>address</b>, metadata: &<b>mut</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">Vault::TokenPairMetadata</a>&lt;X, Y&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_transfer_x">transfer_x</a>&lt;X, Y&gt;(amount: u64, recipient: <b>address</b>, metadata: &<b>mut</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a>&lt;X, Y&gt;) {
    <b>let</b> coins = <a href="Vault.md#0x1_Vault_extract_x">extract_x</a>(amount, metadata);
    <a href="_deposit">coin::deposit</a>(recipient, coins);
}
</code></pre>



</details>

<a name="0x1_Vault_transfer_y"></a>

## Function `transfer_y`

Transfer <code>amount</code> from this contract to <code>recipient</code>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_transfer_y">transfer_y</a>&lt;X, Y&gt;(amount: u64, recipient: <b>address</b>, metadata: &<b>mut</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">Vault::TokenPairMetadata</a>&lt;X, Y&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Vault.md#0x1_Vault_transfer_y">transfer_y</a>&lt;X, Y&gt;(amount: u64, recipient: <b>address</b>, metadata: &<b>mut</b> <a href="Vault.md#0x1_Vault_TokenPairMetadata">TokenPairMetadata</a>&lt;X, Y&gt;) {
    <b>let</b> coins = <a href="Vault.md#0x1_Vault_extract_y">extract_y</a>(amount, metadata);
    <a href="_deposit">coin::deposit</a>(recipient, coins);
}
</code></pre>



</details>
