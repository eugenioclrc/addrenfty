// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Deployer, Owned} from "../src/Deployer.sol";

import {Strings} from "openzeppelin/utils/Strings.sol";

contract DeployTest is Test {
    Deployer public deployer;
    address public owner;

    address predictedAddress = 0xcBd28A33546c25c490DbfC85F8a8ef4C4e48825A;

    function setUp() public {
        owner = makeAddr("owner");

        // mock the create2deployer contract deployed on multiple chains
        vm.etch(
            0x7A0D94F55792C434d74a40883C6ed8545E406D12,
            hex"60003681823780368234f58015156014578182fd5b80825250506014600cf3"
        );
        0x7A0D94F55792C434d74a40883C6ed8545E406D12.call(
            abi.encodePacked(type(Deployer).creationCode, abi.encode(owner))
        );
        deployer = Deployer(0x196854FCf6a06bb6CAD6e78e1Bc278ae99eA82A7);
    }

    function test_deployMainAddrenfty() public {
        deployer.deploy(false);
        assertEq(deployer.deployed(), true, "deployed should be true");

        assertEq(deployer.deployedAddress(), predictedAddress, "deployedAddress should be predictedAddress");
    }

    function test_deployMultichain() public {
        assertEq(deployer.owner(), owner, "owner should be owner");
        deployer.deploy(false);
        assertEq(deployer.deployed(), true, "deployed should be true");
        assertNotEq(deployer.deployedAddress(), address(0), "deployedAddress should be 0");

        assertEq(Owned(deployer.deployedAddress()).owner(), owner, "owner should own deployed contract");
        assertEq(deployer.deployedAddress(), predictedAddress, "deployedAddress should be predictedAddress");
    }
}
