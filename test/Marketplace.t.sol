
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {Marketplace} from "../src/Marketplace2.sol";
import "../src/libraries/ERC721Mock.sol";
import "./Helpers.sol";
contract MarketplaceTest is Helpers {
    Marketplace marketplace;
    OurNFT nft;
    uint256 currentlistingId;
    address Fuser1;
    address Fuser2;

    uint256 privateKey1;
    uint256 privateKey2;

    Marketplace.Addlisting l;

    function setUp() public {
        marketplace = new Marketplace();
        nft = new OurNFT();

        (Fuser1, privateKey1) = mkaddr("USER1");
        (Fuser2, privateKey2) = mkaddr("USER2");

        l = Marketplace.Addlisting({
            token: address(nft),
            tokenId: 1,
            price: 1 ether,
            sig: bytes(""),
            deadline: 0,
            lister: address(0),
            active: false
        });

        nft.mint(Fuser1, 1);
    }
    function test_createListing() public {
        l.lister = Fuser1;
        switchSigner(Fuser2);

        vm.expectRevert("You are not the owner of this token");
        marketplace.createListing(l);

    }
    function testNotApproved() public {
        switchSigner(Fuser1);
        vm.expectRevert("not approve");
        marketplace.createListing(l);
    }

    function testMinlowprice()public{
        switchSigner(Fuser1);
        nft.setApprovalForAll(address(marketplace), true);
        l.price = 0;
        vm.expectRevert("Price must be greater than 0");
        marketplace.createListing(l);
    }
    function testdeadline() public {
        switchSigner(Fuser1);
        nft.setApprovalForAll(address(marketplace), true);
        vm.expectRevert("Deadline must be greater than current time");
        marketplace.createListing(l);
    }
    function testduration() public {
        switchSigner(Fuser1);
        nft.setApprovalForAll(address(marketplace), true);
        l.lister = Fuser1;
        l.deadline = uint88(block.timestamp + 59 minutes);
        l.sig = constructSig(
            l.token,
            l.tokenId,
            l.price,
            l.deadline,
            l.lister,
            privateKey1
        );
        vm.expectRevert("Deadline must be greater than price");
        marketplace.createListing(l);
    }
    function testvalidsignature() public {
        switchSigner(Fuser1);
        nft.setApprovalForAll(address(marketplace), true);
        l.deadline = uint88(block.timestamp + 120 minutes);
        l.sig = constructSig(
            l.token,
            l.tokenId,
            l.price,
            l.deadline,
            l.lister,
            privateKey2
        );
        vm.expectRevert(Marketplace.InvalidAddress.selector);
        marketplace.createListing(l);
    }
    function testeditlisting() public {
        switchSigner(Fuser1);
        vm.expectRevert("Listing is not active");
        marketplace.editListing(1, 0, false);
    }

    function testeditnonOwner()public{
         switchSigner(Fuser1);
        nft.setApprovalForAll(address(marketplace), true);
        l.deadline = uint88(block.timestamp + 120 minutes);
        l.sig = constructSig(
            l.token,
            l.tokenId,
            l.price,
            l.deadline,
            l.lister,
            privateKey1
        );
        
        uint256 lId = marketplace.createListing(l);

        switchSigner(Fuser1);
        marketplace.editListing(lId, 0, false);
        vm.expectRevert("Listing is expired");
    }
    function testexecutenonactive() public {
        switchSigner(Fuser1);
        vm.expectRevert("Not enough value");
        marketplace.executeListing(1);
    }
    function testeditlist()public{
        switchSigner(Fuser1);
        vm.expectRevert("Listing is not active");
        marketplace.editListing(1, 0, false);

    }






}