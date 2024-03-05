// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */

abstract contract ERC20 is IERC20, IERC20Metadata {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;


    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_; string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    //getName
    function name() public view virtual returns (string memory) {
        return _name;
    }

    //get symbol
    function symbol() public view virtual returns (string memory) {
        return _name;
    }

    //get decimal
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    //get total supply
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    //get balance of address
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owner = msg.sender();
        _transfer(owner, to, value);
        return true;
    }
    // Trả về số tiền mà người thứ 3 được chủ token cấp phép chuyển
    function allowance(address owner, address spender) public view virtual returns(uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, unit256 value) public view virtual returns (bool) {
        address owner = msg.sender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = msg.sender();
        _spenderAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }


    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "Address send is the zero address");
        require(to != address(0), "Address receiver is the zero address");

        _update(from, to, value);
    }

    // Các hàm mint, burn, tranfer có logic này nhiều lần nên gộp thành update
    function _update(address from, address to, uint256 value) internal virtual {
        if(from == address(0)) {
            _totalSupply += value; // mint
        } else {
            uint256 fromBalance = _balances[from]; // get amount address send
            require(fromBalance >= value, "Address send has insufficient balance");
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }

        if(to == address(0)) {
            unchecked {
                _totalSupply -= value; // burn
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Tranfer(from, to, value);
    }

    function _mint(address account, unit256 value) internal {
        require(account != address(0), "Address mint is the zero address");
        _update(address(0), account, value)

    }

    function _burn(address account, unit256 value) internal {
        require(account != address(0), "Address burn is the zero address");
        _update(account, address(0), value)
    }

    function _approve(address owner, address spender, uint256 value) internal {
         _approve(owner, spender, value, true);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
         require(owner != address(0), "Address is zero address");
         require(spender != address(0), "Spender is zero address");
         _allowances[owner][spender] = value;
         if(emitEvent) {
            emit Approval(owner, spender, value);
         }
    }

    // Gán lại số tiền mà bên thứ 3 được phép sử dụng
    function _spendAllowance(address owner, address spender, uint256 value) internal  virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if(currentAllowance != type(uint256).max) {
            require(currentAllowance >= value, "Address has insufficient balance");
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }

}