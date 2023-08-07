// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
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

    function testUserCanFund() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe), 0.1 ether);

        assertEq(fundMe.addressToAmountFunded(msg.sender), 0.1 ether);
    }

    function testWithdrawFundMe() public {
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        fundMe.fund{value: 1 ether}();

        uint256 ownerBalance = fundMe.i_owner().balance;

        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(ownerBalance + 1 ether, fundMe.i_owner().balance);
    }

    function testInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe), 0.1 ether);

        assertEq(fundMe.addressToAmountFunded(msg.sender), 0.1 ether);

        uint256 ownerBalance = fundMe.i_owner().balance;

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();

        withdrawFundMe.withdrawFundMe(address(fundMe));

        assertEq(ownerBalance + 0.1 ether, fundMe.i_owner().balance);
    }
}
