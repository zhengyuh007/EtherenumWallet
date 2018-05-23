pragma solidity ^0.4.18;

contract Trigger {
    address public tokenAdress;
    address public tokenOwner;
    uint256 public buyPrice;
    address public owner;
    
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }
    //****************************************************************************
    
    // constructor
    function Trigger(address _tokenAddress, address _tokenOwner) public {
        tokenAdress = _tokenAddress;
        tokenOwner = _tokenOwner;
        buyPrice = 0;
        owner = msg.sender;
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
        address buyer = msg.sender;
        // then transfer these tokens to buyer
        sendTo(buyer, amount);
    }
    
    function sendTo(address _to, uint256 amount) internal {
        //  _e.call(bytes4(sha3("setN(uint256)")), _n); 
        require(tokenAdress.call(bytes4(sha3("transfer(address,uint256)")), _to, amount));
    }
   //*****************************************************************************************
    
}

