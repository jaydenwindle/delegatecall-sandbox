// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

contract CompileLibSandboxScript is Script {
    function setUp() public {}

    function run() public {
        bytes memory header = getHeaderBytecode("Sandbox");
        bytes memory footer = getFooterBytecode("Sandbox");

        string memory bashCommand = string.concat(
            "./script/replace-vars.sh ./src/lib/LibSandbox.sol ", vm.toString(header), " ", vm.toString(footer)
        );

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        vm.ffi(inputs);
    }

    function getHeaderBytecode(string memory fileName) public returns (bytes memory) {
        string memory bashCommand = string.concat(
            'cast abi-encode "f(bytes)" $(solc --strict-assembly yul/',
            string.concat(fileName, ".yul --bin | tail -1 | cut -c -28)")
        );

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        return abi.decode(vm.ffi(inputs), (bytes));
    }

    function getFooterBytecode(string memory fileName) public returns (bytes memory) {
        string memory bashCommand = string.concat(
            'cast abi-encode "f(bytes)" $(solc --strict-assembly yul/',
            string.concat(fileName, ".yul --bin | tail -1 | cut -c 69-)")
        );

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        return abi.decode(vm.ffi(inputs), (bytes));
    }
}
