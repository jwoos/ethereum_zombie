pragma solidity ^0.4.19;

import "./ownable.sol";

contract ZombieFactory is Ownable {
	// Event to communicate with frontend
	event NewZombie(uint zombieId, string name, uint dna);

	/* uint is 256 bit by default
	 * others can be specified as uint8, uint16, etc
	 * generally recommended to use uint unless you have a reason not to
	 */
	uint dnaDigits = 16;
	uint dnaModulus = 10 ** dnaDigits;
	
	uint cooldownTime = 1 days;

	// like a C struct, just PoD
	// pack the struct with smaller types to save space
	struct Zombie {
		string name;
		uint dna;
		uint32 level;
		uint32 readyTime;
	}

	/* Arrays
	 * Type[] indicates a dynamic array
	 * Type[n] indicates an array of size n
	 */
	Zombie[] public zombies;

	// mappings are key-value structures
	mapping (uint => address) public zombieToOwner;
	mapping (address => uint) ownerZombieCount;

	// internal is private but also accessible from inside the contract
	// external is public but the functions are not callable from inside the contract
	function _createZombie(string _name, uint _dna, uint32 _level, uint32 _readyTime) internal {
		uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime))) - 1;

		// msg.sender will always be defined since someone has to call it
		zombieToOwner[id] = msg.sender;
		ownerZombieCount[msg.sender]++;
		NewZombie(id, _name, _dna);
	}

	// private entities should be prefixed with _
	// view denotes the function only accesses data
	// pure denotes that no access is done
	function _generateRandomDna(string _str) private view returns (uint) {
		// SHA3 hashing function
		uint rand = uint(keccak256(_str));
		return rand % dnaModulus;
	}

	function createRandomZombie(string _name) public {
		// require throw an error if the condition is not met
		require(ownerZombieCount[msg.sender] == 0);
		uint randDna = _generateRandomDna(_name);
		_createZombie(_name, randDna);
	}
}
