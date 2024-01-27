// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MultiSwap {
    address private owner;
    ISwapRouter public immutable swapRouter =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    address public constant USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;

    uint24 public constant poolFee = 3000;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function swapPercent(
        address[] _tokens,
        uint256[] _percentages
    ) external returns (uint256 amountOut) {
        require(_tokens.length == _percentages.length, "Invalid input");

        for (uint256 i = 0; i < _tokens.length; i++) {
            uint256 amountIn = (IERC20(USDC).balanceOf(msg.sender) *
                _percentages[i]) / 100;
            TransferHelper.safeTransferFrom(
                _tokens[i],
                msg.sender,
                address(this),
                amountIn
            );

            TransferHelper.safeApprove(
                _tokens[i],
                address(swapRouter),
                amountIn
            );

            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
                .ExactInputSingleParams({
                    tokenIn: USDC,
                    tokenOut: _tokens[i],
                    fee: poolFee,
                    recipient: msg.sender,
                    deadline: block.timestamp,
                    amountIn: amountIn,
                    amountOutMinimum: 0,
                    sqrtPriceLimitX96: 0
                });

            amountOut = swapRouter.exactInputSingle(params);
        }
    }

    function swapExact(
        address[] _tokens,
        uint256[] _amounts
    ) external returns (uint256 amountOut) {
        require(_tokens.length == _amounts.length, "Invalid input");
        for (uint256 i = 0; i < _tokens.length; i++) {
            uint256 amountIn = _amounts[i];

            require(
                IERC20(USDC).balanceOf(msg.sender) >= amountIn,
                "Insufficient balance"
            );
            TransferHelper.safeTransferFrom(
                _tokens[i],
                msg.sender,
                address(this),
                amountIn
            );

            TransferHelper.safeApprove(
                _tokens[i],
                address(swapRouter),
                amountIn
            );

            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
                .ExactInputSingleParams({
                    tokenIn: USDC,
                    tokenOut: _tokens[i],
                    fee: poolFee,
                    recipient: msg.sender,
                    deadline: block.timestamp,
                    amountIn: amountIn,
                    amountOutMinimum: 0,
                    sqrtPriceLimitX96: 0
                });

            amountOut = swapRouter.exactInputSingle(params);
        }
    }

    function getTokenBalance(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(msg.sender);
    }
}
