// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RTKCoin is ERC20 {

    constructor() ERC20("RTKCoin", "RTK") {
        _mint(msg.sender, 20000000 * 10 ** 12);
    }

    function decimals() public pure override returns (uint8) {
        return 12;
    }

}