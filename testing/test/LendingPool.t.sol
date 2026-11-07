// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {LendingPool} from "../src/LendingPool.sol";
import "forge-std/console.sol";


contract LendingPoolTest is Test {
    LendingPool public lp;
    address owner = address(this);
    address user1 = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);

    function setUp() public {
        lp = new LendingPool();
    }

    function testFuzz_UserDepositETH(uint _amount) public{
        vm.assume(_amount>1);
        vm.deal(user1, _amount);
        vm.expectEmit(true, true, false, true, address(lp));
        emit LendingPool.TokenDeposited(user1, address(0), _amount);
        vm.prank(user1);
        lp.depositETH{value : _amount}();
        uint deposits = lp.deposits(user1,address(0));
        uint TotalDepositForToken = lp.totalDeposits(address(0));
        assertEq(deposits, _amount);
        assertEq(TotalDepositForToken, deposits);
        console.log(deposits);
        console.log(TotalDepositForToken);
    }
}
