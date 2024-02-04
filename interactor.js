const Web3 = require('web3');
const { abi } = require('./LiquidityInteractor.json'); // Replace with your contract ABI
const wETHAbi = require('./_wETH.json'); // Replace with the actual path to _wETH.json
const HDWalletProvider = require('@truffle/hdwallet-provider');
const dotenv = require('dotenv');

dotenv.config();

const provider = new HDWalletProvider(process.env.PRIVATE_KEY, `https://api.harmony.one`);
const web3 = new Web3(provider);

const contractAddress = process.env.CONTRACT_ADDRESS;
const ownerAddress = process.env.OWNER_ADDRESS;
const wethTokenAddress = process.env.WETH_TOKEN_ADDRESS; // Replace with the actual WETH token address

const contract = new web3.eth.Contract(abi, contractAddress);
const wETHContract = new web3.eth.Contract(wETHAbi, wethTokenAddress);


async function sendTokensToContract(amount) {
    const allowance = await contract.methods.allowance(ownerAddress, contractAddress).call();
     // Use the wETHContract instance to interact with the WETH token contract
     const allowance = await wETHContract.methods.allowance(ownerAddress, contractAddress).call();

    if (allowance < amount) {
        const approveTx = contract.methods.approve(contractAddress, amount);
        const approveReceipt = await sendTransaction(ownerAddress, approveTx);

        console.log('Approval Transaction Receipt:', approveReceipt.transactionHash);
        if (approveReceipt.status) {
            console.log('Approval was successful.');
        } else {
            console.log('Approval failed.');
        }
    }

    const transferTx = contract.methods.transferFrom(ownerAddress, contractAddress, amount);
    const transferReceipt = await sendTransaction(ownerAddress, transferTx);

    console.log('Transfer Transaction Receipt:', transferReceipt.transactionHash);
    if (transferReceipt.status) {
        console.log('Transfer was successful.');
    } else {
        console.log('Transfer failed.');
    }
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
        await sendTokensToContract(100);

        const canCallFunction = await contract.methods.automatedWithdrawalToPool().call({ from: ownerAddress });

        if (canCallFunction) {
            const withdrawalTx = contract.methods.automatedWithdrawalToPool();
            const withdrawalReceipt = await sendTransaction(ownerAddress, withdrawalTx);

            const confirmationCount = 3;
            const receiptConfirmed = await web3.eth.waitForTransactionConfirmation(
                withdrawalReceipt.transactionHash,
                confirmationCount
            );

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
setInterval(main, 60 * 60 * 1000);
// Call main immediately to run it at the start
main();
