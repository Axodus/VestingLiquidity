// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/Ownable.sol";

contract VestingLiquidityHedgey is Ownable {
    address public receiverWallet;
    address public poolAddress;
    IERC20 public wrappedToken;
    
    uint256 public blockCounter;
    uint256 public transferInterval = 100;

    event TokensDeposited(address indexed from, uint256 amount);
    event ContractApproved(address indexed sender, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TokensWithdrawn(address indexed to, uint256 amount);

    constructor(address _receiverWallet, address _poolAddress, address _wrappedToken) {
        require(_receiverWallet != address(0), "Invalid receiver wallet address");
        require(_poolAddress != address(0), "Invalid pool address");
        require(_wrappedToken != address(0), "Invalid wrapped token address");

        receiverWallet = _receiverWallet;
        poolAddress = _poolAddress;
        wrappedToken = IERC20(_wrappedToken);
        
        // Initialize the block counter
        blockCounter = block.number;
    }

    // Function to deposit wrapped tokens and transfer to the pool
    function depositAndTransfer(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than 0");

        // Ensure the sender has approved this contract to spend their wrapped tokens
        require(wrappedToken.allowance(msg.sender, address(this)) >= amount, "Not enough allowance");

        // Transfer tokens from sender to this contract
        require(wrappedToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Optionally, you can perform additional logic or emit events here
        
        // Check if 100 blocks have passed and execute transfer to pool
        if (block.number - blockCounter >= transferInterval) {
            executeTransferToPool();
            // Reset the block counter
            blockCounter = block.number;
        }
    }

    // Approve the contract to spend a certain amount of wrapped tokens
    function approveContract(uint256 amount) external onlyOwner {
        // Approve this contract to spend the specified amount of tokens
        wrappedToken.approve(address(this), amount);

        emit ContractApproved(msg.sender, amount);
    }

    // Withdraw wrapped tokens from the contract (only callable by the owner)
    function withdrawal(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid withdrawal address");
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(wrappedToken.balanceOf(address(this)) >= amount, "Insufficient balance");

        // Transfer tokens from the contract to the specified address
        require(wrappedToken.transfer(to, amount), "Transfer failed");

        emit TokensWithdrawn(to, amount);
    }

    // Transfer ownership to a new owner (only callable by the current owner)
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner(), newOwner);
        _transferOwnership(newOwner);
    }
    
    // Internal function to execute the transfer to the pool
    function executeTransferToPool() internal {
        // Transfer tokens from this contract to the pool address
        uint256 contractBalance = wrappedToken.balanceOf(address(this));
        if (contractBalance > 0) {
            require(wrappedToken.transfer(poolAddress, contractBalance), "Transfer to pool failed");
        }
    }
}
