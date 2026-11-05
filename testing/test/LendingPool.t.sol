// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {LendingPool} from "../src/LendingPool.sol";

contract LendingPoolTest is Test {
    LendingPool public lp;
    address owner = address(this);
    address user1 = address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);

    function setUp() public {
        lp = new LendingPool();
    }

    function test_CheckRunning() public {
        assertEq(lp.owner(), owner);
    }
}
