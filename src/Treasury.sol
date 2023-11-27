// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable, Ownable2Step} from "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {IUniswapV2Router01} from "./interfaces/IUniswapV2Router01.sol";
import {ILendingPool} from "./interfaces/ILendingPool.sol";

contract Treasury is Ownable2Step {
    using SafeERC20 for IERC20;

    IUniswapV2Router01 private immutable _uniswapRouter;
    ILendingPool private immutable _aaveLendingPool;

    address private immutable _usdcToken;
    address private immutable _usdtToken;
    address private immutable _daiToken;

    uint256 private _uniswapRatio;
    uint256 private _aaveRatio;

    constructor(
        address uniswapRouter_,
        address aaveLendingPool_,
        address usdcToken_,
        address usdtToken_,
        address daiToken_,
        uint256 uniswapRatio_,
        uint256 aaveRatio_
    ) Ownable(_msgSender()) {
        _uniswapRouter = IUniswapV2Router01(uniswapRouter_);
        _aaveLendingPool = ILendingPool(aaveLendingPool_);
        _usdcToken = usdcToken_;
        _usdtToken = usdtToken_;
        _daiToken = daiToken_;
        _setRatios(uniswapRatio_, aaveRatio_);
    }

    function _setRatios(uint256 uniswapRatio_, uint256 aaveRatio_) private {
        if (_uniswapRatio + _aaveRatio > 100) revert();

        _uniswapRatio = uniswapRatio_;
        _aaveRatio = aaveRatio_;
    }

    function setRatios(uint256 uniswapRatio_, uint256 aaveRatio_) external onlyOwner {
        _setRatios(uniswapRatio_, aaveRatio_);
    }

    function deposit(uint256 amount) external {
        IERC20(_usdcToken).safeTransferFrom(_msgSender(), address(this), amount);

        uint256 uniswapAmount = (amount * _uniswapRatio) / 100;
        uint256 aaveAmount = (amount * _aaveRatio) / 100;

        IERC20(_usdcToken).safeIncreaseAllowance(address(_uniswapRouter), uniswapAmount);
        IERC20(_usdcToken).safeIncreaseAllowance(address(_aaveLendingPool), aaveAmount);

        address[] memory path = new address[](2);
        path[0] = _usdcToken;
        path[1] = _usdtToken;

        _uniswapRouter.swapExactTokensForTokens(uniswapAmount, 0, path, address(this), block.timestamp + 10 minutes);
        _aaveLendingPool.deposit(_usdcToken, aaveAmount, address(this), 0);
    }

    function withdraw(uint256 amount) external onlyOwner {
        IERC20(_usdtToken).safeTransfer(_msgSender(), (amount * _uniswapRatio) / 100);
        IERC20(_daiToken).safeTransfer(_msgSender(), (amount * _aaveRatio) / 100);
    }

    function calculateYield() public view returns (uint256) {
        uint256 usdtBalance = IERC20(_usdtToken).balanceOf(address(this));
        uint256 daiBalance = IERC20(_daiToken).balanceOf(address(this));

        return usdtBalance + daiBalance;
    }

    function uniswapRouter() external view returns (IUniswapV2Router01) {
        return _uniswapRouter;
    }

    function aaveLendingPool() external view returns (ILendingPool) {
        return _aaveLendingPool;
    }

    function usdcToken() external view returns (address) {
        return _usdcToken;
    }

    function usdtToken() external view returns (address) {
        return _usdtToken;
    }

    function daiToken() external view returns (address) {
        return _daiToken;
    }

    function uniswapRatio() external view returns (uint256) {
        return _uniswapRatio;
    }

    function aaveRatio() external view returns (uint256) {
        return _aaveRatio;
    }
}
