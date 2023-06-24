// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "ERC721A/ERC721A.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

import "./IHoodlrz.sol";
import "./verification/Verification.sol";

contract Hoodlrz is ERC721A, Ownable {
  string baseURI = "";

  address signer;

  uint256 public maxSupply = 100;
  uint256 public publicPrice;

  bool public freezeContract;

  event SetNewMaxSupply(uint256 newMaxSupply);
  event SetNewBaseURI(string newBaseURI);
  event SetNewPublicPrice(uint256 newPublicPrice);
  event FreezeContract();

  constructor() ERC721A("Hoodlrz", "HDLZ") {
    signer = msg.sender;
  }

  /**
   * @notice verify signature
   */
  modifier verify(address _to, uint256 _tokenId, uint256 _amount, Status _status, bytes memory _sign) {
    if (!Verification.verifySignature(signer, _to, _amount, _status, _sign)) revert invalidSignature();
    _;
  }

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
   * @notice set the price for public mint
   * @param _newPublicPrice the new price for public mint
   */
  function setPublicPrice(uint256 _newPublicPrice) external onlyOwner {
    if (freezeContract) revert contractFreezed();
    publicPrice = _newPublicPrice;
    emit SetNewPublicPrice(_newPublicPrice);
  }

  /**
   * @notice set the new signer for check signature
   * @param _newSigner address of the new signer
   * @dev this function can be call at any moment even if the contract is freeze
   * { WARNING } if th signer change all precedent signature will be rejected
   */
  function setSigner(address _newSigner) external onlyOwner {
    signer = _newSigner;
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
