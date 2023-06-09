// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces

// libraries

// contracts

interface IAccount {
  function owner() external view returns (address);

  function token() external view returns (uint256 chainId, address tokenContract, uint256 tokenId);

  function executeCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external payable returns (bytes memory);
}
