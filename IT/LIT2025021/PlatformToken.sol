// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PlatformToken {
    string public name = "Marketplace Token";
    string public symbol = "MPT";
    uint8 public decimals = 18;

    uint256 public constant RATE = 100000;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) public allowance;
    event TokensMinted(address indexed user, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    // Mint tokens by sending ETH
    function mintTokens() external payable {
        require(msg.value > 0, "Send ETH to mint tokens");

        uint256 tokensToMint = msg.value * RATE;
        balances[msg.sender] += tokensToMint;

        emit TokensMinted(msg.sender, tokensToMint);
    }

    function balanceOf(address user) external view returns (uint256) {
        return balances[user];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balances[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Not approved");

        allowance[from][msg.sender] -= amount;
        balances[from] -= amount;
        balances[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }
}
