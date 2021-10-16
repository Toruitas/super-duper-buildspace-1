// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;  // means use this compiler and up

import "hardhat/console.sol";

// basic contract to let folks wave at us
contract MyWavePortal{

    uint256 totalWaves;

    /*
     * We will be using this below to help generate a random number
     */
    uint256 private seed;

    /*
     * A little magic, Google what events are in Solidity!
     */
    event NewWave(
        address indexed from, 
        uint256 timestamp, 
        string message
    );

    /*
     * I created a struct here named Wave.
     * A struct is basically a custom datatype where we can customize what we want to hold inside it.
     */
     struct Wave {
         address waver; // addy of user who waved
         string message; // the msg that user sent to the
         uint256 timestamp; // ts when the user waved
     }
     /*
     * I declare a variable waves that lets me store an array of structs.
     * This is what lets me hold all the waves anyone ever sends to me!
     */

    Wave[] waves;

    /*
    * This is an address => uint mapping, meaning I can associate an address with a number!
    * In this case, I'll be storing the address with the last time the user waved at us.
    * kinda like a dict, but with types
    */
    mapping(address => uint256) public lastWavedAt;

    // payable added so that this contract can pay people
    constructor() payable{
        console.log("Hey you whatsup, I'm a smart contract");
    }

    // A Get fn
    // if it's public, it's callable on the blockchain, like a public API endpoint
    function getTotalWaves() public view returns (uint256){
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }

    //  We can save data and persist data
    // Global variable that persists state on the blockchain. 
    // It's similar to a database, but these state variables can persist data between function calls
    // this is almost like a public POST function
    /*
     * You'll notice I changed the wave function a little here as well and
     * now it requires a string called _message. This is the message our user
     * sends us from the frontend!
     */
    //  https://medium.com/coinmonks/the-curious-case-of-in-solidity-16d9eb4440f1
    function wave(string memory _message) public {

        /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
         */
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "wait 30 seconds before trying again"
        );
        /*
         * Update the current timestamp we have for the user
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves +=1;
        // msg.sender is the wallet address of the person who called the fn
        // == info.context.user
        console.log("%s has waved -- totalWaves = %s", msg.sender, totalWaves);

        // add to the struct array
        waves.push(Wave(msg.sender, _message, block.timestamp));

        /*
         * Generate a Psuedo random number between 0 and 100
         */
        uint256 randomNumber = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %s", randomNumber);
        seed = randomNumber;

        // 5% chance to win
        if (randomNumber < 5){
            console.log("%s won!", msg.sender);
            uint256 prizeAmount = 0.0001 ether;
            // fancy if statement - will exit transaction if not true
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more mo-nay than the contract has"
            );
            // (msg.sender).call{value: prizeAmount}("") is the magic line where we send money :)
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            // again, if it wasn't successful, exit transaction
            require(success, "Failed to withdraw money from contract.");
        }        

        /*
        * I added some fanciness here, Google it and try to figure out what it is!
        * Let me know what you learn in #general-chill-chat
        */
        //  https://medium.com/coinmonks/the-curious-case-of-emit-in-solidity-2d88913e3d9a
        // https://ethereum.stackexchange.com/questions/43755/struggling-with-using-event-logs-via-web3js-to-update-my-react-app
        emit NewWave(msg.sender, block.timestamp, _message);

    }

    function getAllWaves() public view returns (Wave[] memory){
        return waves;
    }

}