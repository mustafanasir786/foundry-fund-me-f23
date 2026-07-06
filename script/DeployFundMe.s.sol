//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        //change 2, added price feed address to constructor
        HelperConfig helperConfig = new HelperConfig();
        address priceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        //FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); //change 1, added price feed address to constructor, change 3: FundMe fundMe
        //FundMe fundMe = new FundMe(HelperConfig(msg.sender).activeNetworkConfig().priceFeed);
        FundMe fundMe = new FundMe(priceFeed);

        vm.stopBroadcast();
        return fundMe;
    }
}
