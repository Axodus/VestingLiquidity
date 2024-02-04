const Web3 = require('web3');
const { abi, evm } = require('./LiquidityInteractor.json');
const HDWalletProvider = require('@truffle/hdwallet-provider');
const dotenv = require('dotenv');

dotenv.config();

//const provider = new HDWalletProvider(process.env.MNEMONIC, `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`);
const provider = new HDWalletProvider(process.env.MNEMONIC, `https://api.harmony.one`);
const web3 = new Web3(provider);

const contractAddress = process.env.CONTRACT_ADDRESS;
const ownerAddress = process.env.OWNER_ADDRESS;
const privateKey = process.env.PRIVATE_KEY;

const contract = new web3.eth.Contract(abi, contractAddress);

async function main() {
    try {
        const canCallFunction = await contract.methods.automatedWithdrawalToPool().call({ from: ownerAddress });

        if (canCallFunction) {
            // ... (the rest of your function remains unchanged)

            console.log('Transaction Hash:', receipt.transactionHash);

            // Wait for confirmation (adjust as needed)
            const confirmationCount = 3; // Adjust as needed
            const receiptConfirmed = await web3.eth.waitForTransactionConfirmation(receipt.transactionHash, confirmationCount);

            if (receiptConfirmed) {
                console.log('Transaction confirmed.');
            } else {
                console.log('Transaction confirmation failed.');
            }
        } else {
            console.log('The automatedWithdrawalToPool function cannot be called at the moment.');
        }
    } catch (error) {
        console.error('Error:', error);
    } finally {
        provider.engine.stop();
    }
}

// Call main function every 60 minutes
setInterval(main, 60 * 60 * 1000); // 60 minutes * 60 seconds/minute * 1000 milliseconds/second

// Call main immediately to run it at the start
main();

