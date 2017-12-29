pragma solidity ^0.4.19;

contract ZombieFactory {
	// Event to communicate with frontend
	event NewZombie(uint zombieId, string name, uint dna);

	/* uint is 256 bit by default
	 * others can be specified as uint8, uint16, etc
	 * generally recommended to use uint unless you have a reason not to
	 */
	uint dnaDigits = 16;
	uint dnaModulus = 10 ** dnaDigits;

	// like a C struct, just PoD
	struct Zombie {
		string name;
		uint dna;
	}

	/* Arrays
	 * Type[] indicates a dynamic array
	 * Type[n] indicates an array of size n
	 */
	Zombie[] public zombies;

	// private entities should be prefixed with _
	// private functions are not accessible outside
	function _createZombie(string _name, uint _dna) private {
		uint id = zombies.push(Zombie(_name, _dna)) - 1;
		NewZombie(id, _name, _dna);
	}

	// view denotes the function only accesses data
	// pure denotes that no access is done
	function _generateRandomDna(string _str) private view returns (uint) {
		// SHA3 hashing function
		uint rand = uint(keccak256(_str));
		return rand % dnaModulus;
	}

	function createRandomZombie(string _name) public {
		uint randDna = _generateRandomDna(_name);
		_createZombie(_name, randDna);
	}

}
