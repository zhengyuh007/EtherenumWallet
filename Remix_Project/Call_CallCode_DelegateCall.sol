pragma solidity ^0.4.18;
// https://ethereum.stackexchange.com/questions/3667/difference-between-call-callcode-and-delegatecall

contract D {
  uint public n;
  address public sender;
  
  // In D, sender will be null, n is not modified
  // In E, sender will be this D's contract address, n is modified
  function callSetN(address _e, uint _n) public {
    // E's storage(n) is set, D is not modified 
    _e.call(bytes4(sha3("setN(uint256)")), _n); 
  }
  
  // In D, sender will be D's contract address, n is modified
  // In E, sender will be null and n is not modified
  function callcodeSetN(address _e, uint _n) public {
    // D's storage(n) is set, E is not modified 
    _e.callcode(bytes4(sha3("setN(uint256)")), _n);
  }
  
  // In D, sender will be the address of who call D contract, n is modified
  // In E, sender will be null and n is not modified
  function delegatecallSetN(address _e, uint _n) public {
    // D's storage(n) is set, E is not modified 
    _e.delegatecall(bytes4(sha3("setN(uint256)")), _n); 
  }
}
//*******************************************************************************

contract E {
  uint public n;
  address public sender;

  function setN(uint _n) public {
    n = _n;
    sender = msg.sender;
    // msg.sender is D if invoked by D's callcodeSetN. None of E's storage is updated
    // msg.sender is C if invoked by C.foo(). None of E's storage is updated

    // the value of "this" is D, when invoked by either D's callcodeSetN or C.foo()
  }
}
//*******************************************************************************

contract C {
    // In D, sender will be C's contract address and n is modified
    // In E, sender will be null and n is not modified
    function foo(D _d, E _e, uint _n) public {
        _d.delegatecallSetN(_e, _n);
    }
}
//*******************************************************************************


