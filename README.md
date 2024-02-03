# Axodus Pool V2 Interactor
## Introduction
This script, named "Axodus Pool V2 Interactor," is designed to automate the withdrawal of funds to a Liquidity Pool Address in a Uniswap V2 contract. The script is written in JavaScript and utilizes the web3.js library for Ethereum interaction.

## Prerequisites
Before running the script, ensure you have the following:

Node.js: Make sure Node.js is installed on your machine. You can download it from nodejs.org.

Dependencies: Install project dependencies using the following command:
```
npm install
```
## Configuration
Adjust the .env file with your specific configuration:
Environment Variables: Create a .env file in the project directory with the following variables:
```
MNEMONIC=your_mnemonic_phrase // Your wallet's mnemonic phrase.
INFURA_API_KEY=your_infura_api_key //  Your Infura API key.
CONTRACT_ADDRESS=your_contract_address // The address of the target smart contract.
OWNER_ADDRESS=your_owner_address // The owner's wallet address.
PRIVATE_KEY=your_private_key // The private key corresponding to the owner's wallet.
```

## Execution
To run the script, execute the following command:

## If you are using npm
```
npm install
```
## If you are using Yarn
```
yarn install
```
After installing the dependencies, you can start your interactor script with the command:

## If you are using npm
```
npm start
```
## If you are using Yarn
```
yarn start
```
This command will run the interactor.js script using Node.js.

# Functionality
Automated Withdrawal to Pool

The script checks if it's possible to call the automatedWithdrawalToPool function on the target contract.

If allowed, it constructs and sends a transaction to execute the withdrawal.

The script waits for a confirmation and logs the transaction hash.

Execution Interval

The script is set to execute the main function every 60 minutes using setInterval.
Security Considerations
Private Key: Ensure that the private key is kept secure and not exposed.

Testing: Test the script on a testnet before using it on the mainnet.

Customization
Feel free to modify the script according to your specific requirements. Adjust gas parameters, confirmation counts, or any other parameters as needed.

License
This script is provided under the MIT License. You can find the license details in the source code.
