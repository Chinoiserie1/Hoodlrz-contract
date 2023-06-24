// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ERC721A/ERC721A.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

error contractFreezed();
error currentSupplyExceedNewMaxSupply();

contract Hoodlrz is ERC721A, Ownable {
  string baseURI = "";
  uint256 public maxSupply = 1000;

  bool public freezeContract;

  event SetNewMaxSupply(uint256 newMaxSupply);
  event FreezeContract();

  constructor() ERC721A("Hoodlrz", "HDZ") {}

  // SETTER FUNCTION

  /**
   * @notice Set max supply that can be minted
   * @param newMaxSupply the new max supply
   * @dev to call this function newMaxSupply need to be superior that actual supply
   * and the contract not freeze
   */
  function setMaxSupply(uint256 newMaxSupply) external onlyOwner {
    if (freezeContract) revert contractFreezed();
    if (totalSupply() < newMaxSupply) revert currentSupplyExceedNewMaxSupply();
    maxSupply = newMaxSupply;
    emit SetNewMaxSupply(newMaxSupply);
  }

  /**
   * @notice freeze the contract for immutability
   */
  function freeze() external onlyOwner {
    if (freezeContract) revert contractFreezed();
    freezeContract = true;
    emit FreezeContract();
  }

  // OVERRIDE FUNCTIONS

  function _baseURI() internal view override virtual returns (string memory) {
    return baseURI;
  }

  function _startTokenId() internal view override virtual returns (uint256) {
    return 1;
  }
}
