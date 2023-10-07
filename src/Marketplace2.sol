// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";

import "solmate/tokens/ERC721.sol";
import {SignUtils} from "./libraries/SignUtils.sol"; 

contract Marketplace{
    struct Addlisting{
        address token;
        uint256 tokenId;
        uint256 price;
        bytes sig;
        uint88 deadline;
        address lister;
        bool active;

    }
    mapping(uint256 => Addlisting) public listings;
    address admin;
    uint256 listingId;

    error InvalidAddress();

    constructor(){
        admin = msg.sender;
    }
    function createListing(Addlisting calldata l)public returns(uint256 lid){
        require(ERC721(l.token).ownerOf(l.tokenId) == msg.sender,"You are not the owner of this token");
        require(ERC721(l.token).isApprovedForAll(msg.sender,address(this)),"not approve");
        require(l.price > 0,"Price must be greater than 0");
        require(l.deadline > block.timestamp,"Deadline must be greater than current time");
        
        //assert signature
        if (
            !SignUtils.isValid(
                SignUtils.constructMessageHash(
                    l.token,
                    l.tokenId,
                    l.price,
                    l.deadline,
                    l.lister
                ),
                l.sig,
                msg.sender
            )
        ) revert InvalidAddress();
        //append storage
        Addlisting storage li = listings[listingId];
        li.token = l.token;
        li.tokenId = l.tokenId;
        li.price = l.price;
        li.sig = l.sig;
        li.deadline = uint88(l.deadline);
        li.lister = msg.sender;
        li.active = true;
        console2.log("Listing created");
    }
        
    
    function executeListing(uint256 _listingId) public payable {
        require(listings[_listingId].active,"git");
        Addlisting storage l = listings[_listingId];
        require(l.deadline > block.timestamp,"Listing is expired");
        require(l.price <= msg.value,"Not enough value");
         l.active = false;
          ERC721(l.token).transferFrom(
            l.lister,
            msg.sender,
            l.tokenId
        );

        // transfer eth
        payable(l.lister).transfer(l.price);

    }

    function editListing(
        uint256 _listingId,
        uint256 _newPrice,
        bool _active
    ) public{
        require(listings[_listingId].active,"Listing is not active");
        Addlisting storage l = listings[_listingId];
        require(l.lister == msg.sender,"You are not the lister of this listing");
        l.price = _newPrice;
        l.active = _active;
    }
    function fetchListing(
        uint256 _listingId
    ) public view returns (Addlisting memory) {
        // if (_listingId >= listingId)
        return listings[_listingId];
    }
}    
    



















