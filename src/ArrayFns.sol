// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

library ArrayFns {
  function has(address[] memory addresses, address addr) public pure returns(bool) {
    bool hasAddr = false;

    for (uint128 i = 0; i < addresses.length; i++) {
      if (addresses[i] == addr) {
        hasAddr = true;
      }
    }

    return hasAddr;
  }

}