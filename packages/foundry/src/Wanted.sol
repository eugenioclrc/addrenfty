// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Addrenfty} from "./Addrenfty.sol";

contract Wanted {
    Addrenfty public immutable addrenfty;
    mapping(uint256 => Bounty) public bounties;

    uint256 bountiesCreated;

    struct Bounty {
        address owner;
        bool isClaimed;
        uint48 cancelTime;
        uint128 amount;
        bytes leadingBytes;
    }

    constructor(Addrenfty _addrenfty) {
        addrenfty = _addrenfty;
    }

    function createBounty(bytes calldata leadingBytes) external payable {
        require(msg.value > 1000, "INVALID_AMOUNT");
        require(leadingBytes.length < 16, "INVALID_LEADING_BYTES");
        require(leadingBytes.length > 0, "INVALID_LEADING_BYTES");

        bounties[bountiesCreated] = Bounty({
            owner: msg.sender,
            isClaimed: false,
            cancelTime: 0,
            amount: uint128(msg.value),
            leadingBytes: leadingBytes
        });

        bountiesCreated++;
    }

    function claimBounty(uint256 bountyId, uint256 nftId) external {
        Bounty storage bounty = bounties[bountyId];
        require(!bounty.isClaimed, "ALREADY_CLAIMED");
        require(bounty.cancelTime < block.timestamp + 1 hours, "CANCELLED");
        require(addrenfty.ownerOf(nftId) == msg.sender, "NOT_OWNER");

        // @todo probably using a mask would be better and cheaper, for now lets keep it simple
        bytes20 byteAddr = bytes20(address(uint160(nftId)));
        for (uint256 i; i < bounty.leadingBytes.length; i++) {
            if (bounty.leadingBytes[i] != byteAddr[i]) {
                revert("INVALID_NOT_WANTED");
            }
        }

        /// @dev this will be useful to avoid reentrancy
        bounty.isClaimed = true;
        bounty.cancelTime = uint48(block.timestamp + 1 days);

        payable(msg.sender).transfer(bounty.amount);
        addrenfty.transferFrom(msg.sender, bounty.owner, nftId);
    }
}
