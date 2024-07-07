// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "../forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe)  {
        //b4 startbroadcast => not a real tx
        HelperConfig helperCpnfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperCpnfig.activeNetworkConfig();
        
        //is there are multiple return values in struct
        // (address ethUsdPriceFeed, uint256 version, address example) = helperCpnfig.activeNetworkConfig();

        //after broadcast => real tx
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed );
        vm.stopBroadcast();
        return fundMe;
    }

}