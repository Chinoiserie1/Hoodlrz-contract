// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ERC721A/ERC721A.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

error contractFreezed();
error currentSupplyExceedNewMaxSupply();

contract Hoodlrz is ERC721A, Ownable {
  uint256 maxSupply = 1000;

  bool freezeContract;

  event SetNewMaxSupply(uint256 newMaxSupply);

  constructor() ERC721A("Hoodlrz", "HDZ") {}

  function setMaxSupply(uint256 newMaxSupply) external onlyOwner {
    if (freezeContract) revert contractFreezed();
    if (totalSupply() < newMaxSupply) revert currentSupplyExceedNewMaxSupply();
    maxSupply = newMaxSupply;
    emit SetNewMaxSupply(newMaxSupply);
  }
}
