// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces

// libraries

// contracts
import {ERC721Holder} from "openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol";
import {ERC1155Holder} from "openzeppelin-contracts/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract MinimalReceiver is ERC721Holder, ERC1155Holder {

  // solhint-disable-next-line no-empty-blocks
  receive() external payable virtual {}
}
