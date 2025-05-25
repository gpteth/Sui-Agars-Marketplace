#[test_only]
module agar_betting::simple_test {
    use sui::test_scenario;
    use sui::coin;
    use sui::sui::SUI;
    use agar_betting::betting;
    use std::debug;

    const ADMIN: address = @0x01;
    const PLAYER: address = @0x02;

    #[test]
    fun test_game_creation_and_betting() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // 管理员创建游戏
        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let coin = coin::mint_for_testing<SUI>(1000000, ctx);
            betting::create_game(coin, ctx);
        };
        
        // 玩家下注
        test_scenario::next_tx(&mut scenario, PLAYER);
        {
            let mut game = test_scenario::take_from_address<betting::Game>(&scenario, ADMIN);
            let ctx = test_scenario::ctx(&mut scenario);
            let mut coin = coin::mint_for_testing<SUI>(100000, ctx);
            
            // 验证初始资金池
            let initial_pool = betting::get_pool_value(&game);
            debug::print(&b"Initial pool:");
            debug::print(&initial_pool);
            
            // 对玩家1下注50000
            betting::place_bet(&mut game, 1, 50000, &mut coin, ctx);
            
            // 验证资金池增加
            let new_pool = betting::get_pool_value(&game);
            debug::print(&b"New pool:");
            debug::print(&new_pool);
            assert!(new_pool == initial_pool + 50000, 1);
            
            // 验证玩家1的赔率
            let odds1 = betting::get_odds(&game, 1);
            debug::print(&b"Player 1 odds:");
            debug::print(&odds1);
            assert!(odds1 > 0, 2);
            
            test_scenario::return_to_address(ADMIN, game);
            // 转移剩余的coin而不是销毁
            betting::transfer_coin(coin, PLAYER);
        };
        
        test_scenario::end(scenario);
    }
} 