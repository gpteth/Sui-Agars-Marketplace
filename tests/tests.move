#[test_only]
module agar_betting::betting_tests {
    use sui::test_scenario;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use agar_betting::betting::{Self};
    use std::debug;

    const ADMIN: address = @0x01;
    const PLAYER1: address = @0x02;
    const PLAYER2: address = @0x03;
    const PLAYER3: address = @0x04;

    #[test]
    fun test_init_game() {
        let mut scenario = test_scenario::begin(ADMIN);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let coin = coin::mint_for_testing<SUI>(1000000, ctx);
            let game = betting::init_game(coin, ctx);
            
            // 验证游戏已正确初始化
            assert!(betting::get_pool_value(&game) == 1000000, 0);
            
            // 验证赔率已正确计算
            let odds1 = betting::get_odds(&game, 1);
            let odds2 = betting::get_odds(&game, 2);
            debug::print(&odds1);
            debug::print(&odds2);
            
            betting::transfer_game(game, ADMIN);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_place_single_bet() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // 管理员创建游戏
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let coin = coin::mint_for_testing<SUI>(1000000, ctx);
            betting::create_game(coin, ctx);
        };

        // 玩家1下注
        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_from_address<betting::Game>(&scenario, ADMIN);
            let ctx = test_scenario::ctx(&mut scenario);
            let mut coin = coin::mint_for_testing<SUI>(100000, ctx);
            
            // 对玩家1下注50000
            betting::place_bet(&mut game, 1, 50000, &mut coin, ctx);
            
            // 验证资金池增加
            assert!(betting::get_pool_value(&game) == 1050000, 1);
            
            test_scenario::return_to_address(ADMIN, game);
            betting::transfer_coin(coin, PLAYER1);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_multiple_bets() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // 管理员创建游戏
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let coin = coin::mint_for_testing<SUI>(1000000, ctx);
            betting::create_game(coin, ctx);
        };

        // 玩家1下注
        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_from_address<betting::Game>(&scenario, ADMIN);
            let ctx = test_scenario::ctx(&mut scenario);
            let mut coin = coin::mint_for_testing<SUI>(200000, ctx);
            
            // 对玩家1下注50000
            betting::place_bet(&mut game, 1, 50000, &mut coin, ctx);
            // 对玩家3下注30000
            betting::place_bet(&mut game, 3, 30000, &mut coin, ctx);
            
            test_scenario::return_to_address(ADMIN, game);
            betting::transfer_coin(coin, PLAYER1);
        };

        // 玩家2下注
        test_scenario::next_tx(&mut scenario, PLAYER2);
        {
            let mut game = test_scenario::take_from_address<betting::Game>(&scenario, ADMIN);
            let ctx = test_scenario::ctx(&mut scenario);
            let mut coin = coin::mint_for_testing<SUI>(150000, ctx);
            
            // 对玩家1下注100000
            betting::place_bet(&mut game, 1, 100000, &mut coin, ctx);
            
            // 验证资金池总额
            assert!(betting::get_pool_value(&game) == 1180000, 2);
            
            test_scenario::return_to_address(ADMIN, game);
            betting::transfer_coin(coin, PLAYER2);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_end_game_with_payouts() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // 管理员创建游戏
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let coin = coin::mint_for_testing<SUI>(1000000, ctx);
            betting::create_game(coin, ctx);
        };

        // 玩家1下注
        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_from_address<betting::Game>(&scenario, ADMIN);
            let ctx = test_scenario::ctx(&mut scenario);
            let mut coin = coin::mint_for_testing<SUI>(100000, ctx);
            
            betting::place_bet(&mut game, 1, 50000, &mut coin, ctx);
            
            test_scenario::return_to_address(ADMIN, game);
            betting::transfer_coin(coin, PLAYER1);
        };

        // 玩家2下注
        test_scenario::next_tx(&mut scenario, PLAYER2);
        {
            let mut game = test_scenario::take_from_address<betting::Game>(&scenario, ADMIN);
            let ctx = test_scenario::ctx(&mut scenario);
            let mut coin = coin::mint_for_testing<SUI>(100000, ctx);
            
            betting::place_bet(&mut game, 2, 60000, &mut coin, ctx);
            
            test_scenario::return_to_address(ADMIN, game);
            betting::transfer_coin(coin, PLAYER2);
        };

        // 结束游戏，玩家1获胜
        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let mut game = test_scenario::take_from_sender<betting::Game>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            
            betting::end_game(&mut game, 1, ctx);
            
            test_scenario::return_to_sender(&scenario, game);
        };

        // 验证玩家1收到奖励
        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let coin = test_scenario::take_from_sender<Coin<SUI>>(&scenario);
            debug::print(&coin::value(&coin));
            assert!(coin::value(&coin) > 50000, 3); // 应该收到比下注金额更多的奖励
            test_scenario::return_to_sender(&scenario, coin);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 0x1)]
    fun test_bet_on_inactive_game() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // 管理员创建游戏
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let coin = coin::mint_for_testing<SUI>(1000000, ctx);
            betting::create_game(coin, ctx);
        };

        // 结束游戏
        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let mut game = test_scenario::take_from_sender<betting::Game>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            
            betting::end_game(&mut game, 1, ctx);
            
            test_scenario::return_to_sender(&scenario, game);
        };

        // 尝试在已结束的游戏上下注（应该失败）
        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_from_address<betting::Game>(&scenario, ADMIN);
            let ctx = test_scenario::ctx(&mut scenario);
            let mut coin = coin::mint_for_testing<SUI>(50000, ctx);
            
            betting::place_bet(&mut game, 1, 50000, &mut coin, ctx);
            
            test_scenario::return_to_address(ADMIN, game);
            betting::transfer_coin(coin, PLAYER1);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 0x2)]
    fun test_invalid_player_id() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // 管理员创建游戏
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let coin = coin::mint_for_testing<SUI>(1000000, ctx);
            betting::create_game(coin, ctx);
        };

        // 尝试对无效的玩家ID下注
        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_from_address<betting::Game>(&scenario, ADMIN);
            let ctx = test_scenario::ctx(&mut scenario);
            let mut coin = coin::mint_for_testing<SUI>(50000, ctx);
            
            betting::place_bet(&mut game, 9, 50000, &mut coin, ctx); // 玩家ID 9 无效
            
            test_scenario::return_to_address(ADMIN, game);
            betting::transfer_coin(coin, PLAYER1);
        };
        test_scenario::end(scenario);
    }
}
