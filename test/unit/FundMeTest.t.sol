//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";

// import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    // FundMe fundMe;
    //uint256 number = 1;
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 0.1 eth
    uint256 constant STARTING_BALANCE = 10 ether; // 10 eth

    function setUp() external {
        //  number = 2;
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); //change 1, added price feed address to constructor. change 2: deleted this line and added the following line to use DeployFundMe script to deploy FundMe contract

        //change 3: added this line to use DeployFundMe script to deploy FundMe contract
        DeployFundMe deployFundMe = new DeployFundMe();
        //change 4: added this line to use DeployFundMe script to deploy FundMe contract
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    //forge test --match-test testPriceFeedVersionIsAccurate -vvv (command for running specific test)
    //forge test -vvv (for quick testing command)   )
    function testMiniDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        // console.log(number);
        // console.log("hello world");
        // assertEq(number, 2);
    }

    function testIsMsgSender() public view {
        console.log("msg.sender: ", msg.sender);
        console.log("i_owner: ", fundMe.getOwner());
        assertEq(fundMe.getOwner(), msg.sender);
    }

    //to run following testPriceFeedVersionIsAccurate command in terminal would be:
    //forge test --mt testPriceFeedVersionIsAccurate -vvv --fork-url "https://eth-sepolia.g.alchemy.com/v2/WqRtiH2B0nkAB5ZG4115L"
    //forge coverage --fork-url $SEPOLIA_RPC_URL
    //forge test  testPriceFeedVersionIsAccurate -vvv --fork-url $SEPOLIA_RPC_URL
    function testPriceFeedVersionIsAccurate() public view {
        // console.log("version: ", fundMe.getVersion());
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund{value: 0.0002 ether}();
        // fundMe.fund{value: 0.1 ether}(); //0.1 eth
        // uint256 sendValue = 0.01 ether;
    }

    function testFundUpdateFundedDataStructure() public {
        vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();
        fundMe.fund{value: SEND_VALUE}();
        // fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (
            uint160 i = startingFunderIndex;
            i < numberOfFunders + startingFunderIndex;
            i++
        ) {
            //vm.prank(address(i));
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    function testCheaperWithdrawFromMultipleFunders() public {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (
            uint160 i = startingFunderIndex;
            i < numberOfFunders + startingFunderIndex;
            i++
        ) {
            //vm.prank(address(i));
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
