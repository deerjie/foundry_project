// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";


/**
 * @title Raffle
 * @author jay
 * @notice 抽奖合约
 */
contract Raffle is VRFConsumerBaseV2Plus{
    event RaffleEnter(address indexed player);
    /* Errors */// @title A title that should describe the contract/interface
    error NotEnoughETH(); // 错误：支付的ETH不足
    error IntervalNotMet(); // 错误：抽奖间隔时间未到

    uint256 private immutable i_entranceFee; // 抽奖入场券价格,immutable变量可以在声明时或构造函数中初始化
    address payable[] private s_players; // 参与抽奖的玩家列表
    address recentWinner; // 最近的获胜者
    uint256 randomness; // 随机数
    uint256 i_interval; // 抽奖间隔时间
    uint256 private s_lastTimeStamp; // 上一次抽奖时间
    /* VRF */
    uint256 s_subscriptionId;
    address vrfCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B; // 链接到vrf的Coordinator合约地址
    bytes32 s_keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae; //选择一个不同的预言机节点，这些节点根据延迟有不同的价格
    uint32 callbackGasLimit = 40000; // 回调函数消耗的gas限制 ｜ 花掉的钱费用 = 回调函数消耗的gas * 每gas的价格（vrfCoordinator的价格 * callbackGasLimit）
    uint16 requestConfirmations = 3; // 需要多少个区块确认，这个数值越小响应速度越快，但安全性越低
    uint32 numWords =  1;//生成随机数个数，如果填3，则生成3个随机数


    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint256 private immutable i_subscriptionId;

    /**
     * @notice 构造函数
     * @param enterRaffleFee 抽奖入场券价格
     * @param i_interval 抽奖间隔时间
     * @param subscriptionId 订阅ID 先去充值订阅得到一个id，然后传入，到时候根据id进行扣费
     */
    constructor(uint256 enterRaffleFee, uint256 i_interval, uint256 subscriptionId) VRFConsumerBaseV2Plus(vrfCoordinator){
        i_entranceFee = enterRaffleFee; // 初始化抽奖入场券价格
        i_interval = i_interval; // 初始化抽奖间隔时间
        s_lastTimeStamp = block.timestamp;// 初始化上一次抽奖时间
        s_subscriptionId = subscriptionId;
    }

    /**
     * @notice 参与抽奖，通过它购买抽奖入场券
     */
    function enterRaffle() public  payable {
        //1. 检查支付的ETH是否足够
        // 写法一
        require(msg.value >= i_entranceFee, NotEnoughETH());
        // 写法二
        // if (msg.value >= i_entranceFee) {
        //     revert NotEnoughETH(); 
        // }
        //2. 
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);

    }
    /**
     * @notice 选择获胜者，通过它进行抽奖
     * 1. get a random number
     * 2. get a random number to pick a player
     * 3. transfer the prize to the winner
     */
    function pickWinner() public  {
        if (block.timestamp - s_lastTimeStamp < i_interval) {
            revert IntervalNotMet();
        }
        // get a random number
        

    }

    /**
     * @return 抽奖入场券价格
     */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee; // 抽奖入场券价格
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {

        // transform the result to a number between 1 and 20 inclusively
        uint256 d20Value = (randomWords[0] % 20) + 1;

        // assign the transformed value to the address in the s_results mapping variable
        s_results[s_rollers[requesctId]] = d20Value;

        // emitting event to signal that dice landed
        emit DiceLanded(requestId, d20Value);
    }
    

    
}