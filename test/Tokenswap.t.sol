// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IUniswapV2Factory} from "../src/Interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "../src/Interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "../src/Interfaces/IUniswapV2Router.sol";
import {IPancakeFactory} from "../src/Interfaces/IPancakeFactory.sol";
import {IPancakePair} from "../src/Interfaces/IPancakePair.sol";
import {IPancakeRouter02} from "../src/Interfaces/IPancakeRouter.sol";
import {Tokenswap} from "../src/Tokenswap.sol";
import {WBNB} from "../src/WBNB.sol";
import {USDT} from "../src/USDT.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract TokenSwap is Test {
    Tokenswap public tokenswap;
    WBNB public wbnb;
    USDT public usdt;

    IUniswapV2Factory Iuniswapv2factory;
    IUniswapV2Router02 Iuniswapv2router;
    IUniswapV2Factory Isushiv2factory;
    IUniswapV2Router02 Isushiv2router;
    IPancakeFactory Ipancakefactory;
    IPancakeRouter02 Ipancakerouter;

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

    address public client1 = address(111111);
    address public client2 = address(222222);

    function setUp() public {
        Iuniswapv2factory = IUniswapV2Factory(address(UNIFACTORY));
        Iuniswapv2router = IUniswapV2Router02(address(UNIROUTER));
        Isushiv2factory = IUniswapV2Factory(address(SUSHIFACTORY));
        Isushiv2router = IUniswapV2Router02(address(SUSHIROUTER));
        Ipancakefactory = IPancakeFactory(address(PANFACTORY));
        Ipancakerouter = IPancakeRouter02(address(PANROUTER));

        vm.startPrank(client1);
        wbnb = new WBNB();
        usdt = new USDT();

        wbnb.mint(client1, 1000 * 1e18);
        usdt.mint(client1, 1000 * 1e18);

        tokenswap = new Tokenswap(
            UNIFACTORY,
            SUSHIFACTORY,
            PANFACTORY,
            UNIROUTER,
            SUSHIROUTER,
            PANROUTER
        );
        vm.stopPrank();
    }

    function test_Token_setUp() public returns (address,address,address) {
        uint wbnbAmountUni = 100 * 1e18;
        uint usdtAmountUni = 50 * 1e18;
        uint wbnbAmountSushi = 100 * 1e18;
        uint usdtAmountSushi = 25 * 1e18;
        uint wbnbAmountPanCake = 100 * 1e18;
        uint usdtAmountPanCake = 40 * 1e18;

        vm.startPrank(client1);
        wbnb.approve(address(tokenswap), 1000 * 1e18);
        usdt.approve(address(tokenswap), 1000 * 1e18);

        wbnb.approve(address(Iuniswapv2router), wbnbAmountUni);
        usdt.approve(address(Iuniswapv2router), usdtAmountUni);
        wbnb.approve(address(Isushiv2router), 200 * 1e18);
        usdt.approve(address(Isushiv2router), 100 * 1e18);
        wbnb.approve(address(Ipancakerouter), wbnbAmountPanCake);
        usdt.approve(address(Ipancakerouter), usdtAmountPanCake);

        address pairUni = Iuniswapv2factory.createPair(
            address(wbnb),
            address(usdt)
        );

        address pairSushi = Isushiv2factory.createPair(
            address(wbnb),
            address(usdt)
        );

        address pairPancake = Ipancakefactory.createPair(
            address(wbnb),
            address(usdt)
        );

        Iuniswapv2router.addLiquidity(
            address(wbnb),
            address(usdt),
            wbnbAmountUni,
            usdtAmountUni,
            1,
            1,
            address(Iuniswapv2router),
            block.timestamp + 3 minutes
        );

        Isushiv2router.addLiquidity(
            address(wbnb),
            address(usdt),
            wbnbAmountSushi,
            usdtAmountSushi,
            1,
            1,
            address(Isushiv2router),
            block.timestamp + 3 minutes
        );

        Ipancakerouter.addLiquidity(
            address(wbnb),
            address(usdt),
            wbnbAmountPanCake,
            usdtAmountPanCake,
            1,
            1,
            address(Ipancakerouter),
            block.timestamp + 3 minutes
        );
        vm.stopPrank();
        uint256 pairBalanceWBNBUni = wbnb.balanceOf(pairUni);
        uint256 pairBalanceUSDTUni = usdt.balanceOf(pairUni);
        uint256 pairBalanceWBNBSushi = wbnb.balanceOf(pairSushi);
        uint256 pairBalanceUSDTSushi = usdt.balanceOf(pairSushi);
        uint256 pairBalanceWBNBPancake = wbnb.balanceOf(pairPancake);
        uint256 pairBalanceUSDTPancake = usdt.balanceOf(pairPancake);

        assertEq(pairBalanceWBNBUni, wbnbAmountUni);
        assertEq(pairBalanceUSDTUni, usdtAmountUni);
        assertEq(pairBalanceWBNBSushi, wbnbAmountSushi);
        assertEq(pairBalanceUSDTSushi, usdtAmountSushi);
        assertEq(pairBalanceWBNBPancake, wbnbAmountPanCake);
        assertEq(pairBalanceUSDTPancake, usdtAmountPanCake);
        return (pairUni, pairSushi, pairPancake);
    }

    function test_getPriceUni() public {
        test_Token_setUp();
        vm.startPrank(client1);
        uint priceUni = tokenswap.getPriceUni(address(wbnb), address(usdt));
        console.log("priceUni", priceUni);
        vm.stopPrank();
    }

    function test_getPriceSushi() public {
        test_Token_setUp();
        vm.startPrank(client1);
        uint priceSushi = tokenswap.getPriceSushi(address(wbnb), address(usdt));
        console.log("priceSushi", priceSushi);
    }

    function test_getPricePancake() public {
        test_Token_setUp();
        vm.startPrank(client1);
        uint pricePancake = tokenswap.getPricePancake(
            address(wbnb),
            address(usdt)
        );
        console.log("pricePancake", pricePancake);
        vm.stopPrank();
    }

    function test_getLowest() public {
        test_Token_setUp();
        vm.startPrank(client1);
        (uint lowestPrice, uint index) = tokenswap.getLowest(
            address(wbnb),
            address(usdt)
        );
        console.log("lowestPrice", lowestPrice);
        console.log("index", index);
        assertEq(index, 1);
        assertEq(lowestPrice, 250000000000000000);
        vm.stopPrank();
    }

    function test_swap() public {
        (,address pairSushi,) = test_Token_setUp();
        vm.startPrank(client1);
        uint balanceWBNBBefore = wbnb.balanceOf(pairSushi);
        uint balanceUSDTBefore =  usdt.balanceOf(pairSushi);
        uint balance_Client_WBNBBefore = wbnb.balanceOf(client1);
        uint balance_Client_USDTBefore = usdt.balanceOf(client1);
        console.log("balanceWBNBBefore", wbnb.balanceOf(pairSushi));
        console.log("balanceUSDTBefore", usdt.balanceOf(pairSushi));
        console.log("balance_Client_WBNBBefore", wbnb.balanceOf(client1));
        console.log("balance_Client_USDTBefore", usdt.balanceOf(client1));
        wbnb.approve(address(tokenswap), 100 * 1e18);
        tokenswap.swap(address(wbnb), address(usdt), 50, 0);
        uint balanceWBNBAfter = wbnb.balanceOf(pairSushi);
        uint balanceUSDTAfter = usdt.balanceOf(pairSushi);
        uint balance_Client_WBNBAfter =  wbnb.balanceOf(client1);
        uint balance_Client_USDTAfter = usdt.balanceOf(client1);
        console.log("balanceWBNBAfter", wbnb.balanceOf(pairSushi));
        console.log("balanceUSDTAfter", usdt.balanceOf(pairSushi));
        console.log("balance_Client_WBNBAfter", wbnb.balanceOf(client1));
        console.log("balance_Client_USDTAfter", usdt.balanceOf(client1));
        assertGe(balanceWBNBAfter, balanceWBNBBefore);
        assertGe(balanceUSDTBefore, balanceUSDTAfter);
        assertGe(balance_Client_WBNBBefore, balance_Client_WBNBAfter);
        assertGe(balance_Client_USDTAfter, balance_Client_USDTBefore);
        vm.stopPrank();
    }
}
