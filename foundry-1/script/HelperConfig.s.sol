// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Script,console} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../src/mocks/MockV3Aggregator.sol";
/**
 * @title 配置
 * @author 
 * @notice 根据不同的链获取不同的配置
 */
contract HelperConfig is Script{
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed; 
    }

    constructor() {
        if(block.chainid == 11155111) {
            console.log("SepoliaEth");
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            console.log("AnvilEth");
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
        return NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    /**
     * @notice 获取或创建AnvilEth配置
     * 实际上在Anvil上部署和测试 gas 费用为 0
     * 
     */
    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory) {
        //如果已经存在priceFeed地址，则直接返回
        if(activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        // 如果不存在，则创建一个新的
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        vm.stopBroadcast();
        
        NetworkConfig memory envilEthConfig = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return envilEthConfig;
    }
}