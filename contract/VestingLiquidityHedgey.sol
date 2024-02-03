// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WrappedTokenDepositor {
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

        // Assuming the sender has approved this contract to spend their wrapped tokens
        // You should implement the approval mechanism in your frontend or contract

        // Transfer tokens from sender to this contract
        wrappedToken.transferFrom(msg.sender, address(this), amount);

        // Transfer tokens from this contract to the pool address
        wrappedToken.transfer(poolAddress, amount);

        // Optionally, you can perform additional logic or emit events here
    }
}
