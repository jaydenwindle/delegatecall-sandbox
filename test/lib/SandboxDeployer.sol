// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract SandboxDeployer is Test {
    bytes16 private constant _HEX_DIGITS = "0123456789abcdef";

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length);
        for (uint256 i = 2 * length; i > 0; --i) {
            buffer[i - 1] = _HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        require(localValue == 0, "error");
        return string(buffer);
    }

    ///@notice Compiles a Yul contract and returns the address that the contract was deployed to
    ///@notice If deployment fails, an error will be thrown
    ///@param fileName - The file name of the Yul contract. For example, the file name for "Example.yul" is "Example"
    ///@param owner - The address which owns the sandbox
    ///@return deployedAddress - The address that the contract was deployed to

    function deployContract(string memory fileName, address owner) public returns (address) {
        bytes memory bytecode = getBytecode(fileName, owner);

        ///@notice deploy the bytecode with the create instruction
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice check that the deployment was successful
        require(deployedAddress != address(0), "YulDeployer could not deploy contract");

        ///@notice return the address that the contract was deployed to
        return deployedAddress;
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

    function getBytecode(string memory fileName, address owner) public returns (bytes memory) {
        return abi.encodePacked(getHeaderBytecode(fileName), owner, getFooterBytecode(fileName));
    }
}
