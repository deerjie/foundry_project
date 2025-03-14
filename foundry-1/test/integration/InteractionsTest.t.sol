// SPDX-License-Identifier: MIT
// 指定代码的许可证类型为MIT

pragma solidity ^0.8.0;
// 声明Solidity编译器版本为0.8.0或更高版本

// 导入部署FundMe合约的脚本
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
// 导入用于资金注入和提取的交互脚本
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
// 导入主要的FundMe合约
import {FundMe} from "../../src/FundMe.sol";
// 导入Forge测试框架和控制台日志功能
import {Test, console} from "forge-std/Test.sol";

// 定义一个继承自Test的测试合约
contract InteractionsTest is Test {
    // 声明一个公共的FundMe合约实例
    FundMe public fundMe;
    // 声明一个DeployFundMe脚本实例
    DeployFundMe deployFundMe;

    // 定义一个常量，表示测试中发送的以太币数量为0.1
    uint256 public constant SEND_VALUE = 0.1 ether;
    // 定义一个常量，表示测试用户的初始余额为10以太币
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    // 创建一个名为alice的测试地址
    address alice = makeAddr("alice");


    // 测试前的设置函数
    function setUp() external {
        // 创建一个新的DeployFundMe实例
        deployFundMe = new DeployFundMe();
        // 运行部署脚本并获取部署的FundMe合约实例
        fundMe = deployFundMe.run();
        // 给alice地址分配初始余额
        vm.deal(alice, STARTING_USER_BALANCE);
    }

    // 测试用户可以注资且所有者可以提取资金的功能
    function testUserCanFundAndOwnerWithdraw() public {
        // 记录alice的初始余额
        uint256 preUserBalance = address(alice).balance;
        // 记录合约所有者的初始余额
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        // 使用vm.prank模拟alice地址发送交易
        vm.prank(alice);
        // 从alice地址向FundMe合约发送0.1以太币
        fundMe.fund{value: SEND_VALUE}();

        // script中创建的单个合约测试脚本实例子，如果有其他的也可以在其中调用，然后进行一个整体的集成测试（这里是创建一个新的WithdrawFundMe脚本实例）
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        // 调用脚本从FundMe合约中提取所有资金
        withdrawFundMe.withdrawFundMe(address(fundMe));

        // 记录交易后alice的余额
        uint256 afterUserBalance = address(alice).balance;
        // 记录交易后合约所有者的余额
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        // 断言FundMe合约余额为0，确保所有资金都被提取
        assert(address(fundMe).balance == 0);
        // 断言alice的余额减少了发送的金额
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        // 断言所有者的余额增加了相同的金额
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }

}