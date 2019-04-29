pragma solidity ^0.5.0;

contract Casino {
	// Add different class variables here that you might need to use to store data
	address owner;
	//YOUR CODE HERE
	uint public pool;
	uint numberOfBets;
	uint minimumBet;
	uint maxAmountOfBets;
	address payable[] winners;
	address payable [] public addrKeys;

	//private variables for each user
	mapping (address => uint) individualTotalBetAmount;
	mapping (address => uint) individualNumber;

	// Create a constructor here!
	// The constructor will be used to configure different parameters you might want to
	// initialize with the creation of the contract (i.e. minimum bet, max amount of bets, etc.)
	constructor (uint _numberOfBets, uint _minimumBet, uint _totalBet, uint _maxAmountOfBets) public {
		owner = msg.sender;
		// YOUR CODE HERE
		pool = _totalBet;
		numberOfBets = _numberOfBets;
		maxAmountOfBets = _maxAmountOfBets;
		minimumBet = _minimumBet;
	}

	// Below is a modifier, and the purpose of this modifier is to execute the other functions
	// in the Smart Contract once a certain limit has been reached (num of players > set amount)
	// of players to begin with. You can put the name of the modifier in the functions below to
	// have them run only when the modifier is true, as seen with the generateWinningNumber function
	modifier onEndGame(){
		if (numberOfBets >= maxAmountOfBets) {
		    _;
		}
	}

	function isIn(address addr) private returns (bool) {
		for(uint i = 0; i < addrKeys.length; i++){
			if(addr == addrKeys[i]){
				return true;
			}
		}
		return false;
	}

	// Construct the function to conduct a bet here!
	// The function will be passed in a number to bet, and you can access
	// the user's address and amount bet with msg.sender and msg.value respectively.
	function bet(uint numberToBet) public payable{
		// YOUR CODE HERE
		//need user to not have betted before
		require(isIn(msg.sender) == false );
		require(msg.value > minimumBet);
		addrKeys.push(msg.sender);
		pool += msg.value;
		individualTotalBetAmount[msg.sender] += msg.value;
		individualNumber[msg.sender] = numberToBet;
		numberOfBets += 1;
	}

	// Make a random number generator here! (We'll get into variants of at a future week, but
	// you can use what cryptozombies.io discussed here!)
	function generateWinningNumber() public onEndGame returns (uint) {
		// YOUR CODE HERE
		uint nonce;
		uint rand = uint( uint(keccak256(abi.encodePacked(msg.sender, nonce))) % 10);
		nonce++;
		return rand;
	}

	// Distribute the prizes! Send the ether to the winners with the .transfer function,
	// and call the resetData function to reset the different states of the contract!
	function distributePrizes() onEndGame public payable {
		// YOUR CODE HERE
		uint winningNum = generateWinningNumber();
		//Add all other winners in previous betters
		for(uint i = 0; i < addrKeys.length; i++){
			if(individualNumber[addrKeys[i]] == winningNum){
				winners.push(addrKeys[i]);
			}
		}
		//Transfer prize money to all winners
		for(uint i = 0; i < winners.length; i++) {
			winners[i].transfer(pool * 95 / 100 / winners.length);
		}
		resetData();
	}

	// Reset the data of the Smart Contract here!
	function resetData() public {
		// YOUR CODE HERE
		pool = 0;
		numberOfBets = 0;
		delete winners;
		delete addrKeys;
	}
}
