const Web3 = require('web3');
const { abi } = require('./LiquidityInteractor.json'); // Replace with your contract ABI
const HDWalletProvider = require('@truffle/hdwallet-provider');
const dotenv = require('dotenv');

dotenv.config();

const provider = new HDWalletProvider(process.env.PRIVATE_KEY, `https://api.harmony.one`);
const web3 = new Web3(provider);

const contractAddress = process.env.CONTRACT_ADDRESS;
const ownerAddress = process.env.OWNER_ADDRESS;
const wethTokenAddress = process.env.WETH_TOKEN_ADDRESS; // Replace with the actual WETH token address

const contract = new web3.eth.Contract(abi, contractAddress);

async function sendTokensToContract(amount) {
    // Ensure the sender has approved this contract to spend their WETH tokens
    const allowance = await contract.methods.allowance(ownerAddress, contractAddress).call();
    if (allowance < amount) {
        const approveTx = contract.methods.approve(contractAddress, amount);
        const approveReceipt = await sendTransaction(ownerAddress, approveTx);
        // Handle approval confirmation logic if needed
    }

    // Transfer tokens from owner to this contract
    const transferTx = contract.methods.transferFrom(ownerAddress, contractAddress, amount);
    const transferReceipt = await sendTransaction(ownerAddress, transferTx);

    // Handle transfer confirmation logic if needed
}

async function sendTransaction(from, transaction) {
    const gasPrice = await web3.eth.getGasPrice();
    const gasLimit = 500000;

    const transactionObject = {
        from: from,
        to: transaction._parent._address,
        gasPrice,
        gas: gasLimit,
        data: transaction.encodeABI(),
        nonce: await web3.eth.getTransactionCount(from, 'pending'),
    };

    const signedTransaction = await web3.eth.accounts.signTransaction(transactionObject, process.env.PRIVATE_KEY);
    const receipt = await web3.eth.sendSignedTransaction(signedTransaction.rawTransaction);

    return receipt;
}

async function main() {
    try {
        await sendTokensToContract(100); // Replace 100 with the amount of WETH tokens to send

        // Check if automatedWithdrawalToPool can be called
        const canCallFunction = await contract.methods.automatedWithdrawalToPool().call({ from: ownerAddress });

        if (canCallFunction) {
            const withdrawalTx = contract.methods.automatedWithdrawalToPool();
            const withdrawalReceipt = await sendTransaction(ownerAddress, withdrawalTx);

            // Wait for confirmation (adjust as needed)
            const confirmationCount = 3; // Adjust as needed
            const receiptConfirmed = await web3.eth.waitForTransactionConfirmation(withdrawalReceipt.transactionHash, confirmationCount);

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
