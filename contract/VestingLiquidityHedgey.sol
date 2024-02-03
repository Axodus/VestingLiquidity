// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/security/Pausable.sol";

contract LiquidityPoolInteractor is Ownable, ReentrancyGuard, Pausable {
    address public liquidityPoolAddress;
    IERC20 public wrappedToken;

    uint256 public blockCounter;
    uint256 public transferInterval = 200;
    uint256 public maxAllowance;

    event TokensDeposited(address indexed from, uint256 amount);
    event ContractApproved(address indexed sender, uint256 amount);
    event TokensWithdrawn(address indexed to, uint256 amount);
    event MaxAllowanceChanged(uint256 newMaxAllowance);

    constructor(address _liquidityPoolAddress, address _wrappedToken, uint256 _maxAllowance) {
        require(_liquidityPoolAddress != address(0), "Invalid Liquidity Pool address");
        require(_wrappedToken != address(0), "Invalid wrapped token address");

        liquidityPoolAddress = _liquidityPoolAddress;
        wrappedToken = IERC20(_wrappedToken);
        maxAllowance = _maxAllowance;

        // Initialize the block counter
        blockCounter = block.number;
    }

    function depositAndTransfer(uint256 amount) external whenNotPaused {
        require(amount > 0, "Deposit amount must be greater than 0");

        // Ensure the sender has approved this contract to spend their wrapped tokens
        require(wrappedToken.allowance(msg.sender, address(this)) >= amount, "Not enough allowance");

        // Transfer tokens from sender to this contract
        require(wrappedToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Check if the transfer interval has passed and execute transfer to the Liquidity Pool
        if (block.number - blockCounter >= transferInterval) {
            executeTransferToLiquidityPool();
            // Reset the block counter
            blockCounter = block.number;
        }

        emit TokensDeposited(msg.sender, amount);
    }

    function approveContract(uint256 amount) external onlyOwner whenNotPaused {
        // Approve this contract to spend the specified amount of tokens
        require(amount <= maxAllowance, "Exceeds maximum allowance");
        wrappedToken.approve(address(this), amount);

        emit ContractApproved(msg.sender, amount);
    }

    function withdrawal(address to, uint256 amount) external onlyOwner nonReentrant whenNotPaused {
        require(to != address(0), "Invalid withdrawal address");
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(wrappedToken.balanceOf(address(this)) >= amount, "Insufficient balance");

        // Transfer tokens from the contract to the specified address
        require(wrappedToken.transfer(to, amount), "Transfer failed");

        emit TokensWithdrawn(to, amount);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        super.transferOwnership(newOwner);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function automatedWithdrawalToPool() external whenNotPaused {
        // Check if the transfer interval has passed and execute transfer to the Liquidity Pool
        if (block.number - blockCounter >= transferInterval) {
            executeTransferToLiquidityPool();
            // Reset the block counter
            blockCounter = block.number;
        }
    }

    // Internal function to execute the transfer to the Liquidity Pool
    function executeTransferToLiquidityPool() internal {
        // Transfer total tokens from this contract to the Liquidity Pool address
        uint256 contractBalance = wrappedToken.balanceOf(address(this));
        if (contractBalance > 0) {
            require(wrappedToken.transfer(liquidityPoolAddress, contractBalance), "Transfer to Liquidity Pool failed");
        }
    }

    function setMaxAllowance(uint256 newMaxAllowance) external onlyOwner {
        maxAllowance = newMaxAllowance;
        emit MaxAllowanceChanged(newMaxAllowance);
    }
}
