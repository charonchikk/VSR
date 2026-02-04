// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";


contract RTKCoin is ERC20, ERC20Votes  {
    constructor(string memory name, string memory symbol) ERC20 ("RTKCoin", "RTK") EIP712(name, "1") {
        _mint(msg.sender, 20000000 * 10**12);
    }

    function _update(address from, address to, uint amount) internal override(ERC20,ERC20Votes) {
    super._update(from, to, amount);
    }

    function decimals() public view override returns (uint8) {
        return 12;
    }
}