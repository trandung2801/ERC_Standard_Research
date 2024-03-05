pragma solidity ^0.8.20;

import {IERC721} from "./IERC721.sol";
import {IERC721Receiver} from "./IERC721Receiver.sol";
import {IERC721Metadata} from "./extensions/IERC721Metadata.sol";

import {IERC165, ERC165} from "./ERC165/ERC165.sol";

abstract contract ERC721 is IERC721, IERC721Metadata {
    using String for uint256;

    string private _name;
    string private _symbol;

    mapping(uint256 tokenId => address) private _owners;
    mapping(address owner => uint256) private _balances;
    mapping(uint256 tokenId => address) private _tokenApprovals;
    mapping(address owner => mapping(address operator => bool) private _operatorApprovals);

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceID == 0x80ac58cd;
    }

     //getName
    function name() public view virtual returns (string memory) {
        return _name;
    }

    //get symbol
    function symbol() public view virtual returns (string memory) {
        return _name;
    }

    //get balance of address
    function balanceOf(address account) public view virtual returns (uint256) {
        require(account != address(0), "Address is zero address");
        return _balances[account];
    }


    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        return _requireOwned(tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }


    function approve(address to, uint256 tokenId) public virtual {
        _approve(to, tokenId, msg.sender())
    }

    function getApproved(uint256 tokenId) public view virtual returns (address) {
        _requireOwned(tokenId);

        return _getApproved(tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(msg.sender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual returns(bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual {
        require(from != address(0), "Address send is the zero address");
        require(to != address(0), "Address receiver is the zero address");

        address previousOwner = _update(to, tokenId, msg.sender())
        require(previousOwner == from, "Onwner incorrect");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "")
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual {
        transferFrom(from, to, tokenId)
        _checkOnERC721Received(from, to, tokenId, data);
    }

    function _isAuthorized(address owner, address spender, uint256 tokenId) internal view virtual returns(bool) {
        return
            spender != address(0) &&
            (owner == spender || isApprovedForAll(owner, spender) || _getApproved(tokenId) == spender)
    }

    function _chekAuthorized(address owner, address spender, uint256 tokenId) internal view vitural {
        if(!_isAuthorized(owner, spender, tokenId)) {
            require(owner != address(0), "tokenid does not exist");
            require(owner == address(0), "owner of tokenId is zero address");
        }
    }

    function _increaseBalance(address account, uint128 value) internal virtual {
        unchecked {
            _balances[account] += value;
        }
    }

    function _update(address to, uint256 tokenId, address auth) internal virtual returns (address) {
        address from = _ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            _checkAuthorized(from, auth, tokenId);
        }

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(address(0), tokenId, address(0), false);

            unchecked {
                _balances[from] -= 1;
            }
        }

        if (to != address(0)) {
            unchecked {
                _balances[to] += 1;
            }
        }

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        return from;
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "Can't mint");
        address previousOwner = _update(to, tokenId, address(0));
        require(previousOwner == address(0), "Can't mint");
    }

    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, data);
    }

    function _burn(uint256 tokenId) internal {
        address previousOwner = _update(address(0), tokenId, address(0));
        require(previousOwner != address(0), "Can't burn");
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(to != address(0), "Receiver address is zero address");
        address previousOwner = _update(to, tokenId, address(0));
        require(previousOwner != address(0), "send address is zero address");
        require(previousOwner == from, "don't stransfer");
    }

    function _safeTransfer(address from, address to, uint256 tokenId) internal {
        _safeTransfer(from, to, tokenId, "");
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }




    function _getApproved(uint256 tokenId) internal view virtual returns (address) {
        return _tokenApprovals[tokenId];
    }

    function _approve(address to, uint256 tokenId, address auth) internal {
        _approve(to, tokenId, auth, true);
    }

    function _approve(address to, uint256 tokenId, address auth, bool emitEvent) internal {
        if(emitEvent || auth != address(0)) {
            address owner = _requireOwned(tokenId);
            require(auth != address(0) && owner != auth && isApprovedForAll(owner, auth), "Invalid approvals");

            if (emitEvent) {
                emit Approval(owner, to, tokenId);
            }
        }

        _tokenApprovals[tokenId] = to;
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(operator != address(0), "operator address is zero address");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }


    function _requireOwned(uint256 tokenId) internal view returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "Token does not exist");
        return owner;
    }

    //get address owner of tokenId
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

     function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                require(retval == IERC721Receiver.onERC721Received.selector, "invalid Received");
            } catch (bytes memory reason) {
                require(reason.lenth != 0, "invalid Received")
                /// @solidity memory-safe-assembly
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }



}




