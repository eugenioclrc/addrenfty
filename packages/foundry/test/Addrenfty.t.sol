// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Addrenfty} from "../src/Addrenfty.sol";

contract AddrenftyTest is Test {
    Addrenfty public addrenfty;

    function setUp() public {
        addrenfty = new Addrenfty();
    }

    function test_mintSameSaltFromDifferentAddressShouldBeDifferent() public {
        address minter1 = makeAddr("minter1");
        address minter2 = makeAddr("minter2");
        
        vm.prank(minter1);
        uint256 mintedByMinter1 = addrenfty.mint(bytes32("c0ffee"));
        vm.prank(minter2);
        uint256 mintedByMinter2 = addrenfty.mint(bytes32("c0ffee"));
        assertNotEq(mintedByMinter1, mintedByMinter2, "minted by different minter should be different");
    }

    function test_saltWorksAsExpected() public {
        bytes memory PROXY_BYTECODE = hex"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3";
        bytes32 PROXY_BYTECODE_HASH = keccak256(PROXY_BYTECODE);

        address minter = makeAddr("minter");
        bytes32 minterSalt = bytes32("Random Salt From minter");
        bytes32 salt = keccak256(abi.encodePacked(minter, minterSalt));

        address proxy = address(uint160(uint256(keccak256(abi.encodePacked(
                    // Prefix:
                    bytes1(0xFF),
                    // Creator:
                    address(addrenfty),
                    // Salt:
                    salt,
                    // Bytecode hash:
                    PROXY_BYTECODE_HASH
        )))));

        address predictedAddress = address(uint160(uint256(keccak256(
            abi.encodePacked(
                // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01)
                // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex)
                hex"d6_94",
                proxy,
                hex"01" // Nonce of the proxy contract (1)
            )))));
        
        vm.prank(minter);
        uint256 minted = addrenfty.mint(minterSalt);


        assertEq(address(uint160(minted)), predictedAddress);
    }
}
