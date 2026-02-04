// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ProfessionalToken is ERC20 {

    constructor(address[] memory members)
        ERC20("Professional", "PROFI")
    {
        uint256 total = 100000 * 10 ** 12;
        uint256 perMember = total / members.length;

        for (uint i = 0; i < members.length; i++) {
            _mint(members[i], perMember);
        }
    }

    function decimals() public pure override returns (uint8) {
        return 12;
    }
}

