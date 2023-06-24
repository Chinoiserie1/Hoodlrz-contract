// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ERC721A/ERC721A.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Hoodlrz is ERC721A {
  uint256 maxSupply = 1000;

  constructor() ERC721A("Hoodlrz", "HDZ") {}

  function setMaxSupply(uint256 newMaxSupply) external {}
}
