// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/// @title The Tokenswap contract
/// @author Shahidkhan
/// @notice This is a tokenswap contract in which contract will compare prices of token pair on different decentralized exchanges(Dexs) and then swaps using one dex which has best price compare to others.

import "./Interfaces/IUniswapV2Pair.sol";
import "./Interfaces/IUniswapV2Factory.sol";
import "./Interfaces/IPancakePair.sol";
import "./Interfaces/IPancakeFactory.sol";
import "./Interfaces/IUniswapV2Router.sol";
import "./Interfaces/IPancakeRouter.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Tokenswap {
    IUniswapV2Factory public factoryUni;
    IUniswapV2Factory public factorySushi;
    IPancakeFactory public factoryPancake;
    IUniswapV2Router02 public unirouterv2;
    IUniswapV2Router02 public sushirouterv2;
    IPancakeRouter02 public pancakerouterv2;
    address private unirouterV2;
    address private sushirouterV2;
    address private pancakerouterV2;

    constructor(
        address _uniswapv2factory,
        address _sushiswapv2factory,
        address _pancakefactory,
        address _unirouterv2,
        address _sushirouterv2,
        address _pancakerouterv2
    ) {
        require(_uniswapv2factory != address(0), "Uniswap address is not set");
        require(
            _sushiswapv2factory != address(0),
            "Uniswap address is not set"
        );
        require(_pancakefactory != address(0), "Uniswap address is not set");
        require(
            _unirouterv2 != address(0),
            "uniswap router address is not set"
        );
        require(
            _sushirouterv2 != address(0),
            "sushiswap router address is not set"
        );
        require(
            _pancakerouterv2 != address(0),
            "pancakeswap router address is not set"
        );
        factoryUni = IUniswapV2Factory(_uniswapv2factory);
        factorySushi = IUniswapV2Factory(_sushiswapv2factory);
        factoryPancake = IPancakeFactory(_pancakefactory);
        unirouterv2 = IUniswapV2Router02(_unirouterv2);
        unirouterV2 = _unirouterv2;
        sushirouterv2 = IUniswapV2Router02(_sushirouterv2);
        sushirouterV2 = _sushirouterv2;
        pancakerouterv2 = IPancakeRouter02(_pancakerouterv2);
        pancakerouterV2 = _pancakerouterv2;
    }

    /// @notice swaps tokens from one dex which has best price
    /// @param tokenA address of the token which user wants to give for swap
    /// @param tokenB address of the token which user wants as an output
    /// @param _amountIn an amount of tokens user wants to spend for swap
    /// @param _amountOutMin minimum amount of tokens user wants from swap
    function swap(
        address tokenA,
        address tokenB,
        uint _amountIn,
        uint _amountOutMin
    ) external {
        require(
            IERC20(tokenA).balanceOf(msg.sender) >= _amountIn,
            "Insufficient balance1111"
        );
        IERC20(tokenA).transferFrom(msg.sender, address(this), _amountIn);
        (, uint dex) = calcLowest(tokenA, tokenB);
        address[] memory path;
        path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        if (dex == 0) {
            IERC20(tokenA).approve(unirouterV2, _amountIn);
            unirouterv2.swapExactTokensForTokens(
                _amountIn,
                _amountOutMin,
                path,
                msg.sender,
                block.timestamp
            );
        } else if (dex == 1) {
            IERC20(tokenA).approve(sushirouterV2, _amountIn);
            sushirouterv2.swapExactTokensForTokens(
                _amountIn,
                _amountOutMin,
                path,
                msg.sender,
                block.timestamp
            );
        } else {
            IERC20(tokenA).approve(pancakerouterV2, _amountIn);

            pancakerouterv2.swapExactTokensForTokens(
                _amountIn,
                _amountOutMin,
                path,
                msg.sender,
                block.timestamp
            );
        }
    }

    ///@notice to calculate lowest price from all the three dexs
    ///@param tokenA address of the token which user wants to give for swap
    ///@param tokenB address of the token which user wants as an output
    function calcLowest(
        address tokenA,
        address tokenB
    ) internal view returns (uint, uint) {
        uint priceUni = getPriceUni(tokenA, tokenB);
        uint priceSushi = getPriceSushi(tokenA, tokenB);
        uint256 pricePancake = getPricePancake(tokenA, tokenB);
        uint[3] memory Prices = [priceUni, priceSushi, pricePancake];

        uint lowestPrice = Prices[0];
        uint minIndex = 0;
        for (uint256 i = 0; i < Prices.length; i++) {
            if (lowestPrice > Prices[i]) {
                lowestPrice = Prices[i];
                minIndex = i;
            }
        }
        return (lowestPrice, minIndex);
    }

    ///@notice to check a lowestprice and dex index from calcLowest function
    ///@param tokenA address of the token which user wants to give for swap
    ///@param tokenB address of the token which user wants as an output
    function getLowest(
        address tokenA,
        address tokenB
    ) external view returns (uint, uint) {
        (uint index, uint lowestPrice) = calcLowest(tokenA, tokenB);
        return (index, lowestPrice);
    }

    ///@notice to get a price of tokens from uniSwapV2 dex
    ///@param tokenA address of the token which user wants to give for swap
    ///@param tokenB address of the token which user wants as an output
    function getPriceUni(
        address tokenA,
        address tokenB
    ) internal view returns (uint priceUni) {
        address pairAddress = factoryUni.getPair(tokenA, tokenB);
        IUniswapV2Pair uniswappair = IUniswapV2Pair(pairAddress);
        (uint reserve0, uint reserve1, ) = uniswappair.getReserves();
        address token0 = uniswappair.token0();

        if (token0 == tokenA) {
            priceUni = (reserve1 * 1e18) / reserve0; // price of tokenA in terms of tokenB
        } else {
            priceUni = (reserve0 * 1e18) / reserve1; // price of tokenB in terms of tokenA
        }
    }

    ///@notice to get a price of tokens from sushiSwapV2 dex
    ///@param tokenA address of the token which user wants to give for swap
    ///@param tokenB address of the token which user wants as an output
    function getPriceSushi(
        address tokenA,
        address tokenB
    ) internal view returns (uint priceSushi) {
        address pairAddress = factorySushi.getPair(tokenA, tokenB);
        IUniswapV2Pair sushiswappair = IUniswapV2Pair(pairAddress);
        (uint reserve0, uint reserve1, ) = sushiswappair.getReserves();

        address token0 = sushiswappair.token0();

        if (token0 == tokenA) {
            priceSushi = (reserve1 * 1e18) / reserve0; // price of tokenA in terms of tokenB
        } else {
            priceSushi = (reserve0 * 1e18) / reserve1; // price of tokenB in terms of tokenA
        }
    }

    ///@notice to get a price of tokens from pancakeSwapV2 dex
    ///@param tokenA address of the token which user wants to give for swap
    ///@param tokenB address of the token which user wants as an output
    function getPricePancake(
        address tokenA,
        address tokenB
    ) internal view returns (uint256 pricePancake) {
        address pairAddress = factoryPancake.getPair(tokenA, tokenB);
        IPancakePair pancakepair = IPancakePair(pairAddress);
        (uint256 reserve0, uint256 reserve1, ) = pancakepair.getReserves();

        address token0 = pancakepair.token0();

        if (token0 == tokenA) {
            pricePancake = (reserve1 * 1e18) / reserve0; // price of tokenA in terms of tokenB
        } else {
            pricePancake = (reserve0 * 1e18) / reserve1; // price of tokenB in terms of tokenA
        }
    }
}
