# <h1 align="center"> ERC-6551: Non-fungible Token Bound Accounts </h1>

This repository provides an implementation for ERC-6551, a standard for creating smart contract accounts for each ERC-721 token.

## Overview

ERC-6551 is a standard which gives every ERC-721 token a smart contract account. These token bound accounts allow ERC-721 tokens to own assets and interact with applications, without requiring changes to existing ERC-721 smart contracts or infrastructure.

## Features

- **ERC-721 Compatibility**: Works seamlessly with existing ERC-721 smart contracts.
- **Permissionless Registry**: Unique smart contract accounts are deployed for each ERC-721 token via a permissionless registry.
- **Deterministic Addresses**: Account addresses for every ERC-721 token are deterministic, derived from a unique combination of implementation address, token contract address, token ID, chain ID, and an optional salt.
- **Interface Standard**: Follows the `IERC6551Account` interface standard for token bound account implementations.
