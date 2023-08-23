// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "./lib/TestImplementation.sol";
import "../src/ExampleCaller.sol";

contract ExampleCallerTest is Test {
    ExampleCaller public caller;
    TestImplementation public _tester;

    function setUp() public {
        caller = new ExampleCaller();
        _tester = new TestImplementation();
    }

    function testSandboxedDelegatecall() public {
        bytes memory result = caller._delegatecall(address(_tester), abi.encodeWithSignature("custom()"));

        assertEq(uint256(bytes32(result)), 12345);
    }

    function testSandboxSendEther() public {
        address receiver = vm.addr(1);
        vm.deal(address(caller), 1 ether);

        bytes memory result = caller._delegatecall(
            address(_tester), abi.encodeWithSignature("sendEther(address,uint256)", receiver, 0.5 ether)
        );

        result;

        assertEq(receiver.balance, 0.5 ether);
        assertEq(address(caller).balance, 0.5 ether);
        assertEq(address(_tester).balance, 0);
    }

    function testStorageCollisionAttackMitigation() public {
        address originalOwner = caller.owner();

        bytes memory result =
            caller._delegatecall(address(_tester), abi.encodeWithSignature("exploit(address)", vm.addr(1337)));

        result;

        assertEq(caller.owner(), originalOwner);
    }
}
