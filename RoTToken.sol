// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RoTToken is ERC20 {

    struct TokenLockDefinition {
        address receiver; // Token receiver address
        uint256 amount; // Locked token amount
        uint256 releaseTime; // Time format is UTC Unix Timestamp
    }
    
    address public _icoWallet = 0xf0B19DEa23EA5d9e7895D12C607a67d7068FEde7;
    address public _teamWallet = 0xbD236e9eEcAD891FBbF4895caeB6276F61303D07;
    address public _marketingWallet = 0x739C058a525aDf8604559608D3a351f74F316372;
    address public _daoWallet = 0xa5beAc34eEbEE0F30211a0c8e1829a919ab2cAC7;
    

    // Token lock definitions
    TokenLockDefinition[7] public _lockers;

    constructor() ERC20("Rage of Titans Token", "RoT") {
        _mint(address(this), 1000000000 * (10 ** uint256(decimals()))); // Fixed amount of 1 Billion tokens are minted
        
        // Tokens locked for different timelines
        _lockers[0] = TokenLockDefinition(_teamWallet, 30000000 * (10 ** uint256(decimals())), 1660521600); // [0] Team Release 1 - 30M Tokens - Near Closed Beta Release - 3% - At UTC Monday, August 15th, 2022 00:00:00
        _lockers[1] = TokenLockDefinition(_teamWallet, 30000000 * (10 ** uint256(decimals())), 1665792000); // [1] Team Release 2 - 30M Tokens  - Public Beta Release - 3% - At UTC Saturday, October 15th, 2022 00:00:00
        _lockers[2] = TokenLockDefinition(_teamWallet, 40000000 * (10 ** uint256(decimals())), 1673740800); // [2] Team Release 3 - 40M Tokens - Public Release - 4% - At UTC Sunday, January 15th, 2023 00:00:00
        _lockers[3] = TokenLockDefinition(_teamWallet, 50000000 * (10 ** uint256(decimals())), 1684108800); // [3] Team Release 4 - 50M Tokens - 6mo After Public Release - 5% - At UTC Monday, May 15th, 2023 00:00:00
        _lockers[4] = TokenLockDefinition(_marketingWallet, 100000000 * (10 ** uint256(decimals())), 1648771200); // [4] Marketing Release - 100M Tokens - Before Alpha Release - 10% - At UTC Friday, Apr 1st, 2022 00:00:00
        _lockers[5] = TokenLockDefinition(_daoWallet, 200000000 * (10 ** uint256(decimals())), 1671062400); // [5] Reserve Release - 200M Tokens - Before Public Release - 20% - At UTC Thursday, 15.12.2022 00:00:00
        _lockers[6] = TokenLockDefinition(_daoWallet, 200000000 * (10 ** uint256(decimals())), 1671062400); // [6] Treasury Release - 200M Tokens - Before Public Release - 20% - At UTC Thursday 15.12.2022 00:00:00
        
        // Send 300M Tokens to the ICO Distribution Wallet ( 25% ICO and 5% Partnerships)
        _transfer(address(this), _icoWallet, 300000000 * (10 ** uint256(decimals())));
        
        // Total of 1 Billion tokens are distributed or locked.
    }
    
    /**
     * @notice Overloaded decimal count
     */
    function decimals() public view virtual override returns (uint8) {
        return 4;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release(uint8 id) public virtual {
        // Array index check
        require(id < _lockers.length, "Error: Unknown token definition");
        
        // Is definition deleted?
        require(_lockers[id].amount > 0, "Error: Locker item deleted");
        
        // Token unlock release time check
        require(block.timestamp >= _lockers[id].releaseTime, "Error: Not reached the contract's unlock time yet");

        // Total balance of this address
        uint256 totalBalance = balanceOf(address(this));

        // Check if there are enough tokens to unlock and send
        require(totalBalance >= _lockers[id].amount, "Error: Not enough tokens to release");

        // Send the tokens to the receiver address since the requirements are fulfilled
        _transfer(address(this), _lockers[id].receiver, _lockers[id].amount);

        // Delete the locker definition after the tokens sent and it will be unusable anymore (Makes the struct values all zeros, so that's the way how it becomes 'unusable')
        delete _lockers[id];
    }
}