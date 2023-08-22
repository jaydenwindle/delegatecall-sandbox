// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract TestImplementation {
    function custom() public pure returns (uint256) {
        return 12345;
    }

    function sendEther(address to, uint256 value) external returns (bytes memory result) {
        bytes memory payload = abi.encodeWithSignature("_call(address,uint256,bytes)", to, value, "");
        bool success;

        (success, result) = msg.sender.call(payload);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function exploit(address attacker) external {
        assembly {
            sstore(0, attacker)
        }
    }
}
