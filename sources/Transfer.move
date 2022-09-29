script {
    // use Sender::Coins;
    use aptos_framework::coin;
    use switchboard-v2


    const MODULE_ADMIN: address = @hypermatter;


    // Don't know how this is minting a coin, appears to just be depositing a coin to another account.
    /// Script to mint coins and deposit coins to account.
    /// Recipient should has created `Balance` resource on his account, so see `create_balance.move` script.


    /// calculate convertion of Users wallet to usdc
    // fun convert_balance_to_stable(acc: signer, amount: u64) {
    //     let coins = coin::withdraw(&acc, amount);
    //     coin::deposit(MODULE_ADMIN, coins);
    // }


    /// calculate convertion of purchases wallet to usdc
    // fun convert_purchase_to_stable(acc: signer, amount: u64) {
    //     let coins = coin::withdraw(&acc, amount);
    //     coin::deposit(MODULE_ADMIN, coins);
    // }

    /// move money
    fun mint_and_deposit<T>(acc: signer, amount: u64) {
        let coins = coin::withdraw<T>(&acc, amount);
        coin::deposit(MODULE_ADMIN, coins);
    }
}
