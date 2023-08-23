// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "openzeppelin-contracts/contracts/utils/Create2.sol";

import "./lib/TestImplementation.sol";
import "./lib/SandboxDeployer.sol";
import "../src/lib/LibSandbox.sol";

contract SandboxTest is Test {
    TestImplementation public _tester;
    SandboxDeployer sandboxDeployer = new SandboxDeployer();

    function setUp() public {
        _tester = new TestImplementation();
    }

    function testCompileSandbox() public {
        console.logBytes(sandboxDeployer.getHeaderBytecode());
        console.logBytes(sandboxDeployer.getFooterBytecode());
    }

    function testSandboxDeployment() public {
        address sandbox = sandboxDeployer.deploy(address(this));

        console.logBytes(sandbox.code);
        console.logBytes(LibSandbox.bytecode(address(this)));

        bytes memory owner = new bytes(20);

        assembly {
            // copy hardcoded owner address
            extcodecopy(sandbox, add(owner, 0x20), 1, 20)
        }

        assertEq(address(uint160(uint256(bytes32(owner)) >> 96)), address(this));
    }

    function testSandboxDelegatecall() public {
        address sandbox = sandboxDeployer.deploy(address(this));

        bytes memory payload = abi.encodePacked(address(_tester), abi.encodeWithSignature("custom()"));

        (bool success, bytes memory result) = sandbox.call(payload);

        assertEq(success, true);
        assertEq(uint256(bytes32(result)), 12345);
    }

    function testSandboxStorage() public {
        address sandbox = sandboxDeployer.deploy(address(this));

        bytes memory payload =
            abi.encodePacked(address(_tester), abi.encodeWithSignature("exploit(address)", vm.addr(1337)));

        (bool success, bytes memory result) = sandbox.call(payload);

        result;

        assertEq(success, true);
        assertEq(address(uint160(uint256(vm.load(sandbox, 0)))), vm.addr(1337));
    }

    function testSandboxPermissions() public {
        address sandbox = sandboxDeployer.deploy(address(this));

        vm.prank(vm.addr(1));
        (bool success, bytes memory result) =
            sandbox.call(abi.encodePacked(address(_tester), abi.encodeWithSignature("custom()")));

        assertEq(success, false);
        assertEq(result, "");
    }
}
