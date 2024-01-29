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

    uint24 public constant poolFee = 3000;

    constructor() {
        owner = msg.sender;
    }

    function getTokenBalance(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(msg.sender);
    }

    function swapPercent(
        address[] memory _tokensIn,
        address[] memory _tokensOut,
        uint256[] memory _percentages
    ) external returns (uint256 amountOut) {
        require(_tokensOut.length == _percentages.length, "Invalid input");

        require(_tokensIn.length == _tokensOut.length, "Invalid input");

        for (uint256 i = 0; i < _tokensOut.length; i++) {
            uint256 amountIn = (IERC20(_tokensIn[i]).balanceOf(msg.sender) *
                _percentages[i]) / 100;

            TransferHelper.safeTransferFrom(
                _tokensIn[i],
                msg.sender,
                address(this),
                amountIn
            );

            TransferHelper.safeApprove(
                _tokensIn[i],
                address(swapRouter),
                amountIn
            );

            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
                .ExactInputSingleParams({
                    tokenIn: _tokensIn[i],
                    tokenOut: _tokensOut[i],
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
        address[] memory _tokensIn,
        address[] memory _tokensOut,
        uint256[] memory _amounts
    ) external returns (uint256 amountOut) {
        require(_tokensOut.length == _amounts.length, "Invalid input");
        require(_tokensIn.length == _tokensOut.length, "Invalid input");

        for (uint256 i = 0; i < _tokensOut.length; i++) {
            uint256 amountIn = _amounts[i] * 1;

            require(
                IERC20(_tokensIn[i]).balanceOf(msg.sender) >= amountIn,
                "Insufficient balance"
            );
            TransferHelper.safeTransferFrom(
                _tokensIn[i],
                msg.sender,
                address(this),
                amountIn
            );

            TransferHelper.safeApprove(
                _tokensIn[i],
                address(swapRouter),
                amountIn
            );

            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
                .ExactInputSingleParams({
                    tokenIn: _tokensIn[i],
                    tokenOut: _tokensOut[i],
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
}
