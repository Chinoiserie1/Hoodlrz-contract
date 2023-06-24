// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/ERC721A/contracts/ERC721A.sol";

contract Hoodlrz is ERC721A {
  uint256 maxSupply = 1000;

  constructor() ERC721A("Hoodlrz", "HDZ") {}

  function setMaxSupply(uint256 newMaxSupply) external {}
}
