// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/utils/Create2.sol";

import "./lib/LibSandbox.sol";

error NotAuthorized();

contract ExampleCaller {
    bytes constant sandboxHeader = hex"605180600d600039806000f3fe73";
    bytes constant sandboxFooter =
        hex"33146027576382b429006000526004601cfd5b363d3d373d3d6014360360143d5160601c5af46047573d6000803e3d6000fd5b3d6000803e3d6000f3";
    address public owner = msg.sender;

    function _delegatecall(address to, bytes calldata data) external returns (bytes memory result) {
        if (!_isOwnerOrSandbox(msg.sender)) revert NotAuthorized();

        address _sandbox = sandbox();

        if (_sandbox.code.length == 0) {
            Create2.deploy(0, keccak256("sandbox"), LibSandbox.bytecode(address(this)));
        }

        bytes memory payload = abi.encodePacked(to, data);
        bool success;

        (success, result) = _sandbox.call(payload);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function _call(address to, uint256 value, bytes calldata data) external returns (bytes memory result) {
        if (!_isOwnerOrSandbox(msg.sender)) revert NotAuthorized();

        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function sandbox() public view returns (address) {
        return Create2.computeAddress(keccak256("sandbox"), keccak256(LibSandbox.bytecode(address(this))));
    }

    function _isOwnerOrSandbox(address caller) internal view returns (bool) {
        return caller == owner || caller == sandbox();
    }
}
