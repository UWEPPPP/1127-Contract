// SPDX-License-Identifier: MIT
pragma solidity  0.8.11;
library DataStruct{
    
    struct Company{
        string did;
        address addr;
        string name;
    }

    struct DataAsset{
        string cid;
        bool isPublic;
    }
    
    struct Worker{
        string did;
        address addr;
    }

}