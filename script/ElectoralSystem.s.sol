// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {ElectoralSystem} from "../src/ElectoralSystem.sol";

contract ElectoralSystemScript is Script {
    ElectoralSystem public electoralSystem;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        electoralSystem = new ElectoralSystem();

        console.log("ElectoralSystem deployed to:", address(electoralSystem));

        vm.stopBroadcast();
    }
}
