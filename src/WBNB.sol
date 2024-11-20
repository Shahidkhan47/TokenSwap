// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract WBNB is ERC20, Ownable, ERC20Permit {
    constructor()
        ERC20("WBNB", "WBNB")
        Ownable(msg.sender)
        ERC20Permit("WBNB")
    {
        _mint(msg.sender, 1000000000 * 1e18);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}