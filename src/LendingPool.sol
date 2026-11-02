// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LendingPool{
    address immutable owner;
    struct TokenInfo{
        bool isSupported;
        bool borrowingAllowed;
        bool withdrawAllowed;
    }

    mapping(address=>TokenInfo) token;

    constructor(){
        owner = msg.sender;
    }

    event TokenAdded(address indexed _token);
    event TokenRemoved(address indexed _token);
    event DepositStatusChanged(address indexed _token, bool status);
    event WithdrawStatusChanged(address indexed _token, bool status);

    modifier onlyOwner(){
        require(msg.sender==owner,"Not Authorized");
        _;
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
    function pauseWithdraw(address _token) public onlyOwner{
        require(token[_token].isSupported,"Token Not Supported");
        require((token[_token].withdrawAllowed),"Already Paused Withdraw");
        token[_token] = TokenInfo(true,true,false);
        emit WithdrawStatusChanged(_token, false);
    }
    function resumeWithdraw(address _token) public onlyOwner{
        require(token[_token].isSupported,"Token Not Supported");
        require((!token[_token].withdrawAllowed),"Already Resumed Withdraw");
        token[_token] = TokenInfo(true,true,true);
        emit WithdrawStatusChanged(_token, true);
    }
    function deListToken(address _token) public onlyOwner{
        require(token[_token].isSupported,"Token Not Supported");
        token[_token] = TokenInfo(false,false,false);
        emit TokenRemoved(_token);
    }
}