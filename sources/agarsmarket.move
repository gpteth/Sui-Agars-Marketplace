
module agarsmarket::agarsmarket {
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::transfer_policy::TransferPolicy;
    use sui::coin::Coin;
    use sui::sui::SUI;

    // seller functions
    // create new marketplace
    entry fun create_agar_marketplace(ctx: &mut TxContext) {
        let (kiosk, cap) = kiosk::new(ctx);
        let sender = tx_context::sender(ctx);
        transfer::public_share_object(kiosk);
        transfer::public_transfer(cap, sender);
    }

    // Verify ownership of the kiosk
    fun verify_kiosk_ownership(_kiosk: &Kiosk, _cap: &KioskOwnerCap, _sender: address): bool {
        true
    }

    // place a agar
    public fun place_agar<T: key + store>(kiosk: &mut Kiosk, cap: &KioskOwnerCap, agar: T) {
        kiosk::place(kiosk, cap, agar);
    }

    // unplace a agar
    public fun unplace_agar<T: key + store>(kiosk: &mut Kiosk, cap: &KioskOwnerCap, item_id: object::ID): T {
        kiosk::take<T>(kiosk, cap, item_id)
    }

    // list a agar
    public fun list_agar<T: key + store>(kiosk: &mut Kiosk, cap: &KioskOwnerCap, skin_id: object::ID, price: u64) {
        kiosk::list<T>(kiosk, cap, skin_id, price);
    }

    // delist a agar
    public fun delist_agar<T: key + store>(kiosk: &mut Kiosk, cap: &KioskOwnerCap, skin_id: object::ID) {
        kiosk::delist<T>(kiosk, cap, skin_id);
    }

    // lock a agar
    public fun lock_agar<T: key + store>(kiosk: &mut Kiosk, cap: &KioskOwnerCap, policy: &TransferPolicy<T>, agar: T) {
        kiosk::lock(kiosk, cap, policy, agar);
    }

    // withdraw kiosk profits
    public fun withdraw_profits(kiosk: &mut Kiosk, cap: &KioskOwnerCap, amount: Option<u64>, ctx: &mut TxContext): Coin<SUI> {
        kiosk::withdraw(kiosk, cap, amount, ctx)
    }

    // buyer functions
    // purchase a agar
    public fun purchase_agar<T: key + store>(kiosk: &mut Kiosk, item_id: object::ID, payment: Coin<SUI>): (T, sui::transfer_policy::TransferRequest<T>) {
        kiosk::purchase<T>(kiosk, item_id, payment)
    }
}

