// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {FundMe} from "../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";



contract FundMeTest is StdCheats, Test {
    FundMe public fundMe;
    // uint256 public constant SEND_VALUE = 1e18;
    // uint256 public constant SEND_VALUE = 1_000_000_000_000_000_000;
    // uint256 public constant SEND_VALUE = 1000000000000000000;
    address ALICE = makeAddr("ALICE");
    address BOB = makeAddr("BOB");
    uint256 SEND_VALUE = 10e18;
    uint256 INIT_BALANCE = 10e18;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        vm.deal(ALICE, INIT_BALANCE);
        vm.deal(BOB, INIT_BALANCE);
    }

    modifier funded() {
        vm.prank(ALICE);
        fundMe.fund{value : SEND_VALUE}();
        _;
    }

    function testMinimumDollar() public view {
        uint256 minimumUSD = fundMe.MINIMUM_USD();
        assertEq(minimumUSD, 5e18);
        console.log(minimumUSD);
    }

    function testAddressThisIsOwner() public view {
        address owner = fundMe.getOwner();
        assertEq(owner, msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    function testBlockChainId() public view{
        console.log(block.chainid);
        //assertEq(block.chainid, 1);
    }

    function testFundFailWithoutEnoughETH() public {
        vm.expectRevert();
        // assert this line to be revert
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(ALICE);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        vm.prank(BOB);
        fundMe.fund{value : SEND_VALUE}();
        address funder = fundMe.getFunder(1);
        console.log(funder);
        assertEq(funder, BOB);
    }

    function testWithdrawFail() public funded {
        vm.prank(ALICE);
        vm.expectRevert();
        fundMe.withdraw(); 
    }

    function testWithdraw() public funded {
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
    }

    function testCheaperWithdraw() public funded {
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        console.log(endingFundMeBalance);
        console.log(endingOwnerBalance);
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);

    }

    function testWithdrawFromMultipleFunders() public {
        // Arrange
        // casting uint untuk address harus menggunakan uint160

        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank() dan vm.deal() jika digunakan bersamaan bisa menggunakan vm.hoax()
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value : SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Action
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingFundMeBalance + startingOwnerBalance);
    }

}