// SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RoTToken is ERC20 {

    struct TokenLockDefinition {
        address receiver; // Token receiver address
        uint256 amount; // Locked token amount
        uint256 releaseTime; // Time format is UTC Unix Timestamp
    }
    
    address public _icoWallet = 0xDa315c070626C858AB899973068Aa18dbfe31Ea3;

    // Token lock definitions
    TokenLockDefinition[7] public _lockers;

    constructor() ERC20("Rage of Titans Token", "RoT") {
        _mint(address(this), 1000000000 * (10 ** uint256(decimals())));
        
        _lockers[0] = TokenLockDefinition(0x8416c47dc391f1A8Aa4e77AcD986160cc5dA78d7, 50000000 * (10 ** uint256(decimals())), 1632761000); // [0] Team Release 1 - 50M Tokens - At UTC Monday, September 27, 2021 16:35:00 - To address 0xDa315c070626C858AB899973068Aa18dbfe31Ea3
        _lockers[1] = TokenLockDefinition(0x8416c47dc391f1A8Aa4e77AcD986160cc5dA78d7, 50000000 * (10 ** uint256(decimals())), 1632761000); // [1] Team Release 2 - 50M Tokens - At UTC Monday, September 27, 2021 16:35:00 - To address 0xDa315c070626C858AB899973068Aa18dbfe31Ea3
        _lockers[2] = TokenLockDefinition(0x8416c47dc391f1A8Aa4e77AcD986160cc5dA78d7, 50000000 * (10 ** uint256(decimals())), 1632761000); // [2] Team Release 3 - 50M Tokens - At UTC Monday, September 27, 2021 16:35:00 - To address 0xDa315c070626C858AB899973068Aa18dbfe31Ea3
        _lockers[3] = TokenLockDefinition(0x8416c47dc391f1A8Aa4e77AcD986160cc5dA78d7, 100000000 * (10 ** uint256(decimals())), 1632761000); // [3] Team Release 4 - 100M Tokens - At UTC Monday, September 27, 2021 16:35:00 - To address 0xDa315c070626C858AB899973068Aa18dbfe31Ea3
        _lockers[4] = TokenLockDefinition(0x7a503Ea8Eae86b482464772a9ec4a6b0Fe5699Bc, 100000000 * (10 ** uint256(decimals())), 1632761000); // [4] Marketing Release - 100M Tokens - At UTC Epoch 12.12.2022 - To address 0xDa315c070626C858AB899973068Aa18dbfe31Ea3
        _lockers[5] = TokenLockDefinition(0x1701681C9a8243047d332aA08eE41b29c6350758, 200000000 * (10 ** uint256(decimals())), 1632761000); // [5] Reserve Release - 200M Tokens - At UTC Epoch 12.12.2022 - To address 0xDa315c070626C858AB899973068Aa18dbfe31Ea3
        _lockers[6] = TokenLockDefinition(0x1701681C9a8243047d332aA08eE41b29c6350758, 200000000 * (10 ** uint256(decimals())), 1632761000); // [6] Treasury Release - 200M Tokens - At UTC Epoch 12.12.2022 - To address 0xDa315c070626C858AB899973068Aa18dbfe31Ea3
        
        // Send 250M Tokens to the ICO Distribution Wallet
        _transfer(address(this), _icoWallet, 250000000 * (10 ** uint256(decimals())));
        
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