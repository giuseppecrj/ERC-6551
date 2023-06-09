// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.19;

// interfaces
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {IERC1271} from "openzeppelin-contracts/contracts/interfaces/IERC1271.sol";
import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {IERC1155Receiver} from "openzeppelin-contracts/contracts/token/ERC1155/IERC1155Receiver.sol";
import {IAccount} from "./interfaces/IAccount.sol";

// libraries
import {SignatureChecker} from "openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";
import {MinimalProxyStore} from "./libraries/MinimalProxyStore.sol";

// contracts
import {CrossChainExecutorList} from "./CrossChainExecutorList.sol";
import {MinimalReceiver} from "./MinimalReceiver.sol";
import {ERC1155Receiver} from "openzeppelin-contracts/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract Account is IERC165, IERC1271, IAccount, MinimalReceiver {
  error NotAuthorized();
  error AccountLocked();
  error ExceedsMaxLockTime();

  CrossChainExecutorList public immutable executorList;

  /// @dev Timestamp at which Account will unlock
  uint256 public unlockTimestamp;

  /// @dev Mapping from owner address to executor address
  mapping(address => address) public executor;

  /// @dev Emitted when the lock status of the Account is updated
  event LockUpdated(uint256 timestamp);

  /// @dev Emitted when the executor is updated
  event ExecutorUpdated(address owner, address executor);

  /// @dev Ensures execution can only occur if account is unlocked
  modifier onlyUnlocked() {
    // solhint-disable-next-line not-rely-on-time
    if (unlockTimestamp > block.timestamp) revert AccountLocked();
    _;
  }

  constructor(CrossChainExecutorList _executorList) {
    executorList = _executorList;
  }

  /// @dev If account is unlocked and an executor is set, pass call to executor
  // solhint-disable-next-line no-complex-fallback
  fallback(
    bytes calldata data
  ) external payable onlyUnlocked returns (bytes memory result) {
    address _owner = owner();
    address _executor = executor[_owner];

    // accept funds if executor is undefined or cannot be called
    if (_executor.code.length == 0) return "";

    return _call(_executor, 0, data);
  }

  /// @dev Executes a transaction from the Account. Must be called by the owner.
  /// @param to The address of the contract to call
  /// @param value The amount of ETH to send with the transaction
  /// @param data The encoded payload to send with the transaction
  function executeCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external payable override onlyUnlocked returns (bytes memory result) {
    if (msg.sender != owner()) revert NotAuthorized();
    return _call(to, value, data);
  }

  /// @dev Executes a transaction from the Account. Must be called by an authorized executor.
  /// @param to The address of the contract to call
  /// @param value The amount of ETH to send with the transaction
  /// @param data The data to send with the transaction
  function executeTrustedCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external payable onlyUnlocked returns (bytes memory result) {
    address _executor = executor[owner()];

    if (msg.sender != _executor) revert NotAuthorized();

    return _call(to, value, data);
  }

  /// @dev Executes a transaction from the Account. Must be called by a trusted cross-chain executor.
  /// Can only be called if account is owned by a token on another chain.
  /// @param to The address of the contract to call
  /// @param value The amount of ETH to send with the transaction
  /// @param data The data to send with the transaction
  function executeCrossChainCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external payable onlyUnlocked returns (bytes memory result) {
    (uint256 chainId, , ) = _context();

    if (chainId != block.chainid) revert NotAuthorized();
    if (!executorList.isExecutor(chainId, msg.sender)) revert NotAuthorized();

    return _call(to, value, data);
  }

  /// @dev Sets executor address for Account, allowing owner to use a custom implementation if the choose to.
  /// When the token controlling the account is transferred, the implementation address will reset
  /// @param _executor The address of the executor
  function setExecutor(address _executor) external onlyUnlocked {
    address _owner = owner();
    if (_owner != msg.sender) revert NotAuthorized();

    executor[_owner] = _executor;

    emit ExecutorUpdated(_owner, _executor);
  }

  /// @dev Locks Account, preventing transactions from being executed until a specified time
  /// @param timestamp The timestamp at which the Account will unlock
  function lock(uint256 timestamp) external onlyUnlocked {
    // solhint-disable-next-line not-rely-on-time
    if (unlockTimestamp > block.timestamp + 365 days)
      revert ExceedsMaxLockTime();

    address _owner = owner();
    if (_owner != msg.sender) revert NotAuthorized();

    unlockTimestamp = timestamp;

    emit LockUpdated(timestamp);
  }

  /// @dev Returns account lock status
  /// @return true if account is locked, false otherwise
  function isLocked() external view returns (bool) {
    // solhint-disable-next-line not-rely-on-time
    return unlockTimestamp > block.timestamp;
  }

  /// @dev Returns true if caller is authorized to execute actions on this account
  /// @param caller the addres to query authorization for
  /// @return true if caller is authorized, false otherwise
  function isAuthorized(address caller) external view returns (bool) {
    (uint256 chainId, address tokenCollection, uint256 tokenId) = _context();

    if (chainId != block.chainid) {
      return executorList.isExecutor(chainId, caller);
    }

    address _owner = IERC721(tokenCollection).ownerOf(tokenId);
    if (caller == _owner) return true;

    address _executor = executor[_owner];
    if (caller == _executor) return true;

    return false;
  }

  /// @dev Implements EIP-1271 signature validation
  /// @param hash The hash of the data that is signed
  /// @param signature The signature object to validate
  function isValidSignature(
    bytes32 hash,
    bytes memory signature
  ) external view returns (bytes4 magicValue) {
    // If account is locked, disable signing
    // solhint-disable-next-line not-rely-on-time
    if (unlockTimestamp > block.timestamp) return 0;

    // If account has an executor, check if executor signature is valid
    address _owner = owner();
    address _executor = executor[_owner];

    if (
      _executor != address(0) &&
      SignatureChecker.isValidSignatureNow(_executor, hash, signature)
    ) {
      return IERC1271(_executor).isValidSignature.selector;
    }

    // Default - check if signature is valid for account owner
    if (SignatureChecker.isValidSignatureNow(_owner, hash, signature)) {
      return IERC1271(_owner).isValidSignature.selector;
    }

    return "";
  }

  /// @dev Implements EIP-165 standard interface detection
  /// @param interfaceId The interface identifier
  /// @return True if the interface is supported, false otherwise
  function supportsInterface(
    bytes4 interfaceId
  ) public view virtual override(IERC165, ERC1155Receiver) returns (bool) {
    if (
      interfaceId == type(IAccount).interfaceId ||
      interfaceId == type(IERC1155Receiver).interfaceId ||
      interfaceId == type(IERC165).interfaceId
    ) {
      return true;
    }

    address _executor = executor[owner()];

    if (_executor != address(0) || _executor.code.length == 0) {
      return false;
    }

    // if interface is not supported by default, check executor
    try IERC165(_executor).supportsInterface(interfaceId) returns (
      bool supported
    ) {
      return supported;
    } catch {
      return false;
    }
  }

  /// @dev Returns the owner of the token that controls this Account (public for Ownable compatibility)
  /// @return The address of the Account owner
  function owner() public view returns (address) {
    (uint256 chainId, address tokenCollection, uint256 tokenId) = _context();

    if (chainId != block.chainid) {
      return address(0);
    }

    return IERC721(tokenCollection).ownerOf(tokenId);
  }

  /// @dev Returns information about the token that owns this account
  /// @return chainId The chainId of the token
  /// @return tokenCollection The address of the token collection
  /// @return tokenId The id of the token
  function token()
    public
    view
    returns (uint256 chainId, address tokenCollection, uint256 tokenId)
  {
    (chainId, tokenCollection, tokenId) = _context();
  }

  /// @dev Returns information about the context of the call to the Account
  function _context() internal view returns (uint256, address, uint256) {
    bytes memory rawContext = MinimalProxyStore.getContext(address(this));
    return abi.decode(rawContext, (uint256, address, uint256));
  }

  /// @dev Executes a low level call to a contract
  function _call(
    address to,
    uint256 value,
    bytes calldata data
  ) internal returns (bytes memory result) {
    bool success;

    (success, result) = to.call{value: value}(data);

    if (!success) {
      // solhint-disable-next-line no-inline-assembly
      assembly {
        revert(add(result, 32), mload(result))
      }
    }
  }
}
