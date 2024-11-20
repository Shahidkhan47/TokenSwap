// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Tokenswap} from "../src/Tokenswap.sol";

contract TokenSwap is Script {
    //uniswapv2 contract addresses
    address private constant UNIFACTORY =
        0x6725F303b657a9451d8BA641348b6761A6CC7a17;
    address private constant UNIROUTER =
        0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

    address private constant SUSHIFACTORY =
        0xc35DADB65012eC5796536bD9864eD8773aBc74C4;
    address private constant SUSHIROUTER =
        0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506;

    address private constant PANFACTORY =
        0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
    address private constant PANROUTER =
        0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Tokenswap tokenswap = new Tokenswap(
            UNIFACTORY,
            SUSHIFACTORY,
            PANFACTORY,
            UNIROUTER,
            SUSHIROUTER,
            PANROUTER
        );
        console.log("address tokenswap", address(tokenswap));
        vm.stopBroadcast();
    }
}
