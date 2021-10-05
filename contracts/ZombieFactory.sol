//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; //import ownable.sol from openzeppelin lib.

contract ZombieFactory is Ownable {//inherit Ownable

    //create event which can be iteracted by FE js code
    event NewZombie(uint id, string name, uint dna);

    //every type of uint (uint, uint8, uint12, uint32...) is the same. it will be stored in storage by 256 bits.
    //but have exception when using it in struct type see below.
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days;

    //define zomebie obj
    struct Zombie {
        string name;
        uint dna;
        
        //in solidity, the struct will pack variable wich has the same type and stand nearly each others to minimize storage
        //it means the same type of uint in a struct type should put nearly each others to reduce gas.
        uint32 level;
        uint32 readyTime;
    }
  
    //make a list zombies
    Zombie[] public zombies;

    // declare mappings
    mapping (uint => address) public zombieToOwner; //key (uint) refer zombie id, value (address) => to lookup zombie by id (looks like dictionary type)
    mapping (address => uint) ownerZombieCount; //key (address) , value (uint) => to lookup how many zombie in this address

    function _createZombie(string memory _name, uint _dna) internal {
        uint32 freeze = uint32(block.timestamp + cooldownTime);//solidity ^0.7.0 deprecated "now", use "block.timestamp" instead. it is the same
        zombies.push(Zombie(_name, _dna, 1, freeze));
        uint id = zombies.length - 1;
        zombieToOwner[id] = msg.sender;//use Global Variable msg.sender to get address of who called this function. assign it to zombieToOwner
        ownerZombieCount[msg.sender]++;//count 1 to total zombie of this address after create new for it
        emit NewZombie(id,_name, _dna); //Emit an event: Line 8
    }

    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public { //create your first zombie
        require(ownerZombieCount[msg.sender]==0);//put a validation using require(). macke sure each acc has only one zombie.
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}
