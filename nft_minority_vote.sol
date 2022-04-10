//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MinorityVote is ERC721Enumerable, ReentrancyGuard, Ownable {
    struct Vote {
        uint256 tokenId;
        bool answer;
        uint256 questionId;
    }
    Vote[] private _votes;

    struct Question {
        string title;
    }
    Question[] private _questions;

    uint256 private _stage;
    uint256 private _mintId = 1;

    function createQuestion(string memory title) public nonReentrant onlyOwner {
        _questions.push(Question(title));
    }

    function createVotes(Vote[] memory votes) public nonReentrant onlyOwner {
        for(uint256 i = 0; i < votes.length; i++) { 
            ownerOf(votes[i].tokenId);
            _questions[votes[i].questionId];
            _votes.push(votes[i]);
        }
    }

    function execution() public nonReentrant onlyOwner {
        uint256 yes = 0;
        uint256 no = 0;
        uint256 questionId = _stage - 1;
        bool win;

        for(uint256 i = 0; i < _votes.length; i++) {
            if (_votes[i].questionId == questionId) {
                if (_votes[i].answer == true) {
                    yes += 1;
                } else {
                    no += 1;
                }
            }
        }
        if (yes != no) {
            if (yes < no) {
                win = true;
            } else if (no < yes) {
                win = false;
            }
            for(uint256 i = 0; i < _votes.length; i++) {
                if (_votes[i].questionId == questionId && _votes[i].answer != win) {
                    _burn(_votes[i].tokenId); 
                }
            }
        }
        _stage += 1;
    }

    function getQuestions() public view returns (Question[] memory) {
        return _questions;
    }

    function getStage() public view returns (uint256) {
        return _stage;
    }

    function getVotes() public view returns (Vote[] memory) {
        return _votes;
    }

    function mint() public nonReentrant {
        require(_mintId < 23, "Token ID invalid");
        require(balanceOf(msg.sender) == 0, "Already mint invalid");
        require(_stage == 1, "Already start invalid");
        _safeMint(msg.sender, _mintId);
        _mintId += 1;
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "NFT Minority Vote #', toString(tokenId), '", "description": "", "image": "https://dentou-s3.s3.ap-northeast-1.amazonaws.com/NFT/nft_minority_vote/IMG_1249.png"}'))));
        string memory output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
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

    constructor() ERC721("NFT Minority Vote", "NMV") Ownable() {
        _stage = 1;
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