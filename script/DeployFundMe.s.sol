// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // tempatkan sebelum startBroadcast karena tidak perlu digunakan untuk transaksi real
        // sehingga dapat menghemat gas deployment
        HelperConfig helperConfig = new HelperConfig();
        // bisa dituliskan seperti dibawah, jika ada beberpaa address
        // (address ethUsdPriceFeed, address ...) = helperConfig.activeNetworkConfig();
        address priceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();

        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}