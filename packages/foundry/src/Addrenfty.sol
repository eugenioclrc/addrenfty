// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {CREATE3} from "solmate/utils/CREATE3.sol";
import {Strings} from "openzeppelin/utils/Strings.sol";
import {Base64} from "openzeppelin/utils/Base64.sol";

contract Addrenfty is ERC721("AddreNFTy", "ADNFT") {
    using Strings for uint256;

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
        require(!isDeployed[id], "ALREADY_DEPLOYED");
        require(
            msg.sender == _ownerOf[id] || isApprovedForAll[_ownerOf[id]][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );
        isDeployed[id] = true;
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
        require(_saltOf[id] != 0, "NOT_MINTED");
        return string.concat("data:image/svg+xml;base64,", Base64.encode(bytes(renderSvg(id))));
    }

    function renderSvg(uint256 id) public view returns (string memory) {
        string memory _nft = Strings.toHexString(address(uint160(id)));
        string memory head =
            '<svg width="400" height="450" xmlns="http://www.w3.org/2000/svg"><defs><filter id="a" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur in="SourceGraphic" stdDeviation="2" result="blur-out"/><feMerge><feMergeNode in="blur-out"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs><rect width="398" height="448" fill="#fff" stroke="#000" stroke-width="2" rx="20" ry="20"/><rect x="20" y="20" width="360" height="60" fill="#D32F2F" rx="10" ry="10"/><text x="200" y="60" font-family="Arial" font-size="28" fill="#fff" text-anchor="middle">AddreNFTy<animate attributeName="font-size" values="28;34;28" dur="2s" repeatCount="indefinite"/></text><rect x="20" y="100" width="360" height="320" fill="#E0E0E0" rx="10" ry="10"/><text x="34" y="170" font-family="Courier New" font-size="16" text-anchor="middle" filter="url(#a)">0x</text>';

        string memory body = string.concat(
            svgTextLine(200, 170, getAddressChunk(_nft, 2)),
            svgTextLine(200, 235, getAddressChunk(_nft, 12)),
            svgTextLine(200, 300, getAddressChunk(_nft, 22)),
            svgTextLine(200, 370, getAddressChunk(_nft, 32))
        );

        return string.concat(head, body, "</svg>");
    }

    function svgTextLine(uint256 x, uint256 y, string memory str) internal pure returns (string memory) {
        return string.concat(
            '<text x="',
            x.toString(),
            '" y="',
            y.toString(),
            '" font-family="Courier New" font-size="36" text-anchor="middle" filter="url(#a)">',
            str,
            "</text>"
        );
    }

    function getAddressChunk(string memory str, uint256 start) internal pure returns (string memory chunk) {
        chunk = string.concat(slice(str, start, 2));
        for (uint256 i = start + 2; i < start + 10; i += 2) {
            chunk = string.concat(chunk, " ", slice(str, i, 2));
        }
    }

    // utils slice and transform hex address to string, to render the nft (source stack overflow)
    function slice(string memory _str, uint256 _start, uint256 _length) internal pure returns (string memory) {
        bytes memory strBytes = bytes(_str);
        bytes memory result = new bytes(_length);

        for (uint256 i; i < _length; ++i) {
            result[i] = strBytes[_start + i];
        }
        return string(result);
    }
}
