// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


// Always remember the 3 A's when writing unit tests for your Smart Contracts:

// 1. Arrange - Set up the test.
// 2. Act - Perform the action that you want to test.
// 3. Assert - Verify the test.

contract FundMeTest is Test {
 FundMe fundMe;

 address USER = makeAddr("user");
 uint256 constant SEND_VALUE = 0.1 ether;
 uint256 constant STARTING_BALANCE = 10 ether;


function setUp() external {
    // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
    vm.deal(USER, STARTING_BALANCE);
}

function testMinimumDollarIsFive() view public {
    assertEq(fundMe.MINIMUM_USD(), 5e18);
}

function testOwnerIsMsgSender() view public {
    assertEq(fundMe.getOwner(), msg.sender);
}

function testPriceFeedVersionIsAccurate() view public{
    assertEq(fundMe.getVersion(), 4);
}

function testFundFailsWithoutEth() public {
    vm.expectRevert(); //next line should revert
    fundMe.fund();
}

function testFundUpdatesFundedDataStructure() public {
    vm.prank(USER); //next tx will be sent by USER
    fundMe.fund{value: SEND_VALUE}();

    uint256 amountFunded = fundMe.getAdressToAmountFunded(USER);
    assertEq(amountFunded, SEND_VALUE);
}

function testAddsFunderToArrayOfFunders() public{
    vm.prank(USER); //next tx will be sent by USER
    fundMe.fund{value: SEND_VALUE}();

    address funder = fundMe.getFunder(0);
    assertEq(funder, USER);
}

//modifier to help reduce 
modifier funded(){
      vm.prank(USER); 
    fundMe.fund{value: SEND_VALUE}();
    _;
}


function testOnlyOwnerCanWithdraw() public funded {
    vm.prank(USER);
    vm.expectRevert();
    fundMe.withdraw();
}

function testWithdrawWithSingleFunder() public funded {
// Arrange
uint256 startingOwnerBalance = fundMe.getOwner().balance;
uint256 startingFundMeBalance = address(fundMe).balance;

// Act
vm.prank(fundMe.getOwner());
fundMe.withdraw();

// Assert
uint256 endingOwnerBalance = address(fundMe).balance;
uint256 endingFundMeBalance = fundMe.getOwner().balance;
assertEq(endingOwnerBalance, 0);
assertEq(endingFundMeBalance, startingOwnerBalance + startingFundMeBalance);
}

function testWithdrawFromMultipleFunders() public funded {
    //Arrange
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;
    for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
        //vm.prank new add
        //vm.deal new add
        //address
        hoax(address(i), SEND_VALUE);
        fundMe.fund{value: SEND_VALUE}();
    }

    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

    //Act
    vm.startPrank(fundMe.getOwner());
    fundMe.withdraw();
    vm.stopPrank();

    //assert
    uint256 endingOwnerBalance = address(fundMe).balance;
    uint256 endingFundMeBalance = fundMe.getOwner().balance;
    assertEq(endingOwnerBalance, 0);
    assertEq(endingFundMeBalance, startingOwnerBalance + startingFundMeBalance);

}

function testWithdrawFromMultipleFundersCheaper() public funded {
    //Arrange
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;
    for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
        //vm.prank new add
        //vm.deal new add
        //address
        hoax(address(i), SEND_VALUE);
        fundMe.fund{value: SEND_VALUE}();
    }

    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

    //Act
    vm.startPrank(fundMe.getOwner());
    fundMe.withdrawCheaper();
    vm.stopPrank();

    //assert
    uint256 endingOwnerBalance = address(fundMe).balance;
    uint256 endingFundMeBalance = fundMe.getOwner().balance;
    assertEq(endingOwnerBalance, 0);
    assertEq(endingFundMeBalance, startingOwnerBalance + startingFundMeBalance);

}

}
