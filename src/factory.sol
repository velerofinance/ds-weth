pragma solidity >=0.4.23;

import "./weth9.sol";

contract DSWvlxFactory {
    event LogMake(address indexed creator, address token);

    function make() public returns (WVLX9_ result) {
        result = new WVLX9_();
        emit LogMake(msg.sender, address(result));
    }
}
