//SPDX-License-Identifier: MIT

//helper Mock when are on local chain and we want to test our contract with a mock price feed
// Keep the track of contracts address across different chains
// Sepolia ETH/USD price feed address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
// Mainnet ETH/USD price feed address: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b841
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/mocksV3aggregator.sol";

contract HelperConfig is Script {
    // if are on a local anvil chain, we want to deploy mocks
    // otherwise, grab the existing address from the live network

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; //first change, added priceFeed variable to the struct
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 31337) {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            revert("Network not supported");
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //need price feed address for Sepolia ETH/USD price feed address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        return NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        //price feed address for Anvil
        //1. Deply the Mocks
        //2. Return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
    }
}
