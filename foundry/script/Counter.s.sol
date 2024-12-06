// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {WeatherNFT} from "../src/WeatherNFT.sol";

contract WeatherNFTScript is Script {
    WeatherNFT public weatherNFT;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        weatherNFT = new WeatherNFT();

        vm.stopBroadcast();
    }
}
