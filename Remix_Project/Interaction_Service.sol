pragma solidity ^0.4.11;

contract Service{
    
    address public owner;
    uint256 num;
    
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }
    
    // constructor
    function Service(uint256 input) public {
        num = input;
        owner = msg.sender;
    }
    //*************************************************************************
    
    function getNum() public constant returns(uint256 result) {
        return num;
    } 
    
    function alterNum(uint256 other) public {
        num = other;
    }
    //*************************************************************************
    
}
