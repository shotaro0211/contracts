//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ShirokumaQ is Ownable, ReentrancyGuard {

    struct Question {
        string title;
        string[] choices;
        uint256 answer;
        string description;
        address owner;
    }
    Question[] private _questions;

    function getQuestion(uint256 tokenId) public view returns (Question memory) {
        return _questions[tokenId];
    }

    function setQuestion(uint256 tokenId, string memory title, string[] memory choices, uint256 answer, string memory description) public payable onlyOwner nonReentrant {
        _questions[tokenId] = Question(
                title,
                choices,
                answer,
                description,
                _questions[tokenId].owner
        );
    }

    function create(string memory title, string[] memory choices, uint256 answer, string memory description, address owner) public onlyOwner nonReentrant {
        _addQuestions(title, choices, answer, description, owner);
    }

    function _addQuestions(string memory title, string[] memory choices, uint256 answer, string memory description, address owner) internal {
        _questions.push(
            Question(
                title,
                choices,
                answer,
                description,
                owner
            )
        );
    }

    constructor() Ownable() {}
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}

library Convert {
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    function toStringArray(uint256 value) internal pure returns (string[] memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            string[] memory zero = new string[](1);
            zero[0] = "0";
            return zero;
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        
        string[] memory str = new string[](digits);
        while (value != 0) {
            digits -= 1;
            bytes memory buffer = new bytes(1);
            buffer[0] = bytes1(uint8(48 + uint256(value % 10)));
            str[digits] = string(buffer);
            value /= 10;
        }
        return str;
    }
    function toStringEth(uint value) internal pure returns (string memory) {
        string[22] memory str;
        str[0] = "";
        str[1] = "";
        str[2] = "0";
        str[3] = ".";
        for(uint256 i = 4; i < str.length; i++) {
            str[i] = "0";
        }
        string[] memory arrayStr = Convert.toStringArray(value);
        if (arrayStr.length <= 18) {
            for(uint256 i = 0; i < arrayStr.length; i++) {
                str[str.length - i - 1] = arrayStr[arrayStr.length - i - 1];
            }
        } else {
            for(uint256 i = 0; i < 18; i++) {
                str[str.length - i - 1] = arrayStr[arrayStr.length - i - 1];
            }
            for(uint256 i = 18; i < arrayStr.length; i++) {
                str[str.length - i - 2] = arrayStr[arrayStr.length - i - 1];
            }
        }
        string memory output;
        for(uint256 i = 0; i < 7; i++) {
            output = string(abi.encodePacked(output, str[i]));
        }

        return output;
    }
}