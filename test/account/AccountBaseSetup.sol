// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// utils
import {TestUtils} from "test/utils/TestUtils.sol";

//interfaces
import {IRegistry, IRegistryEvents} from "src/account/interfaces/IRegistry.sol";

//libraries
import {MinimalProxyStore} from "src/account/libraries/MinimalProxyStore.sol";

//contracts
import {CrossChainExecutorList} from "src/account/CrossChainExecutorList.sol";
import {Account} from "src/account/Account.sol";
import {AccountRegistry} from "src/account/AccountRegistry.sol";

contract AccountBaseSetup is TestUtils {
  CrossChainExecutorList public ccExecutorList;
  AccountRegistry public accountRegistry;
  Account public accountImplementation;
  address public deployer;

  constructor() {
    deployer = _randomAddress();
    vm.startPrank(deployer);

    ccExecutorList = new CrossChainExecutorList();
    accountImplementation = new Account(ccExecutorList);
    accountRegistry = new AccountRegistry(address(accountImplementation));
  }
}
