//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//// This is a tribute to the original Loot.
contract Nobunaga is ERC721Enumerable, ReentrancyGuard, Ownable {
    
    mapping (uint256 => uint256[]) private _ids;
    string[] private _prefs;
    
    function getSvg(uint256 tokenId) public view returns (string memory) {
        string[49] memory parts;
        uint256[] memory ids = _ids[tokenId];

        parts[0] = '<svg class="c-map-area-map" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="562.462px" height="554.053px" viewBox="-0.241 -0.241 562.462 554.053" enable-background="new -0.241 -0.241 562.462 554.053" xml:space="preserve">';

        for(uint256 i = 0; i < ids.length; i++) { 
            if (i == 0) {
                parts[i + 1] = string(abi.encodePacked('<g fill="#B94047">', _prefs[ids[i] - 1], '</g>'));
            } else {
                parts[i + 1] = _prefs[ids[i] - 1];
            }
        }

        parts[48] = '</svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12], parts[13], parts[14], parts[15], parts[16]));
        output = string(abi.encodePacked(output, parts[17], parts[18], parts[19], parts[20], parts[21], parts[22], parts[23], parts[24]));
        output = string(abi.encodePacked(output, parts[25], parts[26], parts[27], parts[28], parts[29], parts[30], parts[31], parts[32]));
        output = string(abi.encodePacked(output, parts[33], parts[34], parts[35], parts[36], parts[37], parts[38], parts[39], parts[40]));
        output = string(abi.encodePacked(output, parts[41], parts[42], parts[43], parts[44], parts[45], parts[46], parts[47], parts[48]));
        return output;
    }

    function _addIds(uint256 tokenId, uint256 addId) internal {
        _ids[tokenId].push(addId);
    }

    function addPrefs(string[] memory path) public payable onlyOwner {
        for(uint256 i = 0; i < path.length; i++) {
            _prefs.push(path[i]);
        }
        claim();
    }

    function _connect(address to, uint256 tokenId) internal returns (address) {
        for(uint256 i = 1; i <= totalSupply(); i++) {
            if (to == ownerOf(i) && tokenId != i) {
                for(uint256 j = 0; j < _ids[tokenId].length; j++) {
                    _addIds(i, _ids[tokenId][j]);
                }
                to = 0x000000000000000000000000000000000000dEaD;
            }
        } 
        return to;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        to = _connect(to, tokenId);
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        to = _connect(to, tokenId);
        super.safeTransferFrom(from, to, tokenId, _data);
    }
    
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        to = _connect(to, tokenId);
        super.transferFrom(from, to, tokenId);
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string memory output = getSvg(tokenId);
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "Japan #', toString(tokenId), '", "description": "Let`s unify Japan.", "image_data": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }
    
    function claim() public nonReentrant onlyOwner {
        require(totalSupply() < 49, "Token ID invalid");

        for(uint256 i = totalSupply() + 1; i <= _prefs.length; i++) {
            _safeMint(owner(), i);
        }
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
    
    constructor() ERC721("Unification of Japan", "JPN") Ownable() {
      for(uint256 i = 1; i < 48; i++) {
          _ids[i].push(i); 
      }    
    }
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