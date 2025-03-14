// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

/**
 * @title 具体某个合约的测试脚本
 * @author 作者名
 * @notice 与最近部署的合约进行交互
 */
contract FundFundMe is Script {
    uint256 SEND_VALUE = 0.1 ether; // 定义发送的以太币数量为0.1 ether

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast(); // 开始广播交易
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}(); // 调用最近部署的FundMe合约的fund方法，并发送以太币
        vm.stopBroadcast(); // 停止广播交易
        console.log("Funded FundMe with %s", SEND_VALUE); // 打印发送的以太币数量
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid); // 获取最近部署的FundMe合约地址
        fundFundMe(mostRecentlyDeployed); // 调用fundFundMe方法，与最近部署的合约进行交互
    }
}

/**
 * @title 提现FundMe
 * @author 
 * @notice 
 */
// @title 提现FundMe脚本
// @dev 该合约允许从已部署的FundMe合约中提现资金。
// @notice 该脚本与最近部署的FundMe合约进行交互以提现资金。
contract WithdrawFundMe is Script {

    // @notice 从指定的FundMe合约中提现资金。
    // @param mostRecentlyDeployed 最近部署的FundMe合约的地址。
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast(); // 开始广播交易
        FundMe(payable(mostRecentlyDeployed)).withdraw(); // 调用最近部署的FundMe合约的withdraw方法
        vm.stopBroadcast(); // 停止广播交易
        console.log("Withdraw FundMe balance!"); // 打印提现信息
    }

    // @notice 执行脚本从最近部署的FundMe合约中提现资金。
    // @dev 使用DevOpsTools获取最近部署的FundMe合约地址并调用withdrawFundMe方法。
    function run() external {     
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid); // 获取最近部署的FundMe合约地址
        withdrawFundMe(mostRecentlyDeployed); // 调用withdrawFundMe方法，与最近部署的合约进行交互
    }
}