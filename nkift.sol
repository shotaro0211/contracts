//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Nkift is ERC721Enumerable, Ownable, ReentrancyGuard {

    struct NkiftReceiver {
        string name;
        address owner;
        uint256[] senderIds;
    }
    NkiftReceiver[] private _receivers;

    struct NkiftSender {
        string name;
        address owner;
        string[] message;
        uint256 value;
        string date;
        uint256 receiverId;
    }
    NkiftSender[] private _senders;
    
    ERC20 private _token;
    
    function getSvg(uint256 tokenId) public view returns (string memory) {
        string[18] memory parts;

        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="500" height="500">';
        parts[1] = '<path d="M0 0 L 500 0 L 500 500 L 0 500" fill="#5bc43e"/>';
        parts[2] = '<text x="20" y="70" fill="white" font-family="cursive" font-size="60">NkiFT</text>';
        parts[3] = string(abi.encodePacked('<text x="480" y="70" fill="white" font-family="cursive" font-size="25" text-anchor="end">', _senders[tokenId].date, '</text>'));
        parts[4] = string(abi.encodePacked('<text x="40" y="140" fill="white" font-family="cursive" font-size="20">Dear ', _receivers[_senders[tokenId].receiverId].name, '</text>'));
        for(uint256 i = 0; i < _senders[tokenId].message.length; i++) {
            uint256 y = 190 + 30 * i;
            parts[5 + i] = string(abi.encodePacked('<text x="70" y="', Convert.toString(y), '" fill="white" font-family="cursive" font-size="20">', _senders[tokenId].message[i], '</text>'));
        }
        parts[11] = string(abi.encodePacked('<text x="460" y="400" fill="white" font-family="cursive" font-size="20" text-anchor="end">', _senders[tokenId].name, '</text>'));
        parts[12] = string(abi.encodePacked('<text x="480" y="485" fill="white" font-family="cursive" font-size="35" text-anchor="end">', Convert.toStringEth(_senders[tokenId].value), ' ETH</text>'));
        parts[13] = '</svg>';

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6]));
        output = string(abi.encodePacked(output, parts[7], parts[8], parts[9], parts[10], parts[11], parts[12], parts[13]));
        return output;
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        string memory output = getSvg(tokenId);
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "NkiFT #', Convert.toString(tokenId), '", "description": "", "image_data": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }

    function kif(uint256 receiverId, string memory name, string[] memory message, uint256 value) public payable nonReentrant {
        require(value <= _token.allowance(msg.sender, address(this)) && value >= 0.001 ether);
        _token.transferFrom(msg.sender, address(this), value);
        _token.transfer(_receivers[receiverId].owner, value);
        _addNkiftSender(name, msg.sender, message, value, receiverId);
        _receivers[receiverId].senderIds.push(totalSupply());
        _safeMint(_msgSender(), totalSupply()); 
    }

    function getNkiftReceiver(uint256 tokenId) public view returns (NkiftReceiver memory) {
        return _receivers[tokenId];
    }

    function addNkiftReceiver(string memory name, address owner) public payable onlyOwner {
        _receivers.push(
            NkiftReceiver(
                name,
                owner,
                new uint256[](0)
            )
        );
    }

    function getNkiftSender(uint256 tokenId) public view returns (NkiftSender memory) {
        return _senders[tokenId];
    }

    function _addNkiftSender(string memory name, address owner, string[] memory message, uint256 value, uint256 receiverId) internal {
        _senders.push(
            NkiftSender(
                name,
                owner,
                message,
                value,
                DateTime.getDate(block.timestamp),
                receiverId
            )
        );
    }

    constructor(address tokenAddress) ERC721("NkiFT", "KIF") Ownable() {
        _token = ERC20(tokenAddress);
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

library DateTime {
    /*
    *  Date and Time utilities for ethereum contracts
    *
    */
    struct _DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
        uint8 second;
        uint8 weekday;
    }

    uint constant DAY_IN_SECONDS = 86400;
    uint constant YEAR_IN_SECONDS = 31536000;
    uint constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint constant HOUR_IN_SECONDS = 3600;
    uint constant MINUTE_IN_SECONDS = 60;

    uint16 constant ORIGIN_YEAR = 1970;

    function isLeapYear(uint16 year) public pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function leapYearsBefore(uint year) public pure returns (uint) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            return 31;
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        } else if (isLeapYear(year)) {
            return 29;
        } else {
            return 28;
        }
    }

    function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {
        uint secondsAccountedFor = 0;
        uint buf;
        uint8 i;

        // Year
        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

        // Month
        uint secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                dt.month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }

        // Day
        for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                dt.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }

        // Hour
        dt.hour = getHour(timestamp);

        // Minute
        dt.minute = getMinute(timestamp);

        // Second
        dt.second = getSecond(timestamp);

        // Day of week.
        dt.weekday = getWeekday(timestamp);
    }

    function getYear(uint timestamp) public pure returns (uint16) {
        uint secondsAccountedFor = 0;
        uint16 year;
        uint numLeapYears;

        // Year
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            } else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function getHour(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60) % 60);
    }

    function getSecond(uint timestamp) public pure returns (uint8) {
        return uint8(timestamp % 60);
    }

    function getWeekday(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

    function getMonth(uint number) public pure returns (string memory) {
        if (number == 1) {
            return 'January';
        } else if (number == 2) {
            return 'February';
        } else if (number == 3) {
            return 'March';
        } else if (number == 4) {
            return 'April';
        } else if (number == 5) {
            return 'May';
        } else if (number == 6) {
            return 'June';
        } else if (number == 7) {
            return 'July';
        } else if (number == 8) {
            return 'August';
        } else if (number == 9) {
            return 'September';
        } else if (number == 10) {
            return 'October';
        } else if (number == 11) {
            return 'November';
        } else if (number == 12) {
            return 'December';
        } else {
            return '';
        }
    }

    function getDate(uint timestamp) public pure returns (string memory) {
        _DateTime memory dt = parseTimestamp(timestamp);
        return string(abi.encodePacked(getMonth(dt.month), ' ', Convert.toString(dt.day), ', ', Convert.toString(dt.year)));
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