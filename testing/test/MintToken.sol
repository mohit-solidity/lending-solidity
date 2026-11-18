// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Mint is ERC20{
    constructor() ERC20("TestToken","TST") {}
    function mint(address to, uint amount) public{
        _mint(to, amount);
    }
}