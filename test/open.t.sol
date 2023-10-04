// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Openmarket} from "../src/openmarket.sol";
contract OpenTest is Test {
    Openmarket public open;

    function Testsignature() public {
        uint256 privatekey = 0x1234;
        address publickey = vm.addr(privatekey);
        byte32 messagehash = keccak256("secret message");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(messagehash, privatekey);
        address signer = ecrecover(messagehash, v, r, s);
        assertEql(signer, publickey);
}
}