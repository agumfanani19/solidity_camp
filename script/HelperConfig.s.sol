// SPDX-License-Identifier: MIT


// Deploy mocks ketika kita ada di local anvil chain
// - karena jika tidak didefinisikan rpc url nya akan menggunakan 
//   chain default yaitu local anvil chain.
// Terus lacak alamat kontrak untuk chain yang berbeda

// Sepolia ETH/USD
// Mainnet ETH/USD

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // jika di lokal chain, maka deplo ycode
    // jika tidak, maka ambil alamat dari live networks
    NetworkConfig public activeNetworkConfig;
    struct NetworkConfig{
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111){ //chain id itu setiap block chain, dalam kasus ini adalah sepolia 
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory sepoliaConfig = (NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        }));
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        NetworkConfig memory mainnetConfig = (NetworkConfig({
            priceFeed: 0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46
        }));
        return mainnetConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory){
        // 1. Deploy mocks contract - dummy contract / kontrak palsu
        // 2. Return the mock address
        
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }

}