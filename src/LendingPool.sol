// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LendingPool{
    using SafeERC20 for IERC20;
    address immutable owner;
    struct TokenInfo{
        bool isSupported;
        bool depositAllowed;
        bool borrowingAllowed;
    }

    mapping(address=>TokenInfo) token;
    mapping(address=>mapping(address=>uint)) deposits;
    mapping(address=>uint) totalDeposits;

    event TokenAdded(address indexed _token);
    event TokenRemoved(address indexed _token);
    event DepositStatusChanged(address indexed _token, bool status);
    event WithdrawStatusChanged(address indexed _token, bool status);
    event TokenDeposited(address indexed user, address indexed token, uint amount);

    constructor(){
        msg.sender==owner;
    }

    modifier onlyOwner(){
        require(msg.sender==owner,"Not Authorized");
        _;
    }

    function depositETH() external payable {
        require(msg.value>0 ether,"Amount Must Be Greater Than 0 ETH");
        deposits[msg.sender][address(0)] += msg.value;
        totalDeposits[address(0)] += msg.value;
        emit TokenDeposited(msg.sender, address(0), msg.value);
    }
    function deposit(address _token, uint _amount) external {
        require(_amount>0,"Amount Must Be Greater Than 0");
        require(_token!=address(0),"Invalid Adderss");
        TokenInfo memory t = token[_token];
        require(t.isSupported,"Token Not SUpported");
        require(t.depositAllowed,"No Deposit Allowed For This Token");
        IERC20(_token).safeTransferFrom(msg.sender,address(this),_amount);
        deposits[msg.sender][_token] += _amount;
        totalDeposits[_token] += _amount;
        emit TokenDeposited(msg.sender, _token, _amount);
    }

    function withdrawETH(uint _amount) external {
        require(deposits[msg.sender][address(0)]>0,"Insufficient Balance");
        require(totalDeposits[address(0)]>_amount,"Insuffieicnt Liquidity");
        deposits[msg.sender][address(0)] -= _amount;
        totalDeposits[address(0)] -= _amount;
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        require(success,"Transaction Failed Due To Unexpected Error");
    }
    function withdrawToken(address _token, uint _amount) external {
        require(deposits[msg.sender][_token]>0,"Insufficient Balance");
        require(totalDeposits[_token]>_amount,"Insuffieicnt Liquidity");
        deposits[msg.sender][_token] -= _amount;
        totalDeposits[_token] -= _amount;
        IERC20(_token).safeTransfer(msg.sender,_amount);
    }
    function addToken(address _token) public onlyOwner{
        require(!token[_token].isSupported,"Token Already Added");
        token[_token] = TokenInfo(true,true,true);
        emit TokenAdded(_token);
    }
    function pauseBorrowing(address _token) public onlyOwner{
        require(token[_token].isSupported,"Token Not Supported");
        require((token[_token].borrowingAllowed),"Already Paused Borrowing");
        token[_token] = TokenInfo(true,false,false);
        emit DepositStatusChanged(_token, false);
    }
    function resumeBorrowing(address _token) public onlyOwner{
        require(token[_token].isSupported,"Token Not Supported");
        require((!token[_token].borrowingAllowed),"Already Resumed Borrowing");
        token[_token] = TokenInfo(true,true,true);
        emit DepositStatusChanged(_token, true);
    }
    function pauseDeposit(address _token) public onlyOwner{
        require(token[_token].isSupported,"Token Not Supported");
        require((token[_token].depositAllowed),"Already Paused Deposit");
        token[_token] = TokenInfo(true,true,false);
        emit WithdrawStatusChanged(_token, false);
    }
    function resumeDeposit(address _token) public onlyOwner{
        require(token[_token].isSupported,"Token Not Supported");
        require((!token[_token].depositAllowed),"Already Resumed Deposit");
        token[_token] = TokenInfo(true,true,true);
        emit WithdrawStatusChanged(_token, true);
    }
    function deListToken(address _token) public onlyOwner{
        require(token[_token].isSupported,"Token Not Supported");
        token[_token] = TokenInfo(false,false,false);
        emit TokenRemoved(_token);
    }
}