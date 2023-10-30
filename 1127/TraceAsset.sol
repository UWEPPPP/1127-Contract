// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "./DataStruct.sol";
import "./AccessControl.sol";

contract TraceAsset is AccessControl{
    bytes32 public constant ADMIN = 0x00;
    bytes32 public constant TRACER = keccak256("Tracer");

    constructor() AccessControl(msg.sender){
        setRoleAdmin(TRACER, ADMIN);
        grantRole(TRACER, msg.sender);
    }

    // 资产id => assetTrace[] 
    mapping (uint256 => DataStruct.AssetTrace[]) private traceList;
    // 添加追溯记录时的事件
    event LogAddTrace(uint256 indexed assetId,address indexed operator,string message,uint operateTime);


    function setTraceRight(address getter) public AccessControl.onlyRole(ADMIN){
       grantRole(TRACER,getter);
    }
    
    /**
     * 添加记录
     */
    function add(uint256 id,DataStruct.AssetTrace memory trace) public AccessControl.onlyRole(TRACER) {
        traceList[id].push(trace);
        emit LogAddTrace(id,trace.operator,trace.operateMsg,trace.operateTime);
    }

    /**
     * 获取单个资产的所有记录
     */
    function getAll(uint256 id) public view AccessControl.onlyRole(TRACER) returns(DataStruct.AssetTrace[] memory){
        uint256 length = traceList[id].length;
        require(length > 0,"TraceAsset::GetAllError:: id is not valid");
        return traceList[id];
    }

    /**
     * 获取单个资产的最新记录
     */
    function getLast(uint256 id) public view AccessControl.onlyRole(TRACER) returns(DataStruct.AssetTrace memory){
        uint256 length = traceList[id].length;
        require(length > 0,"TraceAsset::GetLastError:: id is not valid");
        return traceList[id][length - 1];
    }

    /**
     * 获取单个资产的某个时间节点上的记录
     * [待优化]
     */
    function getByTimestamp(uint256 id,uint256 timestamp) public view AccessControl.onlyRole(TRACER) returns(DataStruct.AssetTrace memory){
        uint256 length = traceList[id].length - 1;
        require(length >= 0,"TraceAsset::GetByTimestampError:: id is not valid");
        // 二分查找
        DataStruct.AssetTrace[] memory assetTraceList = traceList[id];
        uint256 low = 0;
        uint256 mid;
        while(low <= length){
            mid = low + (length - low) / 2;
            if(assetTraceList[mid].operateTime == timestamp){
                return assetTraceList[mid];
            }
            if(assetTraceList[mid].operateTime < timestamp){
                low = mid + 1;
            } else {
                length = mid - 1;
            }
        }
        revert("TraceAsset::GetByTimestampError:: can not find corresponding trace data");
    }
}