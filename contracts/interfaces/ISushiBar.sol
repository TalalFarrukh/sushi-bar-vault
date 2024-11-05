// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface ISushiBar is IERC20 {
    function enter(uint256 amount) external;
    function leave(uint256 share) external;
}