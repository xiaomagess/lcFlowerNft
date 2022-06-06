// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Box.sol";

contract AirdropBox is Ownable {
    Box public boxContract;

    uint256 public startTime;

    address public signerUser;

    mapping(bytes => bool) public signatureUsed;

    event ClaimAirdrop(address indexed from, uint256 indexed tokenId);
    constructor(address _address) {
        boxContract = Box(_address);
    }

    /// @dev Checks if the airdrop is start.
    modifier checkTime() {
        require(block.timestamp >= startTime, "time not start");
        _;
    }

    function getBlockTime() public view returns (uint256) {
        return block.timestamp;
    }

    /// @dev set start status of the airdrop.
    function setStartTime(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
    }

    function setSigner(address _signerUser) public onlyOwner {
        signerUser = _signerUser;
    }

    function verifySignature(string calldata key, bytes calldata signature)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(abi.encodePacked(key, msg.sender));
        bytes32 message = ECDSA.toEthSignedMessageHash(hash);
        address receivedAddress = ECDSA.recover(message, signature);
        return receivedAddress;
    }

    /// @dev Redeems claimed box.
    function claimAirdrop(string calldata key, bytes calldata signature)
        external
        checkTime
    {
        require(!signatureUsed[signature], "signature has already been used.");
        require(
            verifySignature(key, signature) == signerUser,
            "no permissions"
        );
        uint256 tokenId =  boxContract.mint(msg.sender);
        signatureUsed[signature] = true;
        emit ClaimAirdrop(msg.sender,tokenId);
    }
}
