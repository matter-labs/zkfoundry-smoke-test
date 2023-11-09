// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

contract Counter {
    uint256 public number = 0;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        console.log("increment");
        number += 1;
    }
}

contract CounterTest is Test {
    Counter counter;

    function setUp() public {
        counter = new Counter();
    }

    function test_Increment() public {
        counter.increment();
        if (counter.number() == 1) {
            console.log("[INT-TEST] PASS");
        } else {
            console.log("[INT-TEST] FAIL");
        }
    }
}
