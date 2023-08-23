// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library LibSandbox {
    bytes public constant header = hex"604380600d600039806000f3fe73";
    bytes public constant footer = hex"3314601d573d3dfd5b363d3d373d3d6014360360143d5160601c5af43d6000803e80603e573d6000fd5b3d6000f3";

    function bytecode(address owner) external pure returns (bytes memory) {
        return abi.encodePacked(header, owner, footer);
    }
}
