// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// utils
import {AccountBaseSetup} from "test/account/AccountBaseSetup.sol";

//interfaces

//libraries

//contracts
import {Account} from "src/account/Account.sol";
import {MockERC721} from "test/mocks/MockERC721.sol";

contract AccountERC20Test is AccountBaseSetup {
  MockERC721 public tokenCollection;
}
