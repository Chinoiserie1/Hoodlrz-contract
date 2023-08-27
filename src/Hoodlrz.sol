// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "ERC721A/ERC721A.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

import "./IHoodlrz.sol";
import "./verification/Verification.sol";

/**
 * @title Hoodlrz
 * @author chixx.eth
 * @notice ERC721A for Hoodlrz
 */
contract Hoodlrz is ERC721A, Ownable {
  string public baseURI = "";

  address public signer;

  uint256 public maxSupply = 400;
  uint256 public publicPrice = 0.03 ether;

  bool public freezeContract;

  Status public currentStatus;

  event SetNewMaxSupply(uint256 newMaxSupply);
  event SetNewMaxPerAddress(uint256 newMaxPerAddress);
  event SetNewBaseURI(string newBaseURI);
  event SetNewPublicPrice(uint256 newPublicPrice);
  event FreezeContract();

  constructor() ERC721A("Hoodlrz", "HDLZ") {
    signer = msg.sender;
  }

  /**
   * @notice verify signature
   */
  modifier verify(address _to, uint256 _amount, Status _status, bytes memory _sign) {
    if (!Verification.verifySignature(signer, _to, _amount, _status, _sign)) revert invalidSignature();
    _;
  }

  /**
   * @notice check if the status match
   */
  modifier checkStatus(Status _status) {
    if (currentStatus != _status) revert invalidStatus();
    _;
  }

  // MINT FUNCTIONS

  /**
   * @notice mint function for allowlist
   * @param _quantity the quantity to mint related to the amount given by the signer
   * @param _signature the signature
   */
  function allowlistMint(uint256 _quantity, bytes memory _signature)
    external
    verify(msg.sender, _quantity, Status.allowlistMint, _signature)
    checkStatus(Status.allowlistMint)
  {
    if (_totalMinted() + _quantity > maxSupply) revert maxSupplyReach();

    _mint(msg.sender, _quantity);
  }

  /**
   * @notice mint function for public
   * @param _quantity the quantity to mint
   */
  function publicMint(uint256 _quantity) external payable {
    if (_totalMinted() + _quantity > maxSupply) revert maxSupplyReach();
    if (msg.value < _quantity * publicPrice) revert valueSendIncorrect();

    _mint(msg.sender, _quantity);
  }

  // SETTER FUNCTIONS

  function setStatus(Status _newStatus) external onlyOwner {
    currentStatus = _newStatus;
  }

  /**
   * @notice Set max supply that can be minted
   * @param _newMaxSupply the new max supply
   * @dev to call this function newMaxSupply need to be superior that actual supply
   * and the contract not freeze
   */
  function setMaxSupply(uint256 _newMaxSupply) external onlyOwner {
    if (freezeContract) revert contractFreezed();
    if (_totalMinted() < _newMaxSupply) revert currentSupplyExceedNewMaxSupply();
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
   * { WARNING } if the signer change all precedent signature will be invalid
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

  // WITHDRAW

  function withdraw() external onlyOwner {
    (bool success, ) = address(msg.sender).call{value: address(this).balance}("");
    if (!success) revert failWithdraw();
  }

  // OVERRIDE FUNCTIONS

  function _baseURI() internal view override virtual returns (string memory) {
    return baseURI;
  }

  function _startTokenId() internal view override virtual returns (uint256) {
    return 1;
  }
}
