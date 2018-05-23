pragma solidity ^0.4.18;

contract transferETH {
    address public recipient;
    address public owner;
    
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }
    //****************************************************************************
    
    // constructor
    function transferETH(address ads) public {
        recipient = ads;
        owner = msg.sender;
    }
    //********************************************************************
    
    // do transfer
    function transferTo() payable public {
        require(recipient != address(0));
        recipient.transfer(msg.value);
    }
    //********************************************************************
    
    // change address that receive ether
    function changeRecipient(address _newRecip) public onlyOwner  {
        recipient = _newRecip;
    }
    //********************************************************************
    
    function transferOwnership(address newOwner) public onlyOwner {
      require(newOwner != address(0));
      owner = newOwner;
    }
    //*********************************************************************

}

