// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces

// libraries

// contracts
interface IRegistryEvents {
  event AccountCreated(
    address account,
    address indexed tokenContract,
    uint256 indexed tokenId
  );
}

interface IRegistry is IRegistryEvents {
  function createAccount(
    address tokenContract,
    uint256 tokenId
  ) external returns (address);

  function account(
    address tokenContract,
    uint256 tokenId
  ) external view returns (address);
}
