// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test, console } from 'forge-std/Test.sol';
import { DeployFundMe } from '@script/DeployFundMe.s.sol';
import { FundMe } from '@src/FundMe.sol';


contract FundMeTest is Test {
  address ALICE = makeAddr("1");
  uint256 constant STARTING_BALANCE = 100 ether; 
  
  DeployFundMe private fundMeDeployer;
  FundMe private fundMe;

  function setUp() external {
    fundMeDeployer = new DeployFundMe();
    fundMe = fundMeDeployer.run();
    vm.deal(ALICE, STARTING_BALANCE); // we can also use haox, haox = makeAddr + deal + prank
  }

  function testOwner() public view {
    address owner = fundMe.getOwner();
    assert(owner == msg.sender);
  }
  
  function testValidDonationAmount() public {
    fundMe.fundMe{ value: 0.1 ether }();
  }

  function testCallbackRedirectsToFundMe() public {
    vm.prank(ALICE);
    // transfer money to fund me contract
    (bool success, ) = payable(address(fundMe)).call{value: 1 ether}("");
    if (success) {
      assert(address(fundMe).balance == 1 ether);
      assert(address(ALICE).balance == (STARTING_BALANCE - 1 ether));
      uint256 aliceFunded = fundMe.getFundedAmount(ALICE);
      assert(aliceFunded == 1 ether);
    }
  }

  function testFundMeCrash() public {
    // expect it to crash when not sent enough ether
    vm.prank(ALICE);
    // transfer lesser money to fund me contract
    vm.expectRevert();
    fundMe.fundMe{ value: 0.001 ether }(); // 0.001 * 2000 = $2 = too less
  }

  function testOnlyOwnerCanWithdraw() public {
    
    uint256 ownerStartingBalance = address(msg.sender).balance;

    vm.prank(ALICE);
    fundMe.fundMe{ value: 1 ether }();

    vm.prank(ALICE);
    vm.expectRevert();
    fundMe.withdraw(); // expecting a revert cause ALICE is not owner

    vm.prank(msg.sender);
    fundMe.withdraw(); // shouldd not revert now cause msg.sender is the owner

    // the sender should have one more eth now that ALICE sent as donation.
    assertEq(address(msg.sender).balance, ownerStartingBalance + 1 ether);
  }

}
