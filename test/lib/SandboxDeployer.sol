// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract SandboxDeployer is Test {
    function deploy(address owner) public returns (address) {
        bytes memory bytecode = getBytecode(owner);

        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(deployedAddress != address(0), "Could not deploy Sandbox");

        return deployedAddress;
    }

    function getHeaderBytecode() public returns (bytes memory) {
        string memory bashCommand = string.concat(
            'cast abi-encode "f(bytes)" $(solc --strict-assembly yul/Sandbox.yul --bin | tail -1 | cut -c -28)'
        );

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        return abi.decode(vm.ffi(inputs), (bytes));
    }

    function getFooterBytecode() public returns (bytes memory) {
        string memory bashCommand = string.concat(
            'cast abi-encode "f(bytes)" $(solc --strict-assembly yul/Sandbox.yul --bin | tail -1 | cut -c 69-)'
        );

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        return abi.decode(vm.ffi(inputs), (bytes));
    }

    function getBytecode(address owner) public returns (bytes memory) {
        return abi.encodePacked(getHeaderBytecode(), owner, getFooterBytecode());
    }
}
