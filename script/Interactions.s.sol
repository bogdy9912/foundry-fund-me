// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    function fundFundMe(address lastDeployment, uint256 weiValue) public {
        vm.startBroadcast();
        FundMe(payable(lastDeployment)).fund{value: weiValue}();
        vm.stopBroadcast();
        console.log("Funded with: ", weiValue);
    }

    function run() external {
        address lattesDeploy = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        vm.startBroadcast();
        fundFundMe(lattesDeploy, 0.1 ether);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address latestDeplyment) public {
        uint256 balance = latestDeplyment.balance;
        vm.startBroadcast();
        FundMe(payable(latestDeplyment)).withdraw();
        vm.stopBroadcast();
        console.log("Withdrawed funds: ", balance);
    }

    function run() external {
        address lattestDeploy = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        vm.startBroadcast();
        withdrawFundMe(lattestDeploy);
        vm.stopBroadcast();
    }
}
