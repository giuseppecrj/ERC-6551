// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// utils
import {AccountBaseSetup} from "test/account/AccountBaseSetup.sol";

//interfaces

//libraries

//contracts
import {Account} from "src/account/Account.sol";
import {MockERC721} from "test/mocks/MockERC721.sol";

contract AccountERC721Test is AccountBaseSetup {
  MockERC721 public mockERC721;
  MockERC721 public tokenCollection;

  function setUp() external {
    tokenCollection = new MockERC721();
    mockERC721 = new MockERC721();
  }

  function test_transferPreDeploy(uint256 tokenId) external {
    address user1 = _randomAddress();

    address computedAccountInstance = accountRegistry.account(
      address(tokenCollection),
      tokenId
    );

    tokenCollection.mint(user1, tokenId);
    assertEq(tokenCollection.ownerOf(tokenId), user1);

    mockERC721.mint(computedAccountInstance, 1);

    assertEq(mockERC721.ownerOf(1), computedAccountInstance);
    assertEq(mockERC721.balanceOf(computedAccountInstance), 1);

    address accountAddress = accountRegistry.createAccount(
      address(tokenCollection),
      tokenId
    );

    Account account = Account(payable(accountAddress));

    // transfer nft from nft account to user
    bytes memory erc721TransferCall = abi.encodeWithSelector(
      mockERC721.transferFrom.selector,
      accountAddress,
      user1,
      1
    );

    vm.prank(user1);
    account.executeCall(address(mockERC721), 0, erc721TransferCall);

    assertEq(mockERC721.ownerOf(1), user1);
    assertEq(mockERC721.balanceOf(user1), 1);
    assertEq(mockERC721.balanceOf(accountAddress), 0);
  }

  function test_transferPostDeploy(uint256 tokenId) external {
    address user1 = _randomAddress();

    address accountAddress = accountRegistry.createAccount(
      address(tokenCollection),
      tokenId
    );

    tokenCollection.mint(user1, tokenId);
    assertEq(tokenCollection.ownerOf(tokenId), user1);

    mockERC721.mint(accountAddress, 1);

    assertEq(mockERC721.ownerOf(1), accountAddress);
    assertEq(mockERC721.balanceOf(accountAddress), 1);

    Account account = Account(payable(accountAddress));

    bytes memory erc721TransferCall = abi.encodeWithSelector(
      mockERC721.transferFrom.selector,
      accountAddress,
      user1,
      1
    );

    vm.prank(user1);
    account.executeCall(payable(address(mockERC721)), 0, erc721TransferCall);
  }
}
