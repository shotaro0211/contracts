//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BeatLoot is ERC721Enumerable, Ownable, ReentrancyGuard  {
    string[] ipfs;
    
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
    
    function key(uint256 tokenId) internal pure returns (string memory) {
        uint256 rare = random(string(abi.encodePacked(tokenId, "key"))) % 100;
        // 10%
        if (rare < 10) {
            string[5] memory array = ["C", "D", "F", "G", "A"];
            uint256 ran = random(string(abi.encodePacked(tokenId, "key"))) % 5;
            return array[ran];
        // 30%
        } else if (rare < 40) {
            string[5] memory array = ["C#", "D#", "F#", "G#", "A#"];
            uint256 ran = random(string(abi.encodePacked(tokenId, "key"))) % 5;
            return array[ran];
        // 60%
        } else {
            string[2] memory array = ["B", "E"];
            uint256 ran = random(string(abi.encodePacked(tokenId, "key"))) % 2;
            return array[ran];
        }
    }
    
    function bpm(uint256 tokenId) internal pure returns (string memory) {
        uint256 ran = random(string(abi.encodePacked(tokenId, "bpm"))) % 21;
        uint256 ans = 70;
        ans += ran;
        
        return Utils.toString(ans);
    }
    
    function guitarA(uint256 tokenId) internal pure returns (string memory) {
        uint256 rare = random(string(abi.encodePacked(tokenId, "guitarA"))) % 100;
        // 10%
        if (rare < 10) {
            string[5] memory array = ["Hard worker", "Calm arp", "Take a break", "Hope", "Between happiness"];
            uint256 ran = rare % 5;
            return array[ran];
        // 30%
        } else if (rare < 40) {
            string[5] memory array = ["On the way home", "Chill arp", "Dreams that never come true", "Somehow", "Live tomorrow"];
            uint256 ran = rare % 5;
            return array[ran];
        // 60%
        } else {
            string[5] memory array = ["Familiar cityscape", "Day to do nothing", "Usual morning", "After night shift", "Return to that city"];
            uint256 ran = rare % 5;
            return array[ran];
        }
    }
    
    function guitarB(uint256 tokenId) internal pure returns (string memory) {
        uint256 rare = random(string(abi.encodePacked(tokenId, "guitarB"))) % 100;
        // 10%
        if (rare < 10) {
            string[3] memory array = ["Tic tac", "Unceremoniously", "Parentheses"];
            uint256 ran = rare % 3;
            return array[ran];
        // 30%
        } else if (rare < 40) {
            string[3] memory array = ["Cheer up", "Raise", "Friends"];
            uint256 ran = rare % 3;
            return array[ran];
        // 60%
        } else {
            string[4] memory array = ["From you", "Collaborator", "As it is", "Miss you"];
            uint256 ran = rare % 4;
            return array[ran];
        }
    }
    
    function guitarC(uint256 tokenId) internal pure returns (string memory) {
        uint256 rare = random(string(abi.encodePacked(tokenId, "guitarC"))) % 100;
        // 10%
        if (rare < 10) {
            string[3] memory array = ["Shibu", "Vigor", "That's right"];
            uint256 ran = rare % 3;
            return array[ran];
        // 30%
        } else if (rare < 40) {
            string[3] memory array = ["From now on", "Responsibility", "Winning"];
            uint256 ran = rare % 3;
            return array[ran];
        // 60%
        } else {
            string[4] memory array = ["Letter", "Travel destination", "Subtle", "Slope"];
            uint256 ran = rare % 4;
            return array[ran];
        }
    }

    function beats(uint256 tokenId) internal pure returns (string memory) {
        uint256 rare = random(string(abi.encodePacked(tokenId, "Beats"))) % 100;
        // 10%
        if (rare < 10) {
            string[3] memory array = ["Casual", "Behind time", "Sumou"];
            uint256 ran = rare % 3;
            return array[ran];
        // 30%
        } else if (rare < 40) {
            string[3] memory array = ["Lightly", "Popular person", "Ibushi silver"];
            uint256 ran = rare % 3;
            return array[ran];
        // 60%
        } else {
            string[4] memory array = ["Hand King", "Firmly", "2020 Beat", "Like a turtle"];
            uint256 ran = rare % 4;
            return array[ran];
        }
    }
    
    function getLoot(uint256 tokenId) public pure returns (string memory) {
        string[13] memory parts;

        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="350" height="350"><path d="M0 0 L 350 0 L 350 350 L 0 350" fill="black"/><text x="10" y="20" fill="white">';

        parts[1] = string(abi.encodePacked('Key: ', key(tokenId)));

        parts[2] = '</text><text x="10" y="40" fill="white">';

        parts[3] = string(abi.encodePacked('BPM: ', bpm(tokenId)));

        parts[4] = '</text><text x="10" y="60" fill="white">';

        parts[5] = string(abi.encodePacked('Guitar A: ', guitarA(tokenId)));

        parts[6] = '</text><text x="10" y="80" fill="white">';
        
        parts[7] = string(abi.encodePacked('Guitar B: ', guitarB(tokenId)));
        
        parts[8] = '</text><text x="10" y="100" fill="white">';
        
        parts[9] = string(abi.encodePacked('Guitar C: ', guitarC(tokenId)));
        
        parts[10] = '</text><text x="10" y="120" fill="white">';
        
        parts[11] = string(abi.encodePacked('Beats: ', beats(tokenId)));

        parts[12] = '</text></svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8]));
        output = string(abi.encodePacked(output, parts[9], parts[10], parts[11], parts[12]));
        return output;
    }
    
    function attributes(uint256 tokenId) internal pure returns (string memory) {
        string memory att = string(abi.encodePacked('"attributes": [{"trait_type": "Key", "value": "', key(tokenId), '"}, {"trait_type": "Guitar A", "value": "', guitarA(tokenId), '"}, {"trait_type": "Guitar B", "value": "', guitarB(tokenId), '"}, {"trait_type": "Guitar C", "value": "', guitarC(tokenId), '"}, {"trait_type": "Beats", "value": "', beats(tokenId), '"}, {"display_type": "number", "trait_type": "BPM", "value": ', bpm(tokenId), '}]'));
        return att;
    } 

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string memory output = getLoot(tokenId);
        string memory att = attributes(tokenId);
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "BeatLoot #', Utils.toString(tokenId), '", "description": "BeatLoot is randomized beat generated and stored on chain.", "image_data": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '", "animation_url": "', ipfs[tokenId], '", ', att, '}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }
    
    function claim(string memory ipfs_url) public onlyOwner nonReentrant {
        ipfs.push(ipfs_url);
        require(totalSupply() < 3001, "Token ID invalid");
        _safeMint(owner(), totalSupply() + 1);
    }
    
    constructor() ERC721("BeatLoot", "BEAT") Ownable() {
        ipfs.push("");
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

library Utils {
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
}