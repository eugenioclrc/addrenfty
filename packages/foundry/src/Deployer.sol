// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Owned} from "solmate/auth/Owned.sol";
import {CREATE3} from "solmate/utils/CREATE3.sol";
import {MultichainDeployer} from "./MultichainDeployer.sol";
import {Addrenfty} from "./Addrenfty.sol";

//@dev this contract will be deployed using create2 deployer contract
contract Deployer is Owned {
    bool public deployed;
    address public deployedAddress;

    constructor(address _owner) Owned(_owner) {}

    function deploy(bool isMainnet) external payable {
        require(!deployed, "ALREADY_DEPLOYED");
        deployed = true;

        if (isMainnet) {
            // deploy addrenfty on mainnet
            deployedAddress = CREATE3.deploy(bytes32("WAGMI"), type(Addrenfty).creationCode, 0);
        } else {
            // deploy multichain deployer other networks
            deployedAddress = CREATE3.deploy(
                bytes32("WAGMI"), abi.encodePacked(type(MultichainDeployer).creationCode, abi.encode(owner)), 0
            );
        }
    }
}
