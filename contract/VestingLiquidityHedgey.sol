// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC20/IERC20.sol";

contract VestingLiquidityHedgey {
    address public receiverWallet;
    address public poolAddress;
    IERC20 public wrappedToken;

    constructor(address _receiverWallet, address _poolAddress, address _wrappedToken) {
        require(_receiverWallet != address(0), "Invalid receiver wallet address");
        require(_poolAddress != address(0), "Invalid pool address");
        require(_wrappedToken != address(0), "Invalid wrapped token address");

        receiverWallet = _receiverWallet;
        poolAddress = _poolAddress;
        wrappedToken = IERC20(_wrappedToken);
    }

    // Function to deposit wrapped tokens and transfer to the pool
    function depositAndTransfer(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than 0");

        // Ensure the sender has approved this contract to spend their wrapped tokens
        require(wrappedToken.allowance(msg.sender, address(this)) >= amount, "Not enough allowance");

        // Transfer tokens from sender to this contract
        require(wrappedToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Transfer tokens from this contract to the pool address
        require(wrappedToken.transfer(poolAddress, amount), "Transfer to pool failed");

        // Optionally, you can perform additional logic or emit events here
    }

    // Approve the contract to spend a certain amount of wrapped tokens
    function approveContract(uint256 amount) external {
        // Approve this contract to spend the specified amount of tokens
        wrappedToken.approve(address(this), amount);
    }
}
