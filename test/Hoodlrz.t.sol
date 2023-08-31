// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Hoodlrz.sol";
import "../src/IHoodlrz.sol";
import "../src/error/Error.sol";
import "../src/verification/Verification.sol";

contract HoodlrzTest is Test {
  Hoodlrz public hoodlrz;

  uint256 internal ownerPrivateKey;
  address internal owner;
  uint256 internal user1PrivateKey;
  address internal user1;
  uint256 internal user2PrivateKey;
  address internal user2;
  int256 internal user3PrivateKey;
  address internal user3;
  uint256 internal signerPrivateKey;
  address internal signer;

  function setUp() public {
    ownerPrivateKey = 0xA11CE;
    owner = vm.addr(ownerPrivateKey);
    user1PrivateKey = 0xB0B;
    user1 = vm.addr(user1PrivateKey);
    user2PrivateKey = 0xFE55E;
    user2 = vm.addr(user2PrivateKey);
    user3PrivateKey = 0xD1C;
    user3 = vm.addr(user2PrivateKey);
    signerPrivateKey = 0xF10;
    signer = vm.addr(signerPrivateKey);
    vm.startPrank(owner);

    hoodlrz = new Hoodlrz();
  }

  function testGas() public {
    Hoodlrz contractGas = new Hoodlrz();
  }

  // TEST DEPLOY CORRECTLY
  function testCorrectlyDeployed() public view {
    require(hoodlrz.maxSupply() == 400, "fail init max supply");
    require(hoodlrz.signer() == address(owner), "fail init signer");
    require(hoodlrz.publicPrice() == 0.03 ether, "fail init price");
    require(hoodlrz.freezeContract() == false, "fail init freeze contract");
    require(hoodlrz.currentStatus() == Status.notInitialize, "fail init current status");
  }

  // TEST SETTER

  // setStatus

  function testSetStatus() public {
    require(hoodlrz.currentStatus() == Status.notInitialize, "fail init current status");
    hoodlrz.setStatus(Status.paused);
    require(hoodlrz.currentStatus() == Status.paused, "fail set a new status");
  }

  function testSetStatusOnlyOwner() public {
    vm.stopPrank();
    vm.prank(user1);
    vm.expectRevert("Ownable: caller is not the owner");
    hoodlrz.setStatus(Status.paused);
  }

  // setMaxSuuply

  function testSetMaxSupply() public {
    uint256 newMaxSupply = 100;
    hoodlrz.setMaxSupply(newMaxSupply);
    require(hoodlrz.maxSupply() == newMaxSupply, "fail apply new max supply");
  }

  function testSetMaxSupplyFailIfTotalBalanceMintedExceedNewMaxSuuply() public {
    vm.deal(user1, 100 ether);
    uint256 newMaxSupply = 10;
    hoodlrz.setStatus(Status.publicMint);
    vm.stopPrank();
    vm.prank(user1);
    hoodlrz.publicMint{value: 0.03 ether * 20}(20);
    vm.prank(owner);
    vm.expectRevert(currentSupplyExceedNewMaxSupply.selector);
    hoodlrz.setMaxSupply(newMaxSupply);
  }

  function testMaxSupplyOnlyOwner() public {
    vm.stopPrank();
    vm.prank(user1);
    vm.expectRevert("Ownable: caller is not the owner");
    hoodlrz.setMaxSupply(10);
  }

  function testMaxSupplyFailWhenFreeze() public {
    hoodlrz.freeze();
    vm.expectRevert(contractFreezed.selector);
    hoodlrz.setMaxSupply(10);
  }

  // setBaseURI

  function testSetBaseURI() public {
    string memory newURI = "My new URI";
    hoodlrz.setBaseURI(newURI);
    string memory currentURI = hoodlrz.baseURI();
    require(keccak256(bytes(newURI)) == keccak256(bytes(currentURI)), "fail set new base URI");
  }

  function testSetBaseURIOnlyOwner() public {
    string memory newURI = "My new URI";
    vm.stopPrank();
    vm.prank(user1);
    vm.expectRevert("Ownable: caller is not the owner");
    hoodlrz.setBaseURI(newURI);
  }

  function testSetBaseURIFailWhenFreeze() public {
    string memory newURI = "My new URI";
    hoodlrz.freeze();
    vm.expectRevert(contractFreezed.selector);
    hoodlrz.setBaseURI(newURI);
  }

  // setPublicPrice

  function testSetPublicPrice() public {
    uint256 newPublicPrice = 1 ether;
    hoodlrz.setPublicPrice(newPublicPrice);
    uint256 currentPrice = hoodlrz.publicPrice();
    require(currentPrice == newPublicPrice, "fail set public price");
  }

  function testSetPublicPriceOnlyOwner() public {
    uint256 newPublicPrice = 1 ether;
    vm.stopPrank();
    vm.prank(user1);
    vm.expectRevert("Ownable: caller is not the owner");
    hoodlrz.setPublicPrice(newPublicPrice);
  }

  function testSetPublicPriceFailWhenFreeze() public {
    uint256 newPublicPrice = 1 ether;
    hoodlrz.freeze();
    vm.expectRevert(contractFreezed.selector);
    hoodlrz.setPublicPrice(newPublicPrice);
  }

  // setSigner

  function testSetSigner() public {
    hoodlrz.setSigner(signer);
    address currentSigner = hoodlrz.signer();
    require(currentSigner == signer, "fail set new signer");
  }

  function testSetSignerOnlyOwner() public {
    vm.stopPrank();
    vm.prank(user1);
    vm.expectRevert("Ownable: caller is not the owner");
     hoodlrz.setSigner(signer);
  }

  // withdraw

  function testWithdraw() public {

  }

  // allowlistMint

  function signAllowlist(address user, uint256 quantity) internal view returns (bytes memory) {
    bytes32 messageHash = Verification.getMessageHash(user, quantity, Status.allowlistMint);
    bytes32 finalHash = Verification.getEthSignedMessageHash(messageHash);
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, finalHash);
    bytes memory signature = abi.encodePacked(r, s, v);
    return signature;
  }

  function testAllowlistMint() public {
    bytes memory signature = signAllowlist(address(user1), 10);
    hoodlrz.setSigner(signer);
    hoodlrz.setStatus(Status.allowlistMint);
    vm.stopPrank();
    vm.startPrank(user1);
    hoodlrz.allowlistMint(10, signature);
    uint256 balanceUser1 = hoodlrz.balanceOf(user1);
    require(balanceUser1 == 10, "fail allowlistMint");
  }

  function testAllowlistMintFailInvalidSignature() public {
    bytes memory signature = signAllowlist(address(user1), 10);
    hoodlrz.setSigner(signer);
    hoodlrz.setStatus(Status.allowlistMint);
    vm.stopPrank();
    vm.startPrank(user2);
    vm.expectRevert(invalidSignature.selector);
    hoodlrz.allowlistMint(10, signature);
  }

  function testAllowlistMintFailInvalidStatus() public {
    bytes memory signature = signAllowlist(address(user1), 10);
    hoodlrz.setSigner(signer);
    hoodlrz.setStatus(Status.paused);
    vm.stopPrank();
    vm.startPrank(user1);
    vm.expectRevert(invalidStatus.selector);
    hoodlrz.allowlistMint(10, signature);
  }

  // publicMint

  function testPublicMint() public {
    hoodlrz.setStatus(Status.publicMint);
    vm.deal(user1, 100 ether);
    vm.stopPrank();
    vm.prank(user1);
    hoodlrz.publicMint{ value: 10 * 0.03 ether }(10);
    require(hoodlrz.balanceOf(user1) == 10, "fail public mint");
  }

  function testPublicMintFailInvalidStatus() public {
    vm.deal(user1, 100 ether);
    vm.stopPrank();
    vm.prank(user1);
    vm.expectRevert(invalidStatus.selector);
    hoodlrz.publicMint{ value: 10 * 0.03 ether }(10);
  }
}
