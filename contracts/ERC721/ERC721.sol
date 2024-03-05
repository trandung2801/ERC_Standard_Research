pragma solidity ^0.8.20;

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

    function _approve(address to, uint256 tokenId, address auth) internal {
        _approve(to, tokenId, auth, true);
    }

    function _approve(address to, uint256 tokenId, address auth, bool emitEvent) internal {
        if(emitEvent || auth != address(0)) {
            address owner = _requireOwned(tokenId);


        }
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



}