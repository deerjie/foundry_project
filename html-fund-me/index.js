// 导入ethers.js库，用于与以太坊区块链交互
import { ethers } from "./ethers-6.7.esm.min.js"
// 导入合约ABI接口定义和部署地址
import { abi, contractAddress } from "./constants.js"

// 获取HTML页面中的按钮元素
const connectButton = document.getElementById("connectButton")    // 连接钱包按钮
const withdrawButton = document.getElementById("withdrawButton")  // 提取资金按钮
const fundButton = document.getElementById("fundButton")         // 资助合约按钮
const balanceButton = document.getElementById("balanceButton")   // 查询余额按钮

// 为按钮绑定点击事件处理函数
connectButton.onclick = connect      // 点击连接按钮时调用connect函数
withdrawButton.onclick = withdraw    // 点击提取按钮时调用withdraw函数
fundButton.onclick = fund            // 点击资助按钮时调用fund函数
balanceButton.onclick = getBalance   // 点击余额按钮时调用getBalance函数

/**
 * 连接MetaMask钱包
 * 请求用户授权连接网站到其MetaMask钱包
 */
async function connect() {
  // 检查浏览器是否安装了MetaMask（window.ethereum对象是否存在）
  if (typeof window.ethereum !== "undefined") {
    try {
      // 请求用户授权连接钱包
      await ethereum.request({ method: "eth_requestAccounts" })
    } catch (error) {
      // 如果用户拒绝连接或发生其他错误，记录错误信息
      console.log(error)
    }
    // 连接成功后，更新按钮文本
    connectButton.innerHTML = "Connected"
    // 获取连接的账户地址
    const accounts = await ethereum.request({ method: "eth_accounts" })
    // 在控制台打印账户地址
    console.log(accounts)
  } else {
    // 如果未安装MetaMask，更新按钮文本提示用户安装
    connectButton.innerHTML = "Please install MetaMask"
  }
}

/**
 * 从FundMe合约中提取资金
 * 只有合约的所有者才能成功调用此函数
 */
async function withdraw() {
  console.log(`Withdrawing...`)  // 在控制台输出提示信息
  // 检查浏览器是否安装了MetaMask
  if (typeof window.ethereum !== "undefined") {
    // 创建provider对象，连接到以太坊网络
    const provider = new ethers.BrowserProvider(window.ethereum)
    // 请求用户授权连接钱包
    await provider.send('eth_requestAccounts', [])
    // 获取用户的签名者对象，用于发送交易
    const signer = await provider.getSigner()
    // 创建合约实例，传入合约地址、ABI和签名者
    const contract = new ethers.Contract(contractAddress, abi, signer)
    try {
      console.log("Processing transaction...")  // 在控制台输出交易处理中提示
      // 调用合约的withdraw函数
      const transactionResponse = await contract.withdraw()
      // 等待交易被确认（至少等待1个区块确认）
      await transactionResponse.wait(1)
      console.log("Done!")  // 交易完成提示
    } catch (error) {
      // 如果交易失败，记录错误信息
      console.log(error)
    }
  } else {
    // 如果未安装MetaMask，更新按钮文本提示用户安装
    withdrawButton.innerHTML = "Please install MetaMask"
  }
}

/**
 * 向FundMe合约发送ETH
 * 用户可以通过此函数向合约发送指定数量的ETH
 */
async function fund() {
  // 获取用户输入的ETH金额
  const ethAmount = document.getElementById("ethAmount").value
  console.log(`Funding with ${ethAmount}...`)  // 在控制台输出资金数量
  // 检查浏览器是否安装了MetaMask
  if (typeof window.ethereum !== "undefined") {
    // 创建provider对象，连接到以太坊网络
    const provider = new ethers.BrowserProvider(window.ethereum)
    // 请求用户授权连接钱包
    await provider.send('eth_requestAccounts', [])
    // 获取用户的签名者对象，用于发送交易
    const signer = await provider.getSigner()
    // 创建合约实例，传入合约地址、ABI和签名者
    const contract = new ethers.Contract(contractAddress, abi, signer)
    try {
      // 调用合约的fund函数，并发送ETH
      const transactionResponse = await contract.fund({
        value: ethers.parseEther(ethAmount),  // 将用户输入的ETH金额转换为wei
      })
      // 等待交易被确认（至少等待1个区块确认）
      await transactionResponse.wait(1)
    } catch (error) {
      // 如果交易失败，记录错误信息
      console.log(error)
    }
  } else {
    // 如果未安装MetaMask，更新按钮文本提示用户安装
    fundButton.innerHTML = "Please install MetaMask"
  }
}

/**
 * 获取FundMe合约的ETH余额
 * 查询合约当前持有的ETH数量
 */
async function getBalance() {
  // 检查浏览器是否安装了MetaMask
  if (typeof window.ethereum !== "undefined") {
    // 创建provider对象，连接到以太坊网络
    const provider = new ethers.BrowserProvider(window.ethereum)
    try {
      // 查询合约地址的ETH余额
      const balance = await provider.getBalance(contractAddress)
      // 将余额从wei转换为ETH并在控制台输出
      console.log(ethers.formatEther(balance))
    } catch (error) {
      // 如果查询失败，记录错误信息
      console.log(error)
    }
  } else {
    // 如果未安装MetaMask，更新按钮文本提示用户安装
    balanceButton.innerHTML = "Please install MetaMask"
  }
}
