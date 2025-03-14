// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
/**
 * @title 合约测试
 * @author jay
 * @notice 测试fundme合约
 */
contract FundMeTest is Test{
    address USER = makeAddr("user");
    FundMe fundMeInstance;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant START_BANLANCE = 10 ether; //账户user的余额
    uint256 constant GAS_PRICE =  1;

    // 部署合约
    function setUp() external {
        //部署方式一
        // fundMeInstance = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // 部署方式二
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMeInstance = deployFundMe.run();
        vm.deal(USER, START_BANLANCE); // 给用户提供虚假的10个eth
    }

    // 测试起步价格是否低于5美元
    function testMinimumDollarIsFive() public view{
        //日志打印 打印日志的方式执行：forge test -vv
        console.log("testMinimumDollarIsFive");
        assertEq(fundMeInstance.MINIMUM_USD(), 5e18);
    }

    //测试发送者是否是所有者
    function testOwnerIsSender() public view{
        assertEq(fundMeInstance.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public view{
        uint256 version = fundMeInstance.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEt() public {
        vm.expectRevert();// vm.expectRevert();//如果下面的代码执行成功，则测试"FAIL"，如果失败，则测试"PASS"
        fundMeInstance.fund();
    }

    /**
     * 测试资金更新资金数据是否成功
     */
    function testFundUpdatesFundedDatastructure() public {
        vm.prank(USER);//下一个交易将会通过USER发送
        fundMeInstance.fund{value: SEND_VALUE}();
        uint256 amount = fundMeInstance.getAddressToAmountFunded(USER);
        assertEq(amount, SEND_VALUE);
    }

    /**
     * 测试添加资助者到资助者数组
     */
    function testAddFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMeInstance.fund{value: SEND_VALUE}();
        address funder = fundMeInstance.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        fundMeInstance.fund{value: SEND_VALUE}();

        vm.prank(USER);
        vm.expectRevert();
        fundMeInstance.withdraw();
    }

    modifier funded() {
        vm.txGasPrice(GAS_PRICE); //模拟消耗gas费
        vm.prank(USER);
        fundMeInstance.fund{value: SEND_VALUE}();
        _;
    }

    /**
     * 测试单个资助者提取资金
     */
    function testWithDrawWithSingleFunder() public funded {
        //合约所有者的余额
        uint256 startingOwnerBalance =  fundMeInstance.getOwner().balance;
        //合约的余额
        uint256 startingFundMeBalance = address(fundMeInstance).balance;

        //提取资金
        uint256 gasStart = gasleft();
        vm.prank(fundMeInstance.getOwner());
        fundMeInstance.withdraw();
        uint256 gasEnd = gasleft();
        console.log("gas used: ", gasStart - gasEnd); //gas消耗·

        uint256 endOwnerBalance = fundMeInstance.getOwner().balance;
        uint256 endFundMeBalance = address(fundMeInstance).balance;
        assertEq(endFundMeBalance, 0);
        console.log("gas price: ", tx.gasprice);
        assertEq(endOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    /**
     * 测试多个资助者提取资金
     * 
     */
    function testWithDrawWithMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startFunderIndex = 0;
        //模拟多个自主者存钱
        for (uint160 i = startFunderIndex; i<numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundMeInstance.fund{value: SEND_VALUE}();
        }
        //合约所有者的余额
        uint256 startingOwnerBalance =  fundMeInstance.getOwner().balance;
        //合约的余额
        uint256 startingFundMeBalance = address(fundMeInstance).balance;
        vm.startPrank(fundMeInstance.getOwner());
        fundMeInstance.withdraw();
        vm.stopPrank();
        uint256 endOwnerBalance = fundMeInstance.getOwner().balance;
        uint256 endFundMeBalance = address(fundMeInstance).balance;
        assertEq(endFundMeBalance, 0);
        assertEq(endOwnerBalance, (startingOwnerBalance + startingFundMeBalance) * tx.gasprice);
    }


}