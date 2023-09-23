// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Owned} from "solmate/auth/Owned.sol";
import {CREATE3} from "solmate/utils/CREATE3.sol";

contract MultichainDeployer is Owned {
    mapping(address deployer => bool enabled) public isDeployer;

    constructor(address _owner) Owned(_owner) {
        isDeployer[_owner] = true;
    }

    function setDeployer(address deployer, bool status) external onlyOwner {
        isDeployer[deployer] = status;
    }

    function deploy(bytes32 salt, bytes memory bytecode) external payable {
        require(isDeployer[msg.sender], "NOT_AUTHORIZED");
        CREATE3.deploy(salt, bytecode, msg.value);
    }
}
