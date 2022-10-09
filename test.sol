// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


interface ERC20Interface {
  function transferFrom(address _from, address _to, uint _value) external returns (bool success);
  function transfer(address _from, uint _value) external returns (bool success);
  function balanceOf(address account) external view returns (uint);
  function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}


contract Nomard {
    ERC20Interface stableCoinContract;
    event NewTrip(uint tripId, address user, string tripName, uint totalNeeded);
    event NewFundTrip(uint trip, uint amount, address user);
    event NewWithdralRequest(uint withdrawId, uint trip, uint amount, address user);
    event NewWithdrawDone(uint withdrawId, uint amount, address user);
    event NewAddTripMembers(uint trip, address user);

    //DATA STUCTURES
    //all trips

    mapping( uint => Trip) _trips;
    mapping( uint => WithdrawRequest) _withdrawRequests;
    //address gnosisWallet;
    uint lastId;
    uint lastWithdrawId;

    struct Trip{
        uint id;
        string tripName;
        mapping(address => uint)  balance;
        uint[] withdrawRequests;
        address[]  members;
        uint totalNeeded;
        uint totalExpend;
        bool active;
        address owner;
    }     

    struct WithdrawRequest{
        uint withdrawId;
        uint tripId;
        uint amount;
        string receipt;
        bool done;
        address[] addressApprovals;
    } 


    //all users
    mapping ( address => User) _users;

    //user tripbalance
    struct User{
        //trip id => currentAportation
        mapping(uint => uint) balance;
        uint[] userTrips;
   }
   ///END DATA STRUCTURES

   //ttodo remove members from trips

   function createTrip (address user, string memory tripName, uint totalNeeded) public  {
        //create trip
         
        //other needed assignments
        _users[user].userTrips.push(lastId);


        _trips[lastId].id = lastId;
        _trips[lastId].tripName = tripName;
        _trips[lastId].members.push(user);
        _trips[lastId].totalNeeded = totalNeeded;
        _trips[lastId].active = true;
        _trips[lastId].totalExpend = 0;
        //assign user
        _trips[lastId].owner = user;

        emit NewTrip(lastId,  user,  tripName, totalNeeded);
        lastId += 1;
   }
    
    

   function deleteTrip(uint id) public returns (bool) {
      _trips[id].active = false;
      return true;
   }

  
  function setStableCoinContract(address contractAddress) public {
    stableCoinContract = ERC20Interface(contractAddress); 
  }

   
   function addTripMembers(uint tripId, address user) public returns (uint){
        _trips[tripId].members.push(user);
        emit NewAddTripMembers(tripId, user);
        return _trips[tripId].id;
   }

   function fundTrip(uint trip, uint amount, address user) public payable returns (bool){
    //    msg.sender.transfer(amount);
        _trips[trip].balance[user] += amount;

        emit NewFundTrip(lastId,  amount,  user);
        return true;
   }

   function withdrawRequest(uint amount, uint tripId, address user, string memory receipt) public returns (uint) {
     _withdrawRequests[lastWithdrawId].withdrawId = lastWithdrawId;
     _withdrawRequests[lastWithdrawId].amount = amount;
     _withdrawRequests[lastWithdrawId].done = false;
     _withdrawRequests[lastWithdrawId].tripId = tripId;
     _withdrawRequests[lastWithdrawId].receipt = receipt;
     emit NewWithdralRequest(lastWithdrawId,  tripId,  amount, user);
     lastWithdrawId+=1; 
     return (lastWithdrawId-1);
   }

  function addressAlreadyApproved(address theAddress, uint tripId) public view returns (bool){
    for(uint index = 0; index < _trips[tripId].members.length; index++) {
      if(_trips[tripId].members[index] == theAddress) {
        return true;
      }
    }
    return false;
  }

   function approveWithdraw(uint withdrawId) public {
    if(!addressAlreadyApproved(msg.sender, _withdrawRequests[withdrawId].tripId)) {
      _withdrawRequests[withdrawId].addressApprovals.push(msg.sender);
    }
   }

   function withdrawMoney(uint withdrawRequestId) public  {
    uint actualTripId=_withdrawRequests[withdrawRequestId].tripId;
    // if it's not done and atleast half approvals
    if(!_withdrawRequests[withdrawRequestId].done && _trips[actualTripId].members.length > 0 && _withdrawRequests[lastWithdrawId].addressApprovals.length>=_trips[actualTripId].members.length/2 ) {
       (bool os, ) = payable(msg.sender).call{value: _withdrawRequests[lastWithdrawId].amount}('');
       emit NewWithdrawDone(withdrawRequestId, _withdrawRequests[lastWithdrawId].amount, msg.sender);
      _withdrawRequests[lastWithdrawId].done = true;
      _trips[_withdrawRequests[lastWithdrawId].tripId].withdrawRequests.push(lastWithdrawId);
      _trips[_withdrawRequests[lastWithdrawId].tripId].totalExpend+=_withdrawRequests[lastWithdrawId].amount;
       require(os);
    }
   }

   function getAvailableMoneyInTrip(uint tripId) public view returns (uint) {
    return _trips[tripId].totalNeeded - _trips[tripId].totalExpend; 
   }


/*

   function withdraw(uint trip) public returns (bool){

    return false;
   
                
   }
*/


}

