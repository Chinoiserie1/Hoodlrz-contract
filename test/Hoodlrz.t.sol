// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Hoodlrz.sol";
import "../src/IHoodlrz.sol";

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

  function testCorrectlyDeployed() public view {
    require(hoodlrz.maxSupply() == 400, "fail init max supply");
    require(hoodlrz.signer() == address(owner), "fail init signer");
    require(hoodlrz.publicPrice() == 0.03 ether, "fail init price");
  }
}
