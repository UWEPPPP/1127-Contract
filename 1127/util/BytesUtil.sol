// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract BytesUtil{


    function toRole(string memory str) public pure returns (bytes32){
        return stringToBytes32(str);
    }

    function stringToBytes32(string memory str) public pure returns (bytes32)  {
        return keccak256(abi.encodePacked(str));
    }
}