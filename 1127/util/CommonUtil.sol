// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import {Math} from "1127/util/Math.sol";
import {SignedMath} from "1127/util/SignedMath.sol";
contract CommonUtil  {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    
    /**
    业务工具区
    **/

    //生成规则bytes32
    function toRole(string memory str) public pure returns (bytes32) {
        return stringToBytes32(str);
    }
    
    //生成资产下标 格式为 Group名字:自增id
    function toAssetIndex(string memory _group,uint256 id) public pure returns (string memory){
        
        return strConcat(strConcat(_group, ":"),toString(id));
    }

    
    function error(
        string memory _contract,
        string memory _function,
        string memory _msg
    ) public pure returns (string memory) {
       return strConcat(
        strConcat(
        strConcat("Contract: ", _contract),
        strConcat(",Function: ", _function)
        ),
        strConcat(",Message: ", _msg)
        );
    }


    /**
    通用工具区
    **/
    function stringToBytes32(string memory str) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(str));
    }


    function strConcat(string memory _a, string memory _b)
        public
        pure
        returns (string memory)
    {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint256 k = 0;
        for (uint256 i = 0; i < _ba.length; i++) bret[k++] = _ba[i];
        for (uint256 i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
        return string(ret);
    }


     function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    
}
