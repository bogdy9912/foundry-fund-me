// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 200e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = createAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig()
        public
        pure
        returns (NetworkConfig memory config)
    {
        config = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function createAnvilEthConfig()
        public
        returns (NetworkConfig memory config)
    {
        // 1. deploy the mocks
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );

        vm.stopBroadcast();

        // return the mock
        config = NetworkConfig({priceFeed: address(mockV3Aggregator)});
    }
}
