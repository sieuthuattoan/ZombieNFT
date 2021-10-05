//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ZombieFactory.sol";

interface KittyInterface { //make an interface
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

//make anew contract ZombieFeeding inherit ZombieFactory
contract ZombieFeeding is ZombieFactory{

  // address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d; //some contract address here
  // KittyInterface kittyContract = KittyInterface(ckAddress);// initilize KittyInterface which is reffered to another KittyInterface contract
  KittyInterface kittyContract;

  function setKittyContractAddress(address _address) external onlyOwner{
    //onlyOwner is a function modifier of Zeppline ownable -> function modifier will be call first.
    //because ZombieFactory.sol inherit Ownable.sol and ZombieFeeding.sol inherit ZombieFactory.sol
    //so ZombieFeeding.sol inherit Ownable.sol.

    kittyContract = KittyInterface(_address);
  }

  //helper function to trigger cooldown
  function _triggerCooldown(Zombie storage _zombie) internal{
      _zombie.readyTime = uint32(block.timestamp + cooldownTime);
  }

  //helper function to check is it ready to the next feeding
  function _isReady(Zombie storage _zombie) internal view returns(bool){
      return _zombie.readyTime <= block.timestamp;
  }

  function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal { //feeding function
    require(msg.sender == zombieToOwner[_zombieId]); // to validatethe ownership of current sender
    Zombie storage myZombie = zombies[_zombieId]; //make a storage variable
                                                  //its mean when you change myZombie then zombies[_zombieId] will be changed permanently
    
    require(_isReady(myZombie));
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna)/2;
    if(keccak256(abi.encodePacked(_species))==keccak256(abi.encodePacked("kitty"))){ //if a zombie eat species is kitty then it will have special power
      newDna = newDna - newDna % 100 + 99;//change the last 2 digits in of the dna string to 99 to illustrate the zombie have eaten kitty
    }
    _createZombie("NoName",newDna);

    _triggerCooldown(myZombie);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public{
    uint kittyDna;
    (,,,,,,,,,kittyDna)=kittyContract.getKitty(_kittyId); //getKitty of KittyInterface returns multiple value. 
                                                          //so the comma means ignoring needless value
    feedAndMultiply(_zombieId,kittyDna, "kitty");
  }
}