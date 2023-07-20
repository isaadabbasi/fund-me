// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { console } from "forge-std/console.sol";
import { AggregatorV3Interface } from "@lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
  function getEthPriceInUSD(address priceFeed) view public returns (uint256) {
    (,int256 price,,,) = AggregatorV3Interface(priceFeed).latestRoundData();
    return uint256(price * 1e10);
  }

  function calcDonationAmount(uint256 ethAmount, address priceFeed) public view returns(uint256) {
    uint256 ethAmountInUSD = getEthPriceInUSD(priceFeed);
    return (ethAmountInUSD * ethAmount)/1e18;
  }
}