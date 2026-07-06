//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract InteractionTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 0.1 eth
    uint256 constant STARTING_BALANCE = 10 ether; // 10 eth
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMeScript = new FundFundMe();
        fundFundMeScript.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMeScript = new WithdrawFundMe();
        withdrawFundMeScript.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
        // console.log("Amount funded by user: ", fundFundMeScript);
    }
}
