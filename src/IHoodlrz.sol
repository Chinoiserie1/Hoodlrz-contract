// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./error/Error.sol";

enum Status {
  notInitialize,
  allowlistMint,
  whitelistMint,
  publicMint,
  paused
}