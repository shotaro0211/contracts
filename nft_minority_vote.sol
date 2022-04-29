//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LiarVerseAlpha is ERC721Enumerable, ReentrancyGuard, Ownable {
    enum Answer {
        No,
        Yes,
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
    uint256 private _currentGameSurvivorNftCount;
    uint256 private _currentStage;
    uint8 private _drawCount;

    uint256 private _nextMintId;
    uint256 private _mintValue;
    bool private _mintLock;
    
    string[] private _imageUrlList;
    string[] private _gameTitleList;


    function _createQuestion(string memory title) internal {
        _questions.push(Question(title, _currentStage, _currentGame));
        _currentQuestionIndex += 1;
    }

    function _createVotes(Answer[] memory answers) internal {
        require(answers.length == getCurrentGameNftCount(), toString(answers.length));
        for(uint256 i = 0; i < answers.length; i++) { 
            _votes.push(Vote(_currentGameStartMintId + i, answers[i], _currentQuestionIndex));
        }
    }

    function nextQuestion(string memory title, Answer[] memory answers) public nonReentrant onlyOwner {
        Answer lose;
        uint256 totalYes = 0;
        uint256 totalNo = 0;
        uint256 nextVoteIndex = _votes.length;

        _createVotes(answers);

        if (getCurrentQuestion().stage == 1) {
            _currentGameSurvivorNftCount = answers.length;
        }

        for(uint256 i = nextVoteIndex; i < nextVoteIndex + answers.length; i++) {
            if (_votes[i].answer == Answer.Yes) {
                totalYes += 1;
            } else if (_votes[i].answer == Answer.No) {
                totalNo += 1;
            } else if (_votes[i].answer == Answer.Null) {
                if (_currentGameSurvivorNftCount > 2) {
                    _nfts[_votes[i].tokenId - 1].burn = true;
                } 
            }
        }

        uint256 total = totalYes + totalNo;

        if (totalYes != totalNo) {
            lose = (totalYes < totalNo) ? Answer.No : Answer.Yes;
            for (uint256 i = nextVoteIndex; i < nextVoteIndex + answers.length; i++) {
                if (_votes[i].answer == lose) {
                    _nfts[_votes[i].tokenId - 1].burn = true; 
                }
            }
            _drawCount = 0;
        } else if (total < 3 && totalYes == 0 && totalNo == 0) {
            for (uint256 i = nextVoteIndex; i < nextVoteIndex + answers.length; i++) {
                _nfts[_votes[i].tokenId - 1].burn = true;
            }
        } else {
            _drawCount += 1;
        }

        if ((total < 3 && (totalYes == 0 || totalNo == 0)) || (total > 2 && (totalYes < 2 || totalNo < 2)) || _drawCount == 3) {
            for (uint256 i = nextVoteIndex; i < nextVoteIndex + answers.length; i++) {
                if (_nfts[_votes[i].tokenId - 1].burn == false) {
                    _nfts[_votes[i].tokenId - 1].winner = true;
                }
            }
            _drawCount = 0;
            _currentGame += 1;
            _currentGameStartMintId = _nextMintId;
            _currentStage = 1;
        } else {
            _currentStage += 1;
            for (uint256 i = nextVoteIndex; i < nextVoteIndex + answers.length; i++) {
                if (_nfts[_votes[i].tokenId - 1].burn == false) {
                    _nfts[_votes[i].tokenId - 1].stage = _currentStage;
                }
            }
            
        }
        if (totalYes == totalNo) {
            _currentGameSurvivorNftCount = total;
        } else {
            _currentGameSurvivorNftCount = (totalYes < totalNo) ? totalYes : totalNo;
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

    function getCurrentGameNftCount() public view returns (uint256) {
        return _nextMintId - _currentGameStartMintId;
    }

    function getCurrentGameNftId(address owner) public view returns (uint256) {
        for(uint256 i = _currentGameStartMintId; i < _nextMintId; i++) {
            if (ownerOf(i) == owner) {
                return i;
            }
        }
        return 0;
    }

    function getCurrentGameStartMintId() public view returns (uint256) {
        return _currentGameStartMintId;
    }

    function getCurrentGameSurvivorNftCount() public view returns (uint256) {
        return _currentStage == 1 ? _nextMintId - _currentGameStartMintId : _currentGameSurvivorNftCount;
    }

    function getDrawCount() public view returns (uint256) {
        return _drawCount;
    }

    function getVote(uint256 index) public view returns (Vote memory) {
        return _votes[index];
    }

    function getMintValue() public view returns (uint256 value) {
        return _mintValue;
    }

    function setMintValue(uint256 value) public onlyOwner {
        _mintValue = value;
    }

    function getMintLock() public view returns (bool lock) {
        return _mintLock;
    }

    function setMintLock(bool mintLock) public onlyOwner {
        _mintLock = mintLock;
    }

    function mint() public nonReentrant payable {
        require(msg.value == _mintValue, "value invalid");
        _claim(msg.sender);
    }

    function ownerMints(address[] memory takers) public onlyOwner {
        for(uint256 i = 0; i < takers.length; i++) {
            _claim(takers[i]);
        }
    }

    function _claim(address taker) internal {
        require(_mintLock == false, "Already locked invalid");
        require(_currentStage == 1, "Already start invalid");
        _nfts.push(Nft(1, _currentGame, false, false));
        _safeMint(taker, _nextMintId);
        _nextMintId += 1;
    }

    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function getNftImageUrl(uint256 tokenId) public view returns (string memory) {
        Nft memory nft = getNft(tokenId);
        string memory imageName = _getImageName(nft);
        string memory url = string(abi.encodePacked(_imageUrlList[nft.game], imageName, '.png'));
        return url;
    }

    function createGame(string memory title, string memory url) public onlyOwner {
        _gameTitleList.push(title);
        _imageUrlList.push(url);
    }

    function getGameTitle(uint256 game) public view returns (string memory) {
        return _gameTitleList[game];
    }

    function _attributes(string memory title, bool winner, bool burn) internal pure returns (string memory) {
        string memory att = string(abi.encodePacked('"attributes": [{"trait_type": "Game Title", "value": "', title, '"}, {"trait_type": "Winner", "value": "', winner ? 'true' : 'false', '"}, {"trait_type": "Burn", "value": "', burn ? 'true' : 'false', '"}]'));
        return att;
    } 

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        Nft memory nft = getNft(tokenId);
        string memory gameTitle = _gameTitleList[nft.game];
        string memory att = _attributes(gameTitle, nft.winner, nft.burn);
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "LiarVerse Alpha #', toString(tokenId), '", "description": "", "image": "', getNftImageUrl(tokenId), '", ', att, '}'))));
        string memory output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }

    function _getImageName(Nft memory nft) internal pure returns (string memory) {
        if (nft.burn == true) {
            return string(abi.encodePacked("burn", toString(nft.game), toString(nft.stage)));
        } else if (nft.winner == true) {
            return string(abi.encodePacked("winner", toString(nft.game)));
        } else {
            return string(abi.encodePacked(toString(nft.game), toString(nft.stage)));
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

    constructor(string memory title, string memory gameTitle, string memory imageUrl) ERC721("LiarVerse Alpha", "LIAR") Ownable() {
        _currentGame = 1;
        _currentGameStartMintId = 1;
        _currentStage = 1;
        _drawCount = 0;
        _questions.push(Question(title, 1, 1));

        _mintValue = 0 ether;
        _nextMintId = 1;
        _mintLock = false;

        _imageUrlList.push("");
        _gameTitleList.push("");
        _imageUrlList.push(imageUrl);
        _gameTitleList.push(gameTitle);
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