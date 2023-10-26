// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "1127/DataStruct.sol";
import "1127/util/AccessControl.sol";
contract TraceAsset is AccessControl{

    bytes32 public constant ADMIN = 0x00;
    bytes32 public constant TRACER = keccak256("Tracer");

    constructor() AccessControl(msg.sender){
      setRoleAdmin(TRACER, ADMIN);
      grantRole(TRACER, msg.sender);

    }
    // 字符串格式为 Group名字+自增id
    mapping (string => DataStruct.AssetTrace[]) private traceList;

    function setTraceRight(address getter) public AccessControl.onlyRole(ADMIN){
       grantRole(TRACER,getter);
    }
    
    function add(string memory hash,DataStruct.AssetTrace memory trace) public AccessControl.onlyRole(TRACER) {
        traceList[hash].push(trace);
    }

    function get(string memory hash) public view AccessControl.onlyRole(TRACER) returns(DataStruct.AssetTrace[] memory){
        return traceList[hash];
    }

    function getLastOperateTime(string memory hash) public view AccessControl.onlyRole(TRACER) returns(uint256){
        DataStruct.AssetTrace[] memory array = traceList[hash];
        return array[array.length-1].operateTime;
    }
}