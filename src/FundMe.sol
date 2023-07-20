// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { PriceConverter } from './PriceConverter.sol';
import { ArrayFns } from './ArrayFns.sol';

error NotOwner();
error WithdrawFailOnTransfer();

contract FundMe {
  using PriceConverter for uint256;
  using ArrayFns for address[];
  address private immutable owner;
  address private immutable priceFeed;

  uint private constant MINIMUM_DONATION_IN_USD = 5 * 10e18;
  mapping(address sender => uint256 amount) private funds;
  address[] private funders;

  constructor(address _priceFeed) {
    owner = msg.sender;
    priceFeed = _priceFeed;
  }

  receive() external payable{
    fundMe();
  }

  fallback() external payable{
    fundMe();
  }

  function fundMe() public payable {
    // check if its gte 5 dollars
    // -- convert wei to eth
    // take money from sender and save it in contract
    // make the contract money not locked
    uint256 donationInUSD = msg.value.calcDonationAmount(priceFeed);
    require(donationInUSD >= MINIMUM_DONATION_IN_USD, "Please! Donate at least 5 dollars worth of Eth");

    if (funders.has(msg.sender) == false) {
      funders.push(msg.sender);
    }
    funds[msg.sender] += msg.value;
  }

  function withdraw() public payable onlyOwner {
    uint totalFunders = funders.length;
    for (uint128 i=0; i<totalFunders; i++) {
      address funder = funders[i];
      funds[funder] = 0;
    }
    funders = new address[](0);
    // send money locked in contract to msg.sender
    // payable(msg.sender).transfer(address(this).balance); // can also send it this way
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    if (success == false) {
      revert WithdrawFailOnTransfer();
    }
  }

  function getFundedAmount(address funder) public view returns (uint256) {
    return funds[funder];
  }

  function getOwner() public view returns(address) {
    return owner;
  }

  modifier onlyOwner {
    if (msg.sender != owner) {
      revert NotOwner();
    }
    _;
  }
}