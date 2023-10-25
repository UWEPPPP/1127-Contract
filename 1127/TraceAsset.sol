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
    mapping (uint256 => DataStruct.Asset[]) private traceList;

    function setTraceRight(address getter) public AccessControl.onlyRole(ADMIN){
       grantRole(TRACER,getter);
    }
    
    function add(uint256 timeStamp,DataStruct.Asset memory trace) public AccessControl.onlyRole(TRACER) {
        traceList[timeStamp].push(trace);
    }

    function get(uint256 timeStamp) public view AccessControl.onlyRole(TRACER) returns(DataStruct.Asset[] memory){
        return traceList[timeStamp];
    }

    function getLastOperateTime(uint256 timeStamp) public view AccessControl.onlyRole(TRACER) returns(uint256){
        DataStruct.Asset[] memory array = traceList[timeStamp];
        return array[array.length-1].updatedAt;
    }
}