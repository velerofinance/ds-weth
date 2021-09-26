pragma solidity >=0.4.23;

import "ds-test/test.sol";

import "./weth.sol";
import "./weth9.sol";

contract WVLX9 is WVLX9_ {
    function join() public payable {
        deposit();
    }
    function exit(uint wad) public {
        withdraw(wad);
    }
}

contract WVLX9Test is DSTest, WVLXEvents {
    WVLX9  wvlx;
    Guy   a;
    Guy   b;
    Guy   c;

    function setUp() public {
        wvlx  = this.newWVLX();
        a     = this.newGuy();
        b     = this.newGuy();
        c     = this.newGuy();
    }

    function newWVLX() public returns (WVLX9) {
        return new WVLX9();
    }

    function newGuy() public returns (Guy) {
        return new Guy(wvlx);
    }

    function test_initial_state() public {
        assert_vlx_balance(a, 0 finney);
        assert_wvlx_balance(a, 0 finney);
        assert_vlx_balance(b, 0 finney);
        assert_wvlx_balance(b, 0 finney);
        assert_vlx_balance(c, 0 finney);
        assert_wvlx_balance(c, 0 finney);

        assert_wvlx_supply(0 finney);
    }

    function test_join() public {
        // expectEventsExact    (address(wvlx));

        perform_join         (a, 3 finney);
        assert_wvlx_balance(a, 3 finney);
        assert_wvlx_balance(b, 0 finney);
        assert_vlx_balance(a, 0 finney);
        assert_wvlx_supply(3 finney);

        perform_join         (a, 4 finney);
        assert_wvlx_balance(a, 7 finney);
        assert_wvlx_balance(b, 0 finney);
        assert_vlx_balance(a, 0 finney);
        assert_wvlx_supply(7 finney);

        perform_join         (b, 5 finney);
        assert_wvlx_balance(b, 5 finney);
        assert_wvlx_balance(a, 7 finney);
        assert_wvlx_supply(12 finney);
    }

    function testFail_exital_1() public {
        perform_exit         (a, 1 wei);
    }

    function testFail_exit_2() public {
        perform_join         (a, 1 finney);
        perform_exit         (b, 1 wei);
    }

    function testFail_exit_3() public {
        perform_join         (a, 1 finney);
        perform_join         (b, 1 finney);
        perform_exit         (b, 1 finney);
        perform_exit         (b, 1 wei);
    }

    function test_exit() public {
        // expectEventsExact    (address(wvlx));

        perform_join         (a, 7 finney);
        assert_wvlx_balance(a, 7 finney);
        assert_vlx_balance(a, 0 finney);

        perform_exit         (a, 3 finney);
        assert_wvlx_balance(a, 4 finney);
        assert_vlx_balance(a, 3 finney);

        perform_exit         (a, 4 finney);
        assert_wvlx_balance(a, 0 finney);
        assert_vlx_balance(a, 7 finney);
    }

    function testFail_transfer_1() public {
        perform_transfer     (a, 1 wei, b);
    }

    function testFail_transfer_2() public {
        perform_join         (a, 1 finney);
        perform_exit         (a, 1 finney);
        perform_transfer     (a, 1 wei, b);
    }

    function test_transfer() public {
        // expectEventsExact    (address(wvlx));

        perform_join         (a, 7 finney);
        perform_transfer     (a, 3 finney, b);
        assert_wvlx_balance(a, 4 finney);
        assert_wvlx_balance(b, 3 finney);
        assert_wvlx_supply(7 finney);
    }

    function testFail_transferFrom_1() public {
        perform_transfer     (a,  1 wei, b, c);
    }

    function testFail_transferFrom_2() public {
        perform_join         (a, 7 finney);
        perform_approval     (a, 3 finney, b);
        perform_transfer     (b, 4 finney, a, c);
    }

    function test_transferFrom() public {
        // expectEventsExact    (address(this));

        perform_join         (a, 7 finney);
        perform_approval     (a, 5 finney, b);
        assert_wvlx_balance(a, 7 finney);
        assert_allowance     (b, 5 finney, a);
        assert_wvlx_supply(7 finney);

        perform_transfer     (b, 3 finney, a, c);
        assert_wvlx_balance(a, 4 finney);
        assert_wvlx_balance(b, 0 finney);
        assert_wvlx_balance(c, 3 finney);
        assert_allowance     (b, 2 finney, a);
        assert_wvlx_supply(7 finney);

        perform_transfer     (b, 2 finney, a, c);
        assert_wvlx_balance(a, 2 finney);
        assert_wvlx_balance(b, 0 finney);
        assert_wvlx_balance(c, 5 finney);
        assert_allowance     (b, 0 finney, a);
        assert_wvlx_supply(7 finney);
    }

    //------------------------------------------------------------------
    // Helper functions
    //------------------------------------------------------------------

    function assert_vlx_balance(Guy guy, uint balance) public {
        assertEq(address(guy).balance, balance);
    }

    function assert_wvlx_balance(Guy guy, uint balance) public {
        assertEq(wvlx.balanceOf(address(guy)), balance);
    }

    function assert_wvlx_supply(uint supply) public {
        assertEq(wvlx.totalSupply(), supply);
    }

    function perform_join(Guy guy, uint wad) public {
        emit Join(address(guy), wad);
        guy.join.value(wad)();
    }

    function perform_exit(Guy guy, uint wad) public {
        emit Exit(address(guy), wad);
        guy.exit(wad);
    }

    function perform_transfer(
        Guy src, uint wad, Guy dst
    ) public {
        emit Transfer(address(src), address(dst), wad);
        src.transfer(dst, wad);
    }

    function perform_approval(
        Guy src, uint wad, Guy guy
    ) public {
        emit Approval(address(src), address(guy), wad);
        src.approve(guy, wad);
    }

    function assert_allowance(
        Guy guy, uint wad, Guy src
    ) public {
        assertEq(wvlx.allowance(address(src), address(guy)), wad);
    }

    function perform_transfer(
        Guy guy, uint wad, Guy src, Guy dst
    ) public {
        emit Transfer(address(src), address(dst), wad);
        guy.transfer(src, dst, wad);
    }
}

contract Guy {
    WVLX9 wvlx;

    constructor(WVLX9 _wvlx) public {
        wvlx = _wvlx;
    }

    function join() payable public {
        wvlx.join.value(msg.value)();
    }

    function exit(uint wad) public {
        wvlx.exit(wad);
    }

    function () external payable {
    }

    function transfer(Guy dst, uint wad) public {
        require(wvlx.transfer(address(dst), wad));
    }

    function approve(Guy guy, uint wad) public {
        require(wvlx.approve(address(guy), wad));
    }

    function transfer(Guy src, Guy dst, uint wad) public {
        require(wvlx.transferFrom(address(src), address(dst), wad));
    }
}
