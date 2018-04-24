pragma solidity ^0.4.20;

contract Casino {
    address public owner;
    // The minimum bet a user has to make to participate in the game
    uint public minimumBet = 1 finney; // Equal to 0.001 ether
    // The maximum amount of bets can be made for each game
    uint public maxAmountOfBets = 10;
    // The max amount of bets that cannot be exceeded to avoid excessive gas consumption
    // when distributing the prizes and restarting the game
    uint public constant LIMIT_AMOUNT_BETS = 100;
    // this number is used to generate one random number
    uint private runTime = 1;
    // this number is used to generate one random number
    uint private hashNum = 521;
    // The total amount of Ether bet for this current game
    uint public totalBet;
    // The total number of bets the users have made
    uint public numberOfBets;
    // The number that won the last game (answer for last game)
    uint public lastWinNumber;
    // Array of players
    address[] public players;
    // Each number has an array of players. Associate each number with a bunch of players
    mapping(uint => address[]) public numberBetPlayers;
    // The number that each player has bet for
    mapping(address => uint) public playerBetsNumber;
    // The total amount of money for each player has bet for
    mapping(address => uint) public playerBetsMoney;

    // Modifier to only allow the execution of functions when the bets are completed
    modifier onEndGame(){
        if(numberOfBets >= maxAmountOfBets) _;
    }

    // constructor
    function Casino() public {
        owner = msg.sender;
    }
    //********************************************************** */

    // some rule changing functions -> require owner to change
    function changeMinimumBet(uint _minimumBet) public {
        require(msg.sender == owner);
        if(_minimumBet > 0) minimumBet = _minimumBet;
    }

    function changeMaxAmountOfBets(uint _newVal) public {
        require(msg.sender == owner);
        if(_newVal > 0 && _newVal <= LIMIT_AMOUNT_BETS) {
            maxAmountOfBets = _newVal;
        }
    }
    
    // change generate random number run time
    function changeRNG(uint newRunTime, uint newHashNum) public {
        require(msg.sender == owner);
        if(newRunTime > 0) {
            runTime = newRunTime;
        }
        hashNum = newHashNum;
    }

    // this is only for test
    function showCasinoBalance() public view returns(uint256){
        require(msg.sender == owner);
        return address(this).balance;
    }
    //*********************************************************** */

    function kill() public {
        if(msg.sender==owner) {
            selfdestruct(owner);
        }
    }
    //********************************************************** */

    // to bet for a number between 1 and 10 both inclusive
    function bet(uint256 numberSelected) public payable {
        require(!checkPlayerExists(msg.sender));
        require(numberSelected >= 1 && numberSelected <= 10);
        require(msg.value >= minimumBet);
        require(numberOfBets < maxAmountOfBets);
        
        numberOfBets++;
        totalBet += msg.value;
        players.push(msg.sender);
        playerBetsNumber[msg.sender] = numberSelected;
        playerBetsMoney[msg.sender] = msg.value;
        numberBetPlayers[numberSelected].push(msg.sender);

        if(numberOfBets >= maxAmountOfBets) generateNumberWinner();
    }

    function checkPlayerExists(address player) public constant returns(bool) {
        if(playerBetsNumber[player] > 0) {
            return true;
        }
        else return false;
    }
    //********************************************************** */

    // generate a random number between 1 and 10
    // Must be payable because oraclize needs gas to generate a random number.
    // Can only be executed when the game ends.
    function generateNumberWinner() onEndGame public {
        uint256 winNumber = 0;
        uint256 time = 0;
        while(time < runTime) {
            time++;
            for(uint i = 1; i <= 10; i++) {
                winNumber += i*numberBetPlayers[i].length;
                if(i%2 == 0) {
                    winNumber += hashNum;
                    if(hashNum > 0) hashNum--;
                }
            }
            winNumber = ((winNumber + (hashNum/10)) + block.number%10)%10 + 1;
        }
        lastWinNumber = winNumber;
        distributePrizes(winNumber);
    }

    // Sends the corresponding ether to each winner depending on the total bets
    function distributePrizes(uint256 winNumber) onEndGame public {
        // calculate winner amount
        uint winnerAmount = 0;
        for(uint i = 0; i < numberBetPlayers[winNumber].length; i++) {
            winnerAmount += playerBetsMoney[numberBetPlayers[winNumber][i]];
        }

        for( i = 0; i < numberBetPlayers[winNumber].length; i++) {
            // How much each winner gets
            uint winnerEtherAmount = totalBet * playerBetsMoney[numberBetPlayers[winNumber][i]] / winnerAmount;
            numberBetPlayers[winNumber][i].transfer(winnerEtherAmount);
        }
        resetData();
    }
    //********************************************************** */
    
    // reset all data after distribute prizes
    function resetData() private {
        // Delete all the players for each number
        for(uint i = 1; i <= 10; i++){
            numberBetPlayers[i].length = 0;
        }
        // Delete all players in the round
        for(i = 0; i < players.length; i++) {
            playerBetsNumber[players[i]] = 0;
            playerBetsMoney[players[i]] = 0;
        }
        players.length = 0;
        totalBet = 0;
        numberOfBets = 0;
        if(hashNum == 0) hashNum = 10247;
    }
    //*********************************************************** */

}