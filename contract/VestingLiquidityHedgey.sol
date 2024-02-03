// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/security/ReentrancyGuard.sol";

contract VestingLiquidityHedgey is Ownable, ReentrancyGuard {
    address public poolAddress;
    IERC20 public wrappedToken;
    
    uint256 public blockCounter;
    uint256 public transferInterval = 100;

    event TokensDeposited(address indexed from, uint256 amount);
    event ContractApproved(address indexed sender, uint256 amount);
    event TokensWithdrawn(address indexed to, uint256 amount);

    constructor(address _poolAddress, address _wETH) {
        require(_poolAddress != address(0), "Invalid pool address");
        require(_wETH != address(0), "Invalid wrapped token address");

        poolAddress = _poolAddress;
        wrappedToken = IERC20(_wETH);
        
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

        // Transfer all deposited tokens to the pool immediately
        executeTransferToPool();

        // Optionally, you can perform additional logic or emit events here
        
        // Reset the block counter
        blockCounter = block.number;
    }

    // Approve the contract to spend a certain amount of wrapped tokens
    function approveContract(uint256 amount) external onlyOwner {
        // Approve this contract to spend the specified amount of tokens
        wrappedToken.approve(address(this), amount);

        emit ContractApproved(msg.sender, amount);
    }

    // Withdraw wrapped tokens from the contract (only callable by the owner)
    function withdrawal(address to, uint256 amount) external onlyOwner nonReentrant {
        require(to != address(0), "Invalid withdrawal address");
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(wrappedToken.balanceOf(address(this)) >= amount, "Insufficient balance");

        // Transfer tokens from the contract to the specified address
        require(wrappedToken.transfer(to, amount), "Transfer failed");

        emit TokensWithdrawn(to, amount);
    }

    // Transfer ownership to a new owner (only callable by the current owner)
    function transferOwnership(address newOwner) public onlyOwner override {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner(), newOwner);
        _transferOwnership(newOwner);
    }
    
    // Internal function to execute the transfer to the pool
    function executeTransferToPool() internal {
        // Transfer total tokens from this contract to the pool address
        uint256 contractBalance = wrappedToken.balanceOf(address(this));
        if (contractBalance > 0) {
            require(wrappedToken.transfer(poolAddress, contractBalance), "Transfer to pool failed");
        }
    }
}
