//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

//ERC Token Standard #20 Interface
interface ERC20Interface {
    
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
    //event triggered when tokens are transferred from one address to another
    event Transfer(address indexed from, address indexed to, uint tokens);

    //gives administrators the final say in approving or rejecting a pending demand
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract firstContract is ERC20Interface {
    
    //creates public string variable called name
    string public name;

    //creates public string variable called symbol
    string public symbol; 

    //creates public unsigned integer variable called decimals
    uint8 public decimals;

    //creates public unsigned integer variable called _totalSupply
    uint public _totalSupply;
    
    //shows number of tokens available for given wallet address
    mapping(address => uint) balances;

    //how many tokens can be spent by the approved wallet addresses
    mapping (address => mapping(address => uint)) allowed;

    
    //special function called when contract is first created; contains initialization of state variables
    constructor () {
        name = "Rukma";
        symbol = "R";    
        decimals = 18;
        _totalSupply = 1_000_001_000_000_000_000_000_000;
        balances[0xc33703f786d810161f1a4006846a6BB29D65c0e7] = _totalSupply;
        emit Transfer(address(0), 0xc33703f786d810161f1a4006846a6BB29D65c0e7, _totalSupply);
       
    }
    
    //function totalSupply() returns the total token supply
    function totalSupply() public view returns (uint) {
        return _totalSupply - balances[address(0)];
    }
    
    //function balanceOF() returns the account balance of another account with address of owner 
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    //function transfer() transfers specified number of tokens to receiving address, while also filing the transfer event
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender]- tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    
    //function approve() takes address and ID of token which you own and approves of managing it
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    //function transferFrom() transfers tokens while not performing check for receiving address
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from]- tokens;
        allowed[from][msg.sender] = allowed[from][msg.sender]- tokens;
        balances[to] = balances[to]+ tokens;
        emit Transfer(from, to, tokens);
        return true;
    }
    
    //function allowance() returns the amount which spender is still allowed to withdraw from owner
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
 
   
}