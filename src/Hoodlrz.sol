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
  event SetNewBaseURI(string newBaseURI);
  event FreezeContract();

  constructor() ERC721A("Hoodlrz", "HDZ") {}

  // SETTER FUNCTION

  /**
   * @notice Set max supply that can be minted
   * @param _newMaxSupply the new max supply
   * @dev to call this function newMaxSupply need to be superior that actual supply
   * and the contract not freeze
   */
  function setMaxSupply(uint256 _newMaxSupply) external onlyOwner {
    if (freezeContract) revert contractFreezed();
    if (totalSupply() < _newMaxSupply) revert currentSupplyExceedNewMaxSupply();
    maxSupply = _newMaxSupply;
    emit SetNewMaxSupply(_newMaxSupply);
  }

  /**
   * @notice set the new base URI
   * @param _newBaseURI the new base URI
   */
  function setBaseURI(string memory _newBaseURI) external onlyOwner {
    if (freezeContract) revert contractFreezed();
    baseURI = _newBaseURI;
    emit SetNewBaseURI(_newBaseURI);
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
