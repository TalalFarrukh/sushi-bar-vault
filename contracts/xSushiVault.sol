// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/ISwapRouter.sol";
import "./interfaces/ISushiBar.sol";
import "./interfaces/ISwapFactory.sol";

contract xSushiVault is ERC4626, ReentrancyGuard {
    address private constant SUSHI_SWAP_TOKEN = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
    address private constant X_SUSHI_SWAP_TOKEN = 0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272;
    address private constant SUSHI_SWAP_ROUTER = 0x2E6cd2d30aa43f40aa81619ff4b6E0a41479B13F;
    address private constant SUSHI_SWAP_FACTORY = 0xbACEB8eC6b9355Dfc0269C18bac9d6E2Bdc29C4F;
    address private constant WETH_TOKEN = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address payable public owner;

    uint24 public constant SWAP_FEE = 3000;

    constructor(
        string memory _vaultTokenName,
        string memory _vaultTokenSymbol
    ) ERC4626(IERC20(X_SUSHI_SWAP_TOKEN)) ERC20(_vaultTokenName, _vaultTokenSymbol) {
        owner = payable(msg.sender);
    }

    function depositSpecificToken(address _tokenAddress, uint256 _tokenAmount) public nonReentrant {
        IERC20 token = IERC20(_tokenAddress);
        
        uint256 tokenAllowance = token.allowance(msg.sender, address(this));
        require(tokenAllowance >= _tokenAmount, "Low token allowance for vault");

        bool tokenTransferSuccess = token.transferFrom(msg.sender, address(this), _tokenAmount);
        require(tokenTransferSuccess, "Token transfer failed from user to vault");

        uint256 amountOut = _tokenAmount;

        if(SUSHI_SWAP_TOKEN != _tokenAddress) {
            require(token.approve(SUSHI_SWAP_ROUTER, _tokenAmount), "Token approval failed");

            address tokenSushiPool = ISushiSwapV3Factory(SUSHI_SWAP_FACTORY).getPool(_tokenAddress, SUSHI_SWAP_TOKEN, SWAP_FEE);
            if(tokenSushiPool == address(0)) {
                bytes memory path = abi.encodePacked(
                    _tokenAddress,
                    SWAP_FEE,
                    WETH_TOKEN,
                    SWAP_FEE,
                    SUSHI_SWAP_TOKEN
                );

                ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
                    path: path,
                    recipient: address(this),
                    deadline: block.timestamp + 15,
                    amountIn: _tokenAmount,
                    amountOutMinimum: 0
                });

                amountOut = ISwapRouter(SUSHI_SWAP_ROUTER).exactInput(params);
            } else {
                ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                    tokenIn: _tokenAddress,
                    tokenOut: SUSHI_SWAP_TOKEN,
                    fee: SWAP_FEE,
                    recipient: address(this),
                    deadline: block.timestamp + 15,
                    amountIn: _tokenAmount,
                    amountOutMinimum: 0,
                    sqrtPriceLimitX96: 0
                });

                amountOut = ISwapRouter(SUSHI_SWAP_ROUTER).exactInputSingle(params);
            }
        }

        require(IERC20(SUSHI_SWAP_TOKEN).approve(X_SUSHI_SWAP_TOKEN, amountOut), "Sushi Token approval failed");

        uint256 beforeSushiBarAmount = ISushiBar(X_SUSHI_SWAP_TOKEN).balanceOf(address(this));
        ISushiBar(X_SUSHI_SWAP_TOKEN).enter(amountOut);
        uint256 sushiBarAmountToDeposit = ISushiBar(X_SUSHI_SWAP_TOKEN).balanceOf(address(this)) - beforeSushiBarAmount;

        ISushiBar(X_SUSHI_SWAP_TOKEN).transfer(msg.sender, sushiBarAmountToDeposit);
        deposit(sushiBarAmountToDeposit, msg.sender); 
    }

    function redeemSpecificToken(address _tokenAddress, uint256 _shares) public nonReentrant {
        uint256 sushiBarAmountToRedeem = previewRedeem(_shares);
        redeem(_shares, address(this), msg.sender);

        uint256 beforeSushiAmount = IERC20(SUSHI_SWAP_TOKEN).balanceOf(address(this));
        ISushiBar(X_SUSHI_SWAP_TOKEN).leave(sushiBarAmountToRedeem);
        uint256 sushiAmountToSwap = IERC20(SUSHI_SWAP_TOKEN).balanceOf(address(this)) - beforeSushiAmount;

        uint256 amountOut = sushiAmountToSwap;

        if(SUSHI_SWAP_TOKEN != _tokenAddress) {
            require(IERC20(SUSHI_SWAP_TOKEN).approve(SUSHI_SWAP_ROUTER, sushiAmountToSwap), "Sushi Token approval failed");

            address tokenSushiPool = ISushiSwapV3Factory(SUSHI_SWAP_FACTORY).getPool(SUSHI_SWAP_TOKEN, _tokenAddress, SWAP_FEE);
            if(tokenSushiPool == address(0)) {
                bytes memory path = abi.encodePacked(
                    SUSHI_SWAP_TOKEN,
                    SWAP_FEE,
                    WETH_TOKEN,
                    SWAP_FEE,
                    _tokenAddress
                );

                ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
                    path: path,
                    recipient: msg.sender,
                    deadline: block.timestamp + 15,
                    amountIn: sushiAmountToSwap,
                    amountOutMinimum: 0
                });

                amountOut = ISwapRouter(SUSHI_SWAP_ROUTER).exactInput(params);
            } else {
                ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
                    tokenIn: SUSHI_SWAP_TOKEN,
                    tokenOut: _tokenAddress,
                    fee: SWAP_FEE,
                    recipient: msg.sender,
                    deadline: block.timestamp + 15,
                    amountIn: sushiAmountToSwap,
                    amountOutMinimum: 0,
                    sqrtPriceLimitX96: 0
                });

                amountOut = ISwapRouter(SUSHI_SWAP_ROUTER).exactInputSingle(params);
            }
        } else {
            IERC20(_tokenAddress).transfer(msg.sender, amountOut);
        }
    }
}