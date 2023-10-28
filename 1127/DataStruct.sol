// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

library DataStruct {
    struct Company {
        string did;
        address addr;
        string name;
    }

    struct AssetMetadata {
        // ipfs标识
        string encodeCid;
        // 数据名称
        string name;
        // 创建时间
        uint256 createdAt;
        // 创建者地址
        address creator;
        // 数据分组id
        uint256 groupId;
        // 追溯记录数量
        uint256 traceCount;
        // 数据有效性
        bool isValid;
    }

    struct AssetTrace{
        // 操作时间戳
        uint256 operateTime;
        // 操作人地址
        address operator;
        // 操作信息
        string operateMsg;
    }

    struct Worker {
        address addr;
        bytes32 group;
    }
}
