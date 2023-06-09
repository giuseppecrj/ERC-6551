// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces

// libraries

// contracts
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

contract CrossChainExecutorList is Ownable2Step {
  mapping(uint256 => mapping(address => bool)) public isExecutor;


  /// @notice Enables or disables an executor for a given chain ID.
  /// @param chainId The chain ID of the network the executor exists on
  /// @param executor The address of the executor
  /// @param enabled true if the executor should be enabled, false otherwise
  function setCrossChainExecutor(
    uint256 chainId,
    address executor,
    bool enabled
  ) external onlyOwner {
    isExecutor[chainId][executor] = enabled;
  }
}
