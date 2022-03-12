//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MoveDoram is ERC721Enumerable, ReentrancyGuard, Ownable {
    
    function tokenURI(uint256 tokenId) override public pure returns (string memory) {
        string memory output = '<svg xmlns="http://www.w3.org/2000/svg" width="1047" height="589" viewBox="-523.5 -306.5 1047 589" fill="none"><path type="Path" fill="#000000" fill-rule="nonzero" stroke="#000000" stroke-width="1" d="M182.5,-29.5c0,93.88841 -76.11159,170 -170,170c-93.88841,0 -170,-76.11159 -170,-170c0,-93.88841 76.11159,-170 170,-170c93.88841,0 170,76.11159 170,170z"><animate attributeName="d" values="M182.5,-29.5c0,93.88841 -76.11159,170 -170,170c-93.88841,0 -170,-76.11159 -170,-170c0,-93.88841 76.11159,-170 170,-170c93.88841,0 170,76.11159 170,170z;M182.5,-29.5c0,93.88841 -76.11159,170 -170,170c-93.88841,0 -170,-76.11159 -170,-170c0,-93.88841 76.11159,-170 170,-170c93.88841,0 170,76.11159 170,170z;" dur="5s" repeatCount="indefinite"/></path> <path type="Path" fill="#00f8ff" fill-rule="nonzero" stroke="#000000" stroke-width="1" d="M119.09038,-30.5c0,59.42052 -48.16986,107.59038 -107.59038,107.59038c-59.42052,0 -107.59038,-48.16986 -107.59038,-107.59038c0,-59.42052 48.16986,-107.59038 107.59038,-107.59038c59.42052,0 107.59038,48.16986 107.59038,107.59038z"><animate attributeName="d" values="M119.09038,-30.5c0,59.42052 -48.16986,107.59038 -107.59038,107.59038c-59.42052,0 -107.59038,-48.16986 -107.59038,-107.59038c0,-59.42052 48.16986,-107.59038 107.59038,-107.59038c59.42052,0 107.59038,48.16986 107.59038,107.59038z;M68.61963,-30.5c0,31.5463 -25.57333,57.11963 -57.11963,57.11963c-31.5463,0 -57.11963,-25.57333 -57.11963,-57.11963c0,-31.5463 25.57333,-57.11963 57.11963,-57.11963c31.5463,0 57.11963,25.57333 57.11963,57.11963z;" dur="5s" repeatCount="indefinite"/></path> <path type="Path" fill="#6600ff" fill-rule="nonzero" stroke="#000000" stroke-width="1" d="M132.72018,-32c0,66.11963 -53.60055,119.72018 -119.72018,119.72018c-66.11963,0 -119.72018,-53.60055 -119.72018,-119.72018c0,-66.11963 53.60055,-119.72018 119.72018,-119.72018c66.11963,0 119.72018,53.60055 119.72018,119.72018z"><animate attributeName="d" values="M132.72018,-32c0,66.11963 -53.60055,119.72018 -119.72018,119.72018c-66.11963,0 -119.72018,-53.60055 -119.72018,-119.72018c0,-66.11963 53.60055,-119.72018 119.72018,-119.72018c66.11963,0 119.72018,53.60055 119.72018,119.72018z;M57.23573,-32c0,24.43072 -19.80501,44.23573 -44.23573,44.23573c-24.43072,0 -44.23573,-19.80501 -44.23573,-44.23573c0,-24.43072 19.80501,-44.23573 44.23573,-44.23573c24.43072,0 44.23573,19.80501 44.23573,44.23573z;" dur="5s" repeatCount="indefinite"/></path> <path type="Path" fill="#fff800" fill-rule="nonzero" stroke="#000000" stroke-width="1" d="M90.51559,-31.5c0,43.6391 -35.37649,79.01559 -79.01559,79.01559c-43.6391,0 -79.01559,-35.37649 -79.01559,-79.01559c0,-43.6391 35.37649,-79.01559 79.01559,-79.01559c43.6391,0 79.01559,35.37649 79.01559,79.01559z"><animate attributeName="d" values="M90.51559,-31.5c0,43.6391 -35.37649,79.01559 -79.01559,79.01559c-43.6391,0 -79.01559,-35.37649 -79.01559,-79.01559c0,-43.6391 35.37649,-79.01559 79.01559,-79.01559c43.6391,0 79.01559,35.37649 79.01559,79.01559z;M39.60855,-31.5c0,15.52392 -12.58463,28.10855 -28.10855,28.10855c-15.52392,0 -28.10855,-12.58463 -28.10855,-28.10855c0,-15.52392 12.58463,-28.10855 28.10855,-28.10855c15.52392,0 28.10855,12.58463 28.10855,28.10855z;" dur="5s" repeatCount="indefinite"/></path></svg>';
        
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Move Doram", "description": "", "image_data": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '", "animation_url": "https://dentou-s3.s3.ap-northeast-1.amazonaws.com/NFT/for_NFT_test/2020_05_10_anotokini_demo2.wav"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function claim(string memory nickname) public nonReentrant onlyOwner {
        uint256 tokenId = s2i(nickname);
        _safeMint(_msgSender(), tokenId);
    }
    
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
    
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
    
    function s2b(string memory s) internal pure returns(bytes memory) {
        return bytes(s);
     }
    
    function b2i(bytes memory _bytes) internal pure returns (uint256 value) {
        assembly {
            value := mload(add(_bytes, 0x20))
        }
    }
    
    function s2i(string memory s) internal pure returns(uint256) {
        return b2i(s2b(s));
    }
    
    constructor() ERC721("MoveDoram2", "MD") Ownable() {}
}

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