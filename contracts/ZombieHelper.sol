//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding {

  uint levelUpFee = 0.001 ether;

  modifier aboveLevel(uint _level, uint _zombieId){
    require(zombies[_zombieId].level >= _level);
    _;
  }

  function withdraw() external onlyOwner {
    address payable _owner = payable(owner()); //in sol ^0.8.0 address is not payable by default => need to convert it to payable
    _owner.transfer(address(this).balance);//address(this) get the current address of the contract.
  }

  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function levelUp(uint _zombieId) external payable{
    require(msg.value == levelUpFee);
    zombies[_zombieId].level++;
  }

  function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId){
    require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].name = _newName;
  }

  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId){
    require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].dna = _newDna;
  }

  function getZombiesByOwner(address _owner) external view returns(uint[] memory){//return a memory uint array
    uint [] memory result = new uint[](ownerZombieCount[_owner]);//in current version of solidity, a memory array had to specify the length
                                                                 // and cannot using push() to push data into.
    uint counter = 0;
    for(uint i=0; i< zombies.length; i++){
        if(zombieToOwner[i] == _owner){
            result[counter]=i;
            counter++;
        }
    }
    return result;
  }
}
