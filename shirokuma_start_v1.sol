//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ShirokumaStartV1 is Ownable {

    address[] private _user;


    function _addUser(address ads) internal {
        _user.push(ads);
    }

    function checkUser(address ads) public view returns (bool) {
        for(uint256 i = 0; i < _user.length; i++) {
            if (_user[i] == ads) {
                return true;
            }
        } 
        return false;
    }

    function addUser(address ads) public payable {
        _addUser(ads);
    }

    constructor() Ownable() {}
}