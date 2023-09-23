// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Addrenfty} from "../src/Addrenfty.sol";
import {Wanted} from "../src/Wanted.sol";

contract WantedTest is Test {
    Addrenfty public addrenfty;
    Wanted public wanted;

    function setUp() public {
        addrenfty = new Addrenfty();
        wanted = new Wanted(addrenfty);
    }

    function test_mintSameSaltFromDifferentAddressShouldBeDifferent() public {
        
        address buyer = makeAddr("buyer");
        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        wanted.createBounty{value: 1 ether}(hex"0C");

        address minter = makeAddr("minter");
        
        vm.startPrank(minter);
        uint256 wrongNft = addrenfty.mint(bytes32("32"));
        uint256 wantedNft = addrenfty.mint(bytes32("33"));

        addrenfty.approve(address(wanted), wrongNft);
        addrenfty.approve(address(wanted), wantedNft);
        
        vm.expectRevert("INVALID_NOT_WANTED");
        wanted.claimBounty(0, wrongNft);
        wanted.claimBounty(0, wantedNft);

        assertEq(addrenfty.ownerOf(wantedNft), buyer, "buyer should own the nft");
        assertEq(minter.balance, 1 ether, "minter should have the bounty");

    }
}
