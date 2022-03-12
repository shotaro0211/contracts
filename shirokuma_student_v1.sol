//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ShirokumaStudentV1 is ERC721Enumerable, ReentrancyGuard, Ownable {

    uint256 _maxTotal;
    uint256 _money;

    ERC20 private _token;

    struct Shirokuma {
        string name;
        address owner;
        string description;
        uint256 exp;
    }
    Shirokuma[] private _shirokuma;
    
    function getColor(address shirokumaAdress, string memory name) internal pure returns (string memory) {
        uint256 _firstColor = Utils.random(string(abi.encodePacked(shirokumaAdress, name, "Color1"))) % 256;
        uint256 _secondColor = Utils.random(string(abi.encodePacked(shirokumaAdress, name, "Color2"))) % 256;
        uint256 _thirdColor = Utils.random(string(abi.encodePacked(shirokumaAdress, name, "Color3"))) % 256;
        return string(abi.encodePacked('RGB(', Utils.toString(_firstColor), ',', Utils.toString(_secondColor), ',', Utils.toString(_thirdColor), ')'));
    }
    
    function _getShirokumaSvg(Shirokuma memory shirokuma) internal pure returns (string memory) {
        string[12] memory parts;
        string memory bg = getColor(shirokuma.owner, 'background');
        string memory st0 = getColor(shirokuma.owner, 'st0');
        string memory st1 = getColor(shirokuma.owner, 'st1');
        string memory st2 = getColor(shirokuma.owner, 'st2');
        parts[0] = string(abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="500" height="500"><path d="M0 0 L 500 0 L 500 500 L 0 500" fill="', bg, '"/>'));
        parts[1] = string(abi.encodePacked('<text x="380" y="470" fill="white" font-family="cursive" font-size="60">Lv', Utils.getLevel(shirokuma.exp), '</text>'));
        parts[2] = string(abi.encodePacked('<path fill="#FFFFFF" stroke="', st0, '" stroke-width="5" stroke-miterlimit="10" d="M351.43,324.24c-17.52-23.48-38.3-38.27-49.23-35.81H193.45c-10.59-3.78-32.2,11.22-50.32,35.5 c-19.46,26.08-27.51,52.99-17.98,60.1c9.53,7.11,33.03-8.27,52.49-34.35c4.46-5.97,8.31-11.99,11.49-17.8v61.12 c-0.19,3.13-0.29,6.33-0.29,9.61c0,32.54,9.64,58.92,21.53,58.92s21.53-26.38,21.53-58.92c0-0.94-0.01-1.87-0.03-2.8h31.82 c-0.03,1.36-0.06,2.73-0.06,4.11c0,32.54,9.64,58.92,21.53,58.92s21.53-26.38,21.53-58.92c0-6.43-0.38-12.61-1.08-18.4v-52.94 c3.14,5.69,6.92,11.57,11.28,17.41c19.46,26.08,42.96,41.46,52.49,34.35S370.89,350.32,351.43,324.24z"/>'));
        parts[3] = string(abi.encodePacked('<ellipse fill="#FFFFFF" stroke="', st0, '" stroke-width="5" stroke-miterlimit="10" cx="252" cy="196" rx="151.28" ry="124.85"/>'));
        parts[4] = string(abi.encodePacked('<circle fill="', st1, '" cx="304.67" cy="170.16" r="10.24"/><circle fill="', st1, '" cx="190.89" cy="171.73" r="10.24"/><circle fill="', st1, '" cx="247.94" cy="201.35" r="9.83"/>'));
        parts[5] = string(abi.encodePacked('<ellipse fill="#FFFFFF" stroke="', st0, '" stroke-width="5" stroke-miterlimit="10" transform="matrix(0.5663 -0.8242 0.8242 0.5663 95.4376 334.5226)" cx="365.59" cy="76.58" rx="28.37" ry="33.38"/>'));
        parts[6] = string(abi.encodePacked('<ellipse fill="#FFFFFF" stroke="', st0, '" stroke-width="5" stroke-miterlimit="10" transform="matrix(0.8242 -0.5663 0.5663 0.8242 -20.812 91.0492)" cx="136.24" cy="79.04" rx="33.38" ry="28.37"/>'));
        parts[7] = string(abi.encodePacked('<ellipse fill="', st1, '" transform="matrix(0.5663 -0.8242 0.8242 0.5663 84.4733 333.6321)" cx="359.26" cy="86.55" rx="15.2" ry="17.88"/>'));
        parts[8] = string(abi.encodePacked('<ellipse fill="', st1, '" transform="matrix(0.8242 -0.5663 0.5663 0.8242 -25.773 97.3399)" cx="143.89" cy="90.18" rx="17.88" ry="15.2"/>'));
        parts[9] = string(abi.encodePacked('<path fill="none" stroke="', st2, '" stroke-width="5" stroke-miterlimit="10" d="M247.28,210.18c0,7.83-6.3,14.16-14.09,14.16"/>'));
        parts[10] = string(abi.encodePacked('<path fill="none" stroke="', st2, '" stroke-width="5" stroke-miterlimit="10" d="M248.6,210.18c0,7.83,6.3,14.16,14.09,14.16"/>'));
        parts[11] = '</svg>';

        return string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8], parts[9], parts[10]));
    }
    
    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        Shirokuma memory shirokuma = _shirokuma[tokenId];
        
        string memory output = _getShirokumaSvg(shirokuma);
        
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": shirokuma.name, "description": "', shirokuma.description, '", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));

        return output;
    }

    function claim(string memory name, string memory description) public nonReentrant onlyOwner {
        require(_money <= _token.allowance(msg.sender, address(this)) && totalSupply() < _maxTotal);
        _token.transferFrom(msg.sender, address(this), _money);
        _addShirokuma(name, msg.sender, description);
        _safeMint(_msgSender(), totalSupply());
    }

    function _addShirokuma(string memory name, address owner, string memory description) internal {
        _shirokuma.push(
            Shirokuma(
                name,
                owner,
                description,
                0
            )
        );
    }

    function getShirokuma(uint256 tokenId) public view returns (Shirokuma memory) {
        return _shirokuma[tokenId];
    }

    function addExp(uint256 tokenId, uint256 exp) public payable onlyOwner {
        _shirokuma[tokenId].exp += exp;
    }

    function setSupply(uint256 money, uint256 maxTotal) public payable onlyOwner {
        _money = money;
        _maxTotal = maxTotal;
    }

    function getSupply() public view returns (uint256[2] memory)  {
        return [_money, _maxTotal];
    }

    
    constructor(address tokenAddress) ERC721("ShirokumaStudentV1", "SKV1") Ownable() {
        _token = ERC20(tokenAddress);
        _money = 0.01 ether;
        _maxTotal = 10;
    }
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

library Utils {

    function getLevel(uint256 exp) public pure returns (uint256) {
        if(exp < 5) {
            return 1;
        } else if(exp < 15){
            return 2;
        } else if(exp < 30){
            return 3;
        } else if(exp < 50){
            return 4;
        } else {
            return 5;
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
    
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
}