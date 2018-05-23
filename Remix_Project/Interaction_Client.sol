pragma solidity ^0.4.11;

// describe the interface

interface Service{
  function getNum() public constant returns(uint256 result); // empty because we're not concerned with internal details
}

contract Client {
  Service _s; // "Service" is a Type and the compiler can "see" it because this is one file. 

  function Client(address serviceAddress) public {
    _s = Service(serviceAddress); // _s will be the "Service" located at serviceAddress
  }

  function Ping() public constant returns(uint256 result) {
    return _s.getNum(); // message/response to Service is intuitive
  }
}
