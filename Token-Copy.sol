pragma solidity ^0.4.17;


contract SafeMath {
    uint256 constant public MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (x > MAX_UINT256 - y) throw;
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (x < y) throw;
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) throw;
        return x * y;
    }
}

contract ERC20 {
 	/// tiggered when tokens are transfered
 	event Transfer(address indexed _from, address indexed _to, uint _value);

 	///fires when the 'approve' method is called
  	event Approval(address indexed _owner, address indexed _spender, uint _value);

  	///@notice Get the total token supply
 	function totalSupply() constant returns (uint);

 	///@notice Get the account balance of another account
 	///@param _owner - account address
  	function balanceOf(address _owner) constant returns (uint);

  	///@notice Returns the amount which _spender is still allowed to withdraw from _owner
  	///@param _owner address of token owner
  	///@param _spender address of spender
  	function allowance(address _owner, address _spender) constant returns (uint);

  	///@notice send amount to tokens to a particular address
  	function transfer(address to, uint _value) returns (bool success);

  	///@notice Send _value amount of tokens from one address to another. This function
  	/// allows contracts that have been authorised to send tokens on your behalf
  	///@param _from address where token is sent from
  	///@param _to address where token is sent to
  	function transferFrom(address _from, address _to, uint _value) returns (bool success);

  	///@notice Allow _spender to withdraw from your account, multiple times, up to the _value amount.
  	///@param _spender address allowed to withdraw a maximum value of tokens
  	///@param _value total value of tokens a particular address is allowed to withdraw
  	function approve(address _spender, uint _value) returns (bool success);

 }


contract LherbeurToken is ERC20, SafeMath  {
    //conforming to the ERC20 standard

    string public name;             //token name
    uint8 public decimals;          //number of decimals of the smallest unit
    string public symbol;           //token symbol
    string public version;          //version value according to an arbitrary scheme
    uint256 public totalSupply;
    address owner;

    /// @notice mapping to track amount of tokens each address holds
    mapping (address => uint256) public balances;

    /**
    * @notice mapping to store contract addresses authorised to spend tokens
    * on behalf of an address and maximun tokens they can spend
    */
    mapping (address => mapping(address => uint)) public allowed;

    /// @notice event triggered when new amounts are approved for contract addresses
    event Approval(address _sender, address _spender, uint _amount);

    /// @notice event triggered when tokens are transferred
    event Transfer(address indexed _from, address indexed _to, uint256 _value); //Transfer event
    

   function LherbeurToken() {
        name = "Lherbeur Token";
        decimals = 18;
        symbol = "LBT";
        version = "1.0";
        totalSupply = 100000000000000000000000000; //100million LBT
        balances[this] = totalSupply; 
        owner = msg.sender;
        emit Transfer(address(0), this, totalSupply);
    }

//don't allow more than 100th tokens to be purchased
//0.002Eth per token - oraclize for real usd - eth conversion
function purchaseToken() external payable  
returns (bool){        
    
    require(msg.value != 0);

    uint tokenCount = msg.value * 10**18/ (0.002 ether);

    require(tokenCount <= 100000);
    balances[msg.sender] = safeAdd(balances[msg.sender], tokenCount);
    balances[this] = safeSub(balances[this], tokenCount);
    emit Transfer(this, msg.sender, tokenCount);
    return true;         
}
    
  function totalSupply() view returns (uint)
  {
      return totalSupply;
  }
  
  ///@notice Get the account balance of another account
 	///@param _owner - account address
   function balanceOf(address _owner) view returns (uint balance) {
        balance = balances[_owner];
    }

  	///@notice Returns the amount which _spender is still allowed to withdraw from _owner
  	///@param _owner address of token owner
  	///@param _spender address of spender
  	function allowance(address _owner, address _spender) view returns (uint)
    {
        return allowed[_owner][_spender];
    }
    
    /**
    * @notice @notice function that is called when a user or another contract
    *  wants to transfer funds with no _data
    * @param _to address where token will be sent
    * @param _value of tokens
    */
    function transfer(address _to, uint256 _value) returns (bool success) {
       
        require(balanceOf(msg.sender) > _value);
       
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        emit Transfer(msg.sender, _to, _value);
        success = true;  
    }

  	///@notice Send _value amount of tokens from one address to another. This function
  	/// allows contracts that have been authorised to send tokens on your behalf
  	///@param _from address where token is sent from
  	///@param _to address where token is sent to
  	function transferFrom(address _from, address _to, uint _value) returns (bool success)
    {    
        require(allowed[_from][msg.sender] >= _value);
       
        balances[_from] = safeSub(balanceOf(_from), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);

        //adjust allowance
        approve(msg.sender, allowed[_from][msg.sender] - _value);
        emit Transfer(msg.sender, _to, _value);
        success = true;
    }

  	///@notice Allow _spender to withdraw from your account, multiple times, up to the _value amount.
  	///@param _spender address allowed to withdraw a maximum value of tokens
  	///@param _value total value of tokens a particular address is allowed to withdraw
  	function approve(address _spender, uint _value) returns (bool success)
    {
        approve(msg.sender, _spender, _value);
    }

    /**
    * @dev function to set amount of tokens approved to desired value
    * @param _owner address of token owner
    * @param _spender contract address to spend tokens on behalf of owner
    * @param _amount value of tokens approved to be spent on owner behalf
    */
    function approve(address _owner, address _spender, uint256 _amount) internal returns (bool success) {
        // To change the approve amount you first have to reduce the addresses´
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(approve(_owner, _spender));
        allowed[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
        return true;
    }

    /**
    * @dev function to set amount of tokens approved to zero
    * @param _owner address of token owner
    * @param _spender contract address to spend tokens on behalf of owner
    */
    function approve(address _owner, address _spender) internal returns (bool){
        allowed[_owner][_spender] = 0;
        emit Approval(_owner, _spender, 0);
        return true;
    }

    function transferEth(address _to, uint amount)
    {
        require (msg.sender == owner);

        _to.transfer(amount * 1000000000000000000);

    }

    function kill()  {
      
      require (msg.sender == owner);
      owner.transfer(this.balance);
      selfdestruct(owner);
    }

}

