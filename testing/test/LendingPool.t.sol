// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {LendingPool} from "../src/LendingPool.sol";
import "forge-std/console.sol";
import {Mint} from "./MintToken.sol";


contract LendingPoolTest is Test {
    LendingPool public lp;
    Mint public mints;

    address owner = address(this);
    address user = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);

    function setUp() public {
        lp = new LendingPool();
        mints = new Mint();
        lp.addToken(address(mints));
    }

    function testFuzz_UserDepositETH(uint _amount) public{
        vm.assume(_amount>1);
        vm.deal(user, _amount);
        vm.expectEmit(true, true, false, true, address(lp));
        emit LendingPool.TokenDeposited(user, address(0), _amount);
        vm.prank(user);
        lp.depositETH{value : _amount}();
        uint deposits = lp.deposits(user,address(0));
        uint TotalDepositForToken = lp.totalDeposits(address(0));
        assertEq(deposits, _amount);
        assertEq(TotalDepositForToken, deposits);
        console.log(deposits);
        console.log(TotalDepositForToken);
    }
    function testFuzz_UserDepositAnotherToken(uint _amount) public{
        mints = new Mint();
        lp.addToken(address(mints));
        vm.assume(_amount>0);
        _amount = bound(_amount, 1, 1000000000);
        mints.mint(user,_amount);
        vm.prank(user);
        mints.approve(address(lp),_amount);
        vm.expectEmit(true, true, false, true);
        emit LendingPool.TokenDeposited(user,address(mints),_amount);
        vm.prank(user);
        lp.depositToken(address(mints), _amount);
        uint tokensInUserAccount = lp.deposits(user,address(mints));
        console.log(tokensInUserAccount);
        assertEq(tokensInUserAccount, _amount);
        uint totalDeposits = lp.totalDeposits(address(mints));
        console.log(totalDeposits);
        assertEq(totalDeposits,_amount);
    }
    function testFuzz_UserWithdrawETH(uint _amount) public{
        vm.assume(_amount>0);
        vm.deal(user, _amount);
        vm.prank(user);
        lp.depositETH{value:_amount}();
        uint deposit = lp.deposits(user,address(0));
        console.log("Initial deposit : ",deposit);
        vm.expectEmit(true, true, false, true);
        emit LendingPool.TokenWithdrawed(user, address(0),_amount);
        vm.prank(user);
        lp.withdrawETH(_amount);
        deposit = lp.deposits(user,address(0));
        console.log("After Withdrawing Deposit : ", deposit);
    }
    function testFuzz_UserWithdrawTokens(uint _amount) public {
        // Token Approving And Depositing
        mints = new Mint();
        lp.addToken(address(mints));
        vm.assume(_amount>0);
        _amount = bound(_amount, 1, 1000000000);
        mints.mint(user,_amount);
        vm.prank(user);
        mints.approve(address(lp),_amount);
        vm.expectEmit(true, true, false, true);
        emit LendingPool.TokenDeposited(user,address(mints),_amount);
        vm.prank(user);
        lp.depositToken(address(mints), _amount);

        // Token Withdrawing
        uint totalTokens = lp.deposits(user,address(mints));
        console.log("Total Tokens : ", totalTokens);
        vm.expectEmit(true, true, false, true);
        emit LendingPool.TokenWithdrawed(user,address(mints),_amount);
        vm.prank(user);
        lp.withdrawToken(address(mints), _amount);
        totalTokens = lp.deposits(user,address(mints));
        assertEq(totalTokens, 0);
        uint totalTokensBalance = lp.totalDeposits(address(mints));
        assertEq(totalTokensBalance, 0);
    }
}
