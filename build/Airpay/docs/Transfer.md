
<a name="0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_mint_and_deposit"></a>

# Module `0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff::mint_and_deposit`



-  [Constants](#@Constants_0)
-  [Function `mint_and_deposit`](#0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_mint_and_deposit_mint_and_deposit)


<pre><code><b>use</b> <a href="">0x1::coin</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_mint_and_deposit_MODULE_ADMIN"></a>



<pre><code><b>const</b> <a href="Transfer.md#0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_mint_and_deposit_MODULE_ADMIN">MODULE_ADMIN</a>: <b>address</b> = 1;
</code></pre>



<a name="0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_mint_and_deposit_mint_and_deposit"></a>

## Function `mint_and_deposit`

Script to mint coins and deposit coins to account.
Recipient should has created <code>Balance</code> resource on his account, so see <code>create_balance.<b>move</b></code> script.
calculate convertion of Users wallet to usdc
calculate convertion of purchases wallet to usdc
move money


<pre><code><b>public</b> <b>fun</b> <a href="Transfer.md#0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_mint_and_deposit">mint_and_deposit</a>&lt;T&gt;(acc: <a href="">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="Transfer.md#0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_mint_and_deposit">mint_and_deposit</a>&lt;T&gt;(acc: <a href="">signer</a>, amount: u64) {
    <b>let</b> coins = <a href="_withdraw">coin::withdraw</a>&lt;T&gt;(&acc, amount);
    <a href="_deposit">coin::deposit</a>(<a href="Transfer.md#0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_mint_and_deposit_MODULE_ADMIN">MODULE_ADMIN</a>, coins);
}
</code></pre>



</details>
