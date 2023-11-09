// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";

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

