// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Deployer} from "../src/Deployer.sol";

interface Create2Deployer {
    function safeCreate2(bytes32 salt, bytes calldata initializationCode)
        external
        payable
        returns (address deploymentAddress);
}

contract CounterScript is Script {
    address constant CREATE2DEPLOYER = 0x0000000000FFe8B47B3e2130213B802212439497;

    function setUp() public {}

    function run() public {
        require(msg.sender == 0x0000003FA6D1d52849db6E9EeC9d117FefA2e200, "msg.sender is not the expected");
        vm.startBroadcast();
        // (address(bytes20(salt))
        Create2Deployer(CREATE2DEPLOYER).safeCreate2(
            //bytes32(bytes20(address(0x0000003FA6D1d52849db6E9EeC9d117FefA2e200))),
            0x0000003fa6d1d52849db6e9eec9d117fefa2e200000000000000000000000001,
            abi.encodePacked(type(Deployer).creationCode, abi.encode(msg.sender))
        );
        Deployer(0x3A7d8E40Deb0b05fD32Cef705b4865d2041bd575).deploy(true);
    }
}
