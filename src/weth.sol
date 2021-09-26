pragma solidity >=0.4.23;

import "erc20/erc20.sol";

contract WVLXEvents is ERC20Events {
    event Join(address indexed dst, uint wad);
    event Exit(address indexed src, uint wad);
}

contract WVLX is ERC20, WVLXEvents {
    function join() public payable;
    function exit(uint wad) public;
}
