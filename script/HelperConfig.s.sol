// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { MockV3Aggregator } from "test/mocks/MockV3Aggregator.sol";


contract HelperConfig is Script {
  
  MockV3Aggregator private priceFeed;
  struct NetworkConfig {
    address priceFeed;
  }
  NetworkConfig public activeNetworkConfig;
  uint8 public constant DECIMALS = 8;
  int256 public constant INITIAL_PRICE = 2000e8;
  uint256 public constant SEPOLIA_CHIANID = 11155111;

  constructor() {
    if (block.chainid == SEPOLIA_CHIANID) {
      activeNetworkConfig = getSepoliaNetworkConfig();
    } else {
      activeNetworkConfig = getOrCreateAnvilNetworkConfig();
    }
  }

  function getSepoliaNetworkConfig() private pure returns (NetworkConfig memory) {
    NetworkConfig memory networkConfig = NetworkConfig({
      priceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
    });
    return networkConfig;
  }

  function getOrCreateAnvilNetworkConfig() private returns (NetworkConfig memory) {
    if (address(priceFeed) == address(0)) {
      vm.startBroadcast();
      priceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
      vm.stopBroadcast();
    }

    NetworkConfig memory networkConfig = NetworkConfig({
      priceFeed: address(priceFeed)
    });

    return networkConfig;
  }
}