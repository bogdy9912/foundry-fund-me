// SPDX-License_Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script{
    function run() public returns(FundMe fundMe){
        HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        fundMe = new FundMe(AggregatorV3Interface(helperConfig.activeNetworkConfig()));
        vm.stopBroadcast();
    }
}

