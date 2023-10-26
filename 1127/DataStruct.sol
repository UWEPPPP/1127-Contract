// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

library DataStruct {
    struct Company {
        string did;
        address addr;
        string name;
    }

    struct AssetGroup {
        mapping(uint256 => AssetMetadata) assets;
        uint256 assetSize;
        bool isOpen;
    }

    struct AssetMetadata {
        string cid;
        uint256 createdAt;
        address creator;
        bool isPublic;
    }

    struct AssetTrace{
        AssetMetadata asset;
        uint256 operateTime;
        string operateMsg;
    }

    struct Worker {
        address addr;
        bytes32 group;
    }

   
     

}
