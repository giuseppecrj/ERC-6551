// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

//interfaces
import {IRegistryEvents} from "src/account/interfaces/IRegistry.sol";

//libraries
import {MinimalProxyStore} from "src/account/libraries/MinimalProxyStore.sol";

//contracts
import {AccountBaseSetup} from "test/account/AccountBaseSetup.sol";

contract AccountRegistryTest is AccountBaseSetup, IRegistryEvents {
  function test_createAccount(
    address tokenCollection,
    uint256 tokenId
  ) external {
    assertTrue(address(accountRegistry) != address(0));

    address predictedAccountAddress = accountRegistry.account(
      tokenCollection,
      tokenId
    );

    vm.expectEmit(true, true, true, true, address(accountRegistry));
    emit AccountCreated(predictedAccountAddress, tokenCollection, tokenId);
    address accountAddress = accountRegistry.createAccount(
      tokenCollection,
      tokenId
    );

    assertTrue(accountAddress != address(0));
    assertTrue(accountAddress == predictedAccountAddress);
    assertEq(
      MinimalProxyStore.getContext(accountAddress),
      abi.encode(block.chainid, tokenCollection, tokenId)
    );
  }
}
