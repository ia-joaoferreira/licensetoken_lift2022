// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts@4.7.3/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.7.3/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@4.7.3/access/Ownable.sol";

contract LicenseToken is ERC20, Ownable {
	mapping (address => uint256) private expiryDates;

    constructor() ERC20("LicenseToken", "LCT") {
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function getExpiryDate(address user) external returns (uint256){
        return expiryDates[user];
    }

    function createLicense(address user, uint  amount) external onlyOwner {
        uint balance = this.balanceOf(user);
        _mint(user, amount);
        if(balance > 0){ 
            expiryDates[user] += (amount * 365 days);
        }
        else {
            expiryDates[user] = block.timestamp + (amount * 365 days);
        }
    }

    function burn(address user, uint amount) external onlyOwner {
        _burn(user, amount);
    }

    function transfer(address _to, uint _value) public override returns (bool success) {
        return false;
    }

    function checkAndUpdate(address user) external onlyOwner returns (bool valid) {
        if(expiryDates[user] < block.timestamp){ 
            _burn(user, this.balanceOf(user));
            return false;
        } else {
            uint daysRemaning = (expiryDates[user] - block.timestamp) / 60 / 60 / 24; 
            uint correctBalance = (daysRemaning/366)+1; 
            if(this.balanceOf(user)>correctBalance){ 
                _burn(user, this.balanceOf(user)-correctBalance);
            }
            return true;
        }
    }
}
