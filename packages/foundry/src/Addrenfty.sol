// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {CREATE3} from "solmate/utils/CREATE3.sol";

contract Addrenfty is ERC721("AddreNFTy", "ADNFT") {
    mapping(uint256 id => bool isDeployed) public isDeployed;
    mapping(uint256 id => bytes32 salt) public _saltOf;

    function mint(bytes32 senderSalt) external returns (uint256 id) {
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, senderSalt));

        address nftAddr = CREATE3.getDeployed(salt);
        require(nftAddr.code.length == 0, "IN_USE_ADDRESS");
        
        id = uint256(uint160(nftAddr));
        _saltOf[id] = salt;
        _safeMint(msg.sender, id);
    }

    function deploy(uint256 id, bytes memory bytecode) external payable {
        require(bytecode.length != 0, "NO_BYTECODE");
        require(_saltOf[id] != 0, "NOT_MINTED");
        require(
            msg.sender == _ownerOf[id] || isApprovedForAll[_ownerOf[id]][msg.sender] || msg.sender == getApproved[id], "NOT_AUTHORIZED"
        );
        address nftAddr = address(uint160(id));
        require(nftAddr.code.length == 0, "IN_USE_ADDRESS");

        nftAddr = CREATE3.deploy(_saltOf[id], bytecode, msg.value);
    }

    function transferFrom(address from, address to, uint256 id) public override {
        require(!isDeployed[id], "SOULBOUNDED");
        super.transferFrom(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes calldata data) public override {
        require(!isDeployed[id], "SOULBOUNDED");
        super.safeTransferFrom(from, to, id, data);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "TODO";
    }
/*
useful for rendering
    function bytesToString(bytes memory _data) public pure returns (string memory) {
        string memory result = string(_data);
        return result;
    }
*/
}
