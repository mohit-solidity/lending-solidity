// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract LendingPool{
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

    function depositETH(address _ETH) public payable {
        TokenInfo memory t = token[_ETH];
        require(t.isSupported,"Token Not Supported");
        require(t.depositAllowed,"Deposit Not Allowed For This Token");
        require(msg.value>= 0 ether,"Value Must Be Greater Than 0 ETH");
        deposits[msg.sender][_ETH] += msg.value;
        totalDeposits[_ETH] += msg.value;
        emit TokenDeposited(msg.sender, _ETH, msg.value);
    }
    function deposit(address _token, uint _amount) external {
        require(_amount>0,"Amount Must Be Greater Than 0");
        require(_token!=address(0),"Invalid Adderss");
        TokenInfo memory t = token[_token];
        require(t.isSupported,"Token Not SUpported");
        require(t.depositAllowed,"No Deposit Allowed For This Token");
        deposits[msg.sender][_token] += _amount;
        totalDeposits[_token] += _amount;
        emit TokenDeposited(msg.sender, _token, _amount);

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