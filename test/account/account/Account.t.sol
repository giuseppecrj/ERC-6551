// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// utils
import {AccountBaseSetup} from "test/account/AccountBaseSetup.sol";

//interfaces

//libraries

//contracts
import {MockERC721} from "test/mocks/MockERC721.sol";
import {Account} from "src/account/Account.sol";

contract AccountTest is AccountBaseSetup {
  MockERC721 public tokenCollection;

  function setUp() external {
    tokenCollection = new MockERC721();
  }

  function test_customExecutorCalls(uint256 tokenId) external {
    address user1 = _randomAddress();
    address user2 = _randomAddress();

    tokenCollection.mint(user1, tokenId);
    assertEq(tokenCollection.ownerOf(tokenId), user1);

    address accountAddress = accountRegistry.createAccount(
      address(tokenCollection),
      tokenId
    );

    vm.deal(accountAddress, 1 ether);

    Account account = Account(payable(accountAddress));

    assertEq(account.isAuthorized(user2), false);

    vm.prank(user1);
    account.setExecutor(user2);

    assertEq(account.isAuthorized(user2), true);

    vm.prank(user2);
    account.executeTrustedCall(user2, 0.1 ether, "");

    assertEq(user2.balance, 0.1 ether);
  }
}
