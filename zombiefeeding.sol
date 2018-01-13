pragma solidity ^0.4.19;

// import files
import "./zombiefactory.sol";


// An interface to interact with other contracts
contract KittyInterface {
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

// inheritance
contract ZombieFeeding is ZombieFactory {
	// instantiate the interface to the cryptokitties contract
	// don't use a hard coded address
	address ckAddress;
	KittyInterface kittyContract;
	
	// address setter
	// uses modifier from Ownable contract
	function setKittyContractAddress(address _address) external onlyOwner {
		kittyContract = KittyInterface(_address);
	}
	
	function _triggerCooldown(Zombie storage _zombie) internal {
		_zombie.readyTime = uint32(now + cooldownTime);
	}

	function _isReady(Zombie storage _zombie) internal view returns (bool) {
		return (_zombie.readyTime <= now);
	}

	function feedAndMultiply(uint _zombieId, uint _targetDna, string species) internal {
		require(msg.sender == zombieToOwner[_zombieId]);
		/* variables declared outside of functions are by default storage (written to blockchain)
		 * variables in functions are by default memory
		 */
		Zombie storage myZombie = zombies[_zombieId];
		
		// make sure it's ready
		require(_isReady(myZombie));
		
		_targetDna = _targetDna % dnaModulus;
		uint newDna = (myZombie.dna + _targetDna) / 2;

		// there is no primitive string comparison so compare hashes
		if (keccak256(species) == keccak256("kitty")) {
			newDna = newDna - newDna % 100 + 99;
		}

		_createZombie("NoName", newDna);
		
		_triggerCooldown(myZombie);
	}

	function feedOnKitty(uint _zombieId, uint _kittyId) public {
		uint kittyDna;
		// multiple return values are automatically expanded
		(,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
		feedAndMultiply(_zombieId, kittyDna, "kitty");
	}
}
