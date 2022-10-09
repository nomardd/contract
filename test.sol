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
    event NewWithdralRequest(uint trip, uint amount, address user);
    event NewAddTripMembers(uint trip, address user);

    //DATA STUCTURES
    //all trips

    mapping( uint => Trip) _trips;
    WithdrawRequest[] _wR;
    //address gnosisWallet;
    uint lastId;
    uint lastWithdrawId;

    struct Trip{
        uint id;
        string tripName;
        mapping(address => uint)  balance;
        address[]  members;
        uint totalNeeded;
        bool active;
        address owner;
    }     

    struct WithdrawRequest{
        uint withdrawId;
        uint tripId;
        uint amount;
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
        //assign user
        _trips[lastId].owner = user;


        emit NewTrip(lastId,  user,  tripName, totalNeeded);
        lastId += 1;
   }
    
    

   function deleteTrip(uint id) public returns (bool){
        _trips[lastId].active = false;
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
/*
   function withdrawRequest(uint amount, uint tripId, address user) public returns (bool){
        WithdrawRequest storage wR = new WithdrawRequest();       
        wR.withdrawId = lastWithdrawId+1;
        wR.amount = amount;
        wR.done = false;
        wR.tripId = tripId;

        lastWithdrawId = _wR.withdrawId;

        _wR.push(wR);
        emit NewWithdralRequest(lastId,  tripId,  amount, user);

        return true;
   }

   function withdraw(uint trip) public returns (bool){

    return false;
   
                
   }
*/


}

