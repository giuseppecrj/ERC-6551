// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MockERC721 is ERC721 {
  // solhint-disable-next-line no-empty-blocks
  constructor() ERC721("MockERC721", "M721") {}

  function mint(address to, uint256 tokenId) external {
    _safeMint(to, tokenId);
  }
}
