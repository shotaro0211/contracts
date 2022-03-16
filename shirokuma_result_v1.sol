//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ShirokumaResultV1 is Ownable {

    struct Result {
        bool[10] correct;
    }
    Result[] private _result;

    function _addResult(bool[10] memory correct) internal {
        _result.push(Result(correct));
    }

    function getResult(uint256 index) public view returns (Result memory) {
        return _result[index];
    }

    function createResult(bool[10] memory correct) public payable onlyOwner {
        _addResult(correct);
    }

    constructor() Ownable() {}
}