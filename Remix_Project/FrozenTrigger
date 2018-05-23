pragma solidity ^0.4.18;

/**
 check for transaction safety (integer overflow prevent)
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically revert()s when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
//--------------------------------------------------------------------

contract Trigger {
    using SafeMath for uint256;
    address public tokenAdress;
    address public tokenOwner;
    uint256 public buyPrice;
    address public owner;
    // onwer to control the total tokens can be sold
    uint256 public totalSold;
    uint256 public maxSold;
    
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }
    
    // record each buyer transaction
    // default value are all 0 in solidity
    uint256 timeLimit = 1 minutes;
    struct Transaction {
        uint256 index;
        uint256[] amount;
        uint256[] timeStamp;
    }
    // record one buyer total frozen amount
    mapping(address => uint256) public frozenOf;
    mapping(address => Transaction) public buyInfo;
    //****************************************************************************
    
    // constructor
    function Trigger(address _tokenAddress, address _tokenOwner) public {
        tokenAdress = _tokenAddress;
        tokenOwner = _tokenOwner;
        buyPrice = 0;
        owner = msg.sender;
        totalSold = 0;
        maxSold = 0;
    }
    //********************************************************************
    
    function transferOwnership(address newOwner) public onlyOwner {
      require(newOwner != address(0));
      owner = newOwner;
    }
    //*********************************************************************
    
    // change buy price
    function altPrice(uint256 newPrice) public onlyOwner {
        require(newPrice >= 0);
        buyPrice = newPrice;
    }
    
    // change token address
    function altTokenAddress(address newAddress) public onlyOwner {
        require(newAddress != address(0));
        tokenAdress = newAddress;
    }
    
    // change token owner address
    function altOnwerAddress(address newTokenOwner) public onlyOwner {
        require(newTokenOwner != address(0));
        tokenOwner = newTokenOwner;
    }
    
    // set new sold limit
    function altMaxSold(uint256 newLimit) public onlyOwner {
        maxSold = newLimit;
    }
    //**********************************************************************
    
     // transfer contract balance to owner -> unit: ether
    function withdrawEther(uint256 amount) public onlyOwner {
        owner.transfer(amount * 1 ether);
    }
    
    // transfer contract balance to owner -> uint: wei
    function withdrawEtherInWei(uint256 amount) public onlyOwner {
        owner.transfer(amount);
    }
    //*********************************************************************
    
    // withdraw Token to owner from this contract
    function withDrawToken(uint256 amount) public onlyOwner {
        sendTo(tokenOwner, amount);
    }
    //**********************************************************************
    
     function() payable public {
        require(buyPrice>0);
        uint256 amount = msg.value * buyPrice;
        require(totalSold.add(amount) <= maxSold);
        totalSold = totalSold.add(amount);
        
        address buyer = msg.sender;
        // then add to fronzen transaction
        frozenOf[buyer] = frozenOf[buyer].add(amount);
        buyInfo[buyer].amount.push(amount);
        buyInfo[buyer].timeStamp.push(now + timeLimit);
    }
   
   // unfrozen tokens -> this will unfreeze one most recently tokens that buyer bought
   // if current time is ready, the buyer can do this
   function unfrozenToken() public {
       // check time stamp
       uint256 id = buyInfo[msg.sender].index;
       require(id < buyInfo[msg.sender].amount.length);
       require(buyInfo[msg.sender].timeStamp[id] <= now);
       // send token to owner and reduce their frozen amount
       frozenOf[msg.sender] -= buyInfo[msg.sender].amount[id];
       sendTo(msg.sender, buyInfo[msg.sender].amount[id]);
       // move index pointer to next transaction if exist
       buyInfo[msg.sender].index++;
   }
    
    function sendTo(address _to, uint256 amount) internal {
        //  _e.call(bytes4(sha3("setN(uint256)")), _n); 
        require(tokenAdress.call(bytes4(sha3("transfer(address,uint256)")), _to, amount));
    }
   //*****************************************************************************************
    
}

