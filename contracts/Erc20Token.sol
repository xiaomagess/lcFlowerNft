// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Erc20Token is ERC20, Ownable {
    constructor(string memory _name, string  memory _symbol, uint _totalSupply) ERC20(_name, _symbol) {
        _mint(msg.sender, _totalSupply * 10 ** decimals());
    }

    function mint(uint256 amount) public  {
        _mint(msg.sender, amount);
    }
}