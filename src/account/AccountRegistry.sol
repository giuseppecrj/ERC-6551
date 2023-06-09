// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces
import {IRegistry} from "./interfaces/IRegistry.sol";

// libraries
import {MinimalProxyStore} from "./libraries/MinimalProxyStore.sol";

// contracts
import {Account} from "./Account.sol";

/// @title A registry for token bound accounts
/// @dev Determines the address fo each token bound account and performs deployment of accounts
contract AccountRegistry is IRegistry {
  // @dev Address of the account implementation
  address public immutable implementation;

  constructor(address _implementation) {
    implementation = _implementation;
  }

  /// @dev Deploys an account for an ERC721 token. Will revert if acount has already been deployed.
  /// @param tokenCollection Address of the ERC721 token contract
  /// @param tokenId ID of the token
  /// @return account Address of the account
  function createAccount(
    address tokenCollection,
    uint256 tokenId
  ) external override returns (address) {
    return _createAccount(block.chainid, tokenCollection, tokenId);
  }

  /// @dev Gets the address of the account for an ERC721 token.
  /// If account is not yet deployed, returns the address if will be deployed to
  /// @param tokenCollection Address of the ERC721 token contract
  /// @param tokenId ID of the token
  /// @return account Address of the account
  function account(
    address tokenCollection,
    uint256 tokenId
  ) external view override returns (address) {
    return _account(block.chainid, tokenCollection, tokenId);
  }

  function _createAccount(
    uint256 chainId,
    address tokenCollection,
    uint256 tokenId
  ) internal returns (address) {
    bytes memory encodedTokenData = abi.encode(
      chainId,
      tokenCollection,
      tokenId
    );

    bytes32 salt = keccak256(encodedTokenData);

    address accountProxy = MinimalProxyStore.cloneDeterministic(
      implementation,
      encodedTokenData,
      salt
    );

    emit AccountCreated(accountProxy, tokenCollection, tokenId);

    return accountProxy;
  }

  function _account(
    uint256 chainId,
    address tokenCollection,
    uint256 tokenId
  ) internal view returns (address) {
    bytes memory encodedTokenData = abi.encode(
      chainId,
      tokenCollection,
      tokenId
    );

    bytes32 salt = keccak256(encodedTokenData);

    address accountProxy = MinimalProxyStore.predictDeterministicAddress(
      implementation,
      encodedTokenData,
      salt,
      address(this)
    );

    return accountProxy;
  }
}
