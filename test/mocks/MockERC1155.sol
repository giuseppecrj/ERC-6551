// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces

// libraries

// contracts
import {ERC1155} from "openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";

contract MockERC1155 is ERC1155 {
  // solhint-disable-next-line no-empty-blocks
  constructor() ERC1155("http://MockERC1155.com") {}

  function mint(address to, uint256 tokenId, uint256 amount) external {
    _mint(to, tokenId, amount, "");
  }
}
