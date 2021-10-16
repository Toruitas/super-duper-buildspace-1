// this helps us run our smart contract
// npx hardhat run scripts/run.js


const waveFromUser = async (user, contract, waver_counts, msg) => {
    waveTxn = await contract.connect(user).wave(msg);
    await waveTxn.wait();

    waver = waveTxn.from
    if (waver_counts.hasOwnProperty(waver)) {
        waver_counts[waver] += 1
    }else{
        waver_counts[waver] = 1
    }
    console.log("Users who have waved")
    console.log(waver_counts);
}

const main = async () => {
    // compiling our smart contract
    // hre = hardhat runtime environments

    const [owner, randomPerson, randomTwo, random3, random4] = await hre.ethers.getSigners();  // first is the contract owner, then some random wallet addy

    // finds this contract in /contracts/ and compiles it
    const waveContractFactory = await hre.ethers.getContractFactory("MyWavePortal");

    // Deploy to local blockchain
    // give it some extra ETH from my wallet
    const waveContract = await waveContractFactory.deploy({value:hre.ethers.utils.parseEther('0.1')});

    // we need to wait for contract to be mined
    // When deploy contract, that doesn't mean it's fully deployed. It has to be mined (or staked eventually)
    // Miners grab the request
    // hardhat creates local miners for us, fake ones. That's so cool. In real world we gotta wait.
    await waveContract.deployed();

    console.log("Contract deployed to: ", waveContract.address);
    console.log('Contract deployed by:', owner.address);

    let contractBalance = await hre.ethers.provider.getBalance(
      waveContract.address
    );
    console.log("Contract balance:", hre.ethers.utils.formatEther(contractBalance));

    let waver_counts = {

    } 

    let waveCount;
    waveCount = await waveContract.getTotalWaves();
    console.log(waveCount)

    await waveFromUser(randomPerson, waveContract, waver_counts, "HI MOM");
    await waveFromUser(randomPerson, waveContract, waver_counts, "Maeajasd");
    await waveFromUser(randomTwo, waveContract, waver_counts, "i sia are bprogammer");
    await waveFromUser(randomPerson, waveContract, waver_counts, "texas sux");
    await waveFromUser(random3, waveContract, waver_counts, "I can't see good");

    waveCount = await waveContract.getTotalWaves();

    const allWaves = await waveContract.getAllWaves();
    console.log(allWaves);

    contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
    console.log("Contract balance: ", hre.ethers.utils.formatEther(contractBalance));

    
};

const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };

runMain();

// npx hardhat run scripts/run.js
// injects hre object
// in project we'll actually deploy to the real testnet

