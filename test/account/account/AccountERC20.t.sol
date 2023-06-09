// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// utils
import {AccountBaseSetup} from "test/account/AccountBaseSetup.sol";

//interfaces

//libraries

//contracts
import {Account} from "src/account/Account.sol";
import {MockERC20} from "test/mocks/MockERC20.sol";
import {MockERC721} from "test/mocks/MockERC721.sol";

contract AccountERC20Test is AccountBaseSetup {
  MockERC721 public tokenCollection;
  MockERC20 public mockERC20;

  function setUp() external {
    tokenCollection = new MockERC721();
    mockERC20 = new MockERC20();
  }

  function test_transferERC20PreDeploy(uint256 tokenId) external {
    address user1 = _randomAddress();

    address computedAccountAddress = accountRegistry.account(
      address(tokenCollection),
      tokenId
    );

    tokenCollection.mint(user1, tokenId);
    assertEq(tokenCollection.ownerOf(tokenId), user1);

    mockERC20.mint(computedAccountAddress, 1 ether);
    assertEq(mockERC20.balanceOf(computedAccountAddress), 1 ether);

    address acccountAddress = accountRegistry.createAccount(
      address(tokenCollection),
      tokenId
    );

    Account account = Account(payable(acccountAddress));

    bytes memory erc20TransferCall = abi.encodeWithSelector(
      mockERC20.transfer.selector,
      user1,
      1 ether
    );

    vm.prank(user1);
    account.executeCall(payable(address(mockERC20)), 0, erc20TransferCall);

    assertEq(mockERC20.balanceOf(user1), 1 ether);
    assertEq(mockERC20.balanceOf(computedAccountAddress), 0);
  }

  function test_transferERC20PostDeploy(uint256 tokenId) external {
    address user1 = _randomAddress();

    address acccountAddress = accountRegistry.createAccount(
      address(tokenCollection),
      tokenId
    );

    tokenCollection.mint(user1, tokenId);
    assertEq(tokenCollection.ownerOf(tokenId), user1);

    mockERC20.mint(acccountAddress, 1 ether);
    assertEq(mockERC20.balanceOf(acccountAddress), 1 ether);

    Account account = Account(payable(acccountAddress));

    bytes memory erc20TransferCall = abi.encodeWithSelector(
      mockERC20.transfer.selector,
      user1,
      1 ether
    );

    vm.prank(user1);
    account.executeCall(payable(address(mockERC20)), 0, erc20TransferCall);

    assertEq(mockERC20.balanceOf(user1), 1 ether);
    assertEq(mockERC20.balanceOf(acccountAddress), 0);
  }
}
