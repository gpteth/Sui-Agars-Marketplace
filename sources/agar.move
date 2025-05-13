module agar::agar {
    use std::string::{Self, String};
    use sui::event;

    // skin struct
    public struct Agar has key, store {
        id: UID,
        owner: address,
        author: String,
        title: String,
        category: String,
        story: String,
    }

    // events
    public struct AgarCreated has copy, drop {
        agar_id: ID,
        author: address,
    }

    // mint agar
    public entry fun mint_agar (
        author: vector<u8>,
        title: vector<u8>,
        category: vector<u8>,
        story: vector<u8>,   
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let agar = Agar {
            id: object::new(ctx),
            owner: sender,
            author: string::utf8(author),
            title: string::utf8(title),
            category: string::utf8(category),
            story: string::utf8(story),
        };

        event::emit(AgarCreated {
            agar_id: object::id(&agar),
            author: sender,
        });

        transfer::public_transfer(agar, sender);
    }
}
