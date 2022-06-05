// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SunToken is ERC20, Ownable {
    mapping(bytes => bool) public signatureUsed;
    address public signerUser;

    constructor(string memory _name, string  memory _symbol, uint _totalSupply) ERC20(_name, _symbol) {
        _mint(msg.sender, _totalSupply * 10 ** decimals());
    }

    function setSigner(address _signerUser) public onlyOwner {
        signerUser = _signerUser;
    }

    function receiveToken(uint256 amount,string calldata key, bytes calldata signature) external  {
        require(!signatureUsed[signature], "signature has already been used");
        require(
            verifySignature(amount,key, signature) == signerUser,
            "no permissions"
        );
        _transfer(address(this), msg.sender, amount);
         signatureUsed[signature] = true;
    }

    
    function verifySignature(uint256 amount,string calldata key, bytes calldata signature)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(abi.encodePacked(amount,key, msg.sender));
        bytes32 message = ECDSA.toEthSignedMessageHash(hash);
        address receivedAddress = ECDSA.recover(message, signature);
        return receivedAddress;
    }


    function withdraw(address _user) public onlyOwner {
        uint256 balance = this.balanceOf(address(this));
        _transfer(address(this), _user, balance);
    }   


}