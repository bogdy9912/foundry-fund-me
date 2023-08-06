// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;
    DeployFundMe public deployer;

    address USER = makeAddr("user");
    address ALICE = makeAddr("alice");
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(USER, STARTING_BALANCE);
        vm.deal(ALICE, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerisMsgSender() public {
        assertEq(fundMe.i_owner(), msg.sender);
        // assertEq(fundMe.i_owner(), address(this));
        // console.log(address(deployer));
        // console.log(msg.sender);
        // console.log(address(this));
        // assertEq(fundMe.i_owner(), address(deployer));
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughtEth() public {
        vm.expectRevert("You need to spend more ETH!");
        fundMe.fund{value: 1}();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();

        assertEq(fundMe.addressToAmountFunded(USER), 10e18);
        assertEq(fundMe.funders(0), USER);

        assertFalse(fundMe.funders(0) == ALICE);
    }

    modifier userFund() {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();

        assertEq(fundMe.addressToAmountFunded(USER), 10e18);
        assertEq(fundMe.funders(0), USER);
        _;
    }

    function testOnlyOwnerWithdraw() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();

        vm.prank(ALICE);
        fundMe.fund{value: 10e18}();

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
        address[] memory funders = fundMe.fundersArray();

        assertEq(funders.length, 2);
    }

    function testWithdraw() public {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();

        vm.prank(ALICE);
        fundMe.fund{value: 10e18}();

        uint256 ownerBalance = fundMe.i_owner().balance;
        uint256 fundMeBalance = address(fundMe).balance;

        assertEq(fundMeBalance, 2* 10e18);

        vm.prank(msg.sender);
        // vm.prank(fundMe.i_owner()); // same as above

        fundMe.withdraw();
        address[] memory funders = fundMe.fundersArray();

        assertEq(funders.length, 0);
        assertEq(address(fundMe).balance, 0);
        assertEq(ownerBalance + 10e18 * 2, fundMe.i_owner().balance);
    }

    function testFallback() public {}
}
