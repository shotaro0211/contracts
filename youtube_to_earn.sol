//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract YoutubeToEarn is Ownable {
    ERC20 private _token;
    uint256 private _pass;
    address[] private _user;

    function addToken(uint256 value, uint256 pass) public payable onlyOwner {
        require(value <= _token.allowance(msg.sender, address(this)) && value >= 1 ether && _checkUser());
        _token.transferFrom(msg.sender, address(this), value);
        _pass = pass;
    }

    function removeToken() public payable onlyOwner {
        _token.transfer(msg.sender, balance());
    }

    function getPass() public view onlyOwner returns (uint256) {
        return _pass;
    }

    function giveToken(uint256 pass) public payable {
        require(pass == _pass);
        _user.push(msg.sender);
        _token.transfer(msg.sender, 1 ether);
    }

    function _checkUser() internal view returns (bool) {
        for(uint256 i = 0; i < _user.length; i++) {
            if (_user[i] == msg.sender) {
                return false;
            } 
        } 
        return true;
    }

    function balance() public view returns (uint256) {
        return _token.balanceOf(address(this));
    }

    constructor(address tokenAddress) Ownable() {
        _token = ERC20(tokenAddress);
    }
}