//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MinorityVote is ERC721Enumerable, ReentrancyGuard, Ownable {
    enum Answer {
        Yes,
        No,
        Null
    }

    struct Nft {
        uint256 stage;
        uint256 game;
        bool burn;
        bool winner;
    }
    Nft[] private _nfts;

    struct Vote {
        uint256 tokenId;
        Answer answer;
        uint256 questionIndex;
    }
    Vote[] private _votes;

    struct Question {
        string title;
        uint256 stage;
        uint256 game;
    }
    Question[] private _questions;

    uint256 private _currentQuestionIndex;
    uint256 private _currentGame;
    uint256 private _currentGameStartMintId;
    uint256 private _currentStage;
    uint256 private _nextMintId;

    function _createQuestion(string memory title) internal {
        _questions.push(Question(title, _currentStage, _currentGame));
        _currentQuestionIndex += 1;
    }

    function _createVotes(Answer[] memory answers) internal {
        require(answers.length == _nextMintId - _currentGameStartMintId, "length invalid");
        for(uint256 i = 0; i < answers.length; i++) { 
            _votes.push(Vote(_currentGameStartMintId + i, answers[i], _currentQuestionIndex));
        }
    }

    function nextQuestion(string memory title, Answer[] memory answers) public nonReentrant onlyOwner {
        uint256 totalYes = 0;
        uint256 totalNo = 0;
        Answer win;

        _createVotes(answers);

        for(uint256 i = 0; i < _votes.length; i++) {
            if (_votes[i].questionIndex == _currentQuestionIndex) {
                if (_votes[i].answer == Answer.Yes) {
                    totalYes += 1;
                } else if (_votes[i].answer == Answer.No) {
                    totalNo += 1;
                } else if (_votes[i].answer == Answer.Null) {
                    _nfts[_votes[i].tokenId - 1].burn = true; 
                }
            }
        }
        if (totalYes != totalNo) {
            if (totalYes < totalNo) {
                win = Answer.Yes;
            } else if (totalNo < totalYes) {
                win = Answer.No;
            }
            for(uint256 i = 0; i < _votes.length; i++) {
                if (_votes[i].questionIndex == _currentQuestionIndex && _votes[i].answer != win) {
                    _nfts[_votes[i].tokenId - 1].burn = true; 
                }
            }
        }
        if (totalYes < 2 || totalNo < 2) {
            for(uint256 i = 0; i < _votes.length; i++) {
                if(_nfts[_votes[i].tokenId - 1].burn == false) {
                    _nfts[_votes[i].tokenId - 1].winner = true;
                }
            }
            _currentGame += 1;
            _currentGameStartMintId = _nextMintId;
            _currentStage = 1;
        } else {
            _currentStage += 1;
        }
        _createQuestion(title);
    }

    function getQuestion(uint256 index) public view returns (Question memory) {
        return _questions[index];
    }

    function getNft(uint256 tokenId) public view returns (Nft memory) {
        uint256 index = tokenId -1;
        return _nfts[index];
    }

    function getCurrentQuestion() public view returns (Question memory) {
        return _questions[_currentQuestionIndex];
    }

    function getVote(uint256 index) public view returns (Vote memory) {
        return _votes[index];
    }

    function mint() public nonReentrant onlyOwner {
        require(_currentStage == 1, "Already start invalid");
        _nfts.push(Nft(1, _currentGame, false, false));
        _safeMint(msg.sender, _nextMintId);
        _nextMintId += 1;
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        Nft memory nft = getNft(tokenId);
        string memory imageName = _getImageName(nft);
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "NFT Minority Vote #', toString(tokenId), '", "description": "", "image": "https://dentou-s3.s3.ap-northeast-1.amazonaws.com/NFT/nft_minority_vote/', imageName, '.png"}'))));
        string memory output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }

    function _getImageName(Nft memory nft) internal pure returns (string memory) {
        if (nft.burn == true) {
            return "burn";
        } else if (nft.winner == true) {
            return "winner";
        } else {
            return toString(nft.stage);
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

    constructor(string memory title) ERC721("NFT Minority Vote", "NMV") Ownable() {
        _currentGame = 1;
        _currentGameStartMintId = 1;
        _currentStage = 1;
        _questions.push(Question(title, 1, 1));

        _nextMintId = 1;   
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