// SPDX-License-Identifier: MIT
pragma solidity  0.8.11;
library DataStruct{
    
    struct Company{
        string did;
        address addr;
        string name;
    }

    struct AssetGroup{
        mapping (uint256 => Asset) assets;
        uint256 assetSize;
        bool isOpen;
    }
    struct Asset {
        string cid;
        // bool isPublic;
    }
    
    struct Worker{
        string did;
        address addr;
    }

}