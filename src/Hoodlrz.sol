// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ERC721A/ERC721A.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

error contractFreezed();
error currentSupplyExceedNewMaxSupply();

contract Hoodlrz is ERC721A, Ownable {
  uint256 public maxSupply = 1000;

  bool public freezeContract;

  event SetNewMaxSupply(uint256 newMaxSupply);
  event FreezeContract();

  constructor() ERC721A("Hoodlrz", "HDZ") {}

  function setMaxSupply(uint256 newMaxSupply) external onlyOwner {
    if (freezeContract) revert contractFreezed();
    if (totalSupply() < newMaxSupply) revert currentSupplyExceedNewMaxSupply();
    maxSupply = newMaxSupply;
    emit SetNewMaxSupply(newMaxSupply);
  }

  function freeze() external onlyOwner {
    if (freezeContract) revert contractFreezed();
    freezeContract = true;
    emit FreezeContract();
  }
}
