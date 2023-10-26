// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import  "1127/util/CommonUtil.sol";
import "1127/util/AccessControl.sol";
import "1127/DataStruct.sol";
import "1127/TraceAsset.sol";

contract CompanyLogic is AccessControl,CommonUtil {
    TraceAsset private _trace;

    address private admin;
    address private implementationAddress;
    string private company_name;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 public constant BE_FIRED_ROLE = keccak256("Fired");

    mapping (address => DataStruct.Worker) private workerList;
    mapping (string => DataStruct.AssetGroup) private dataGroupList;
    mapping (uint256 => DataStruct.AssetTrace[]) private traceList;

    event NewWorkerAdd(address worker_address, string company_name);
    event NewWorkerRemoved(address worker_address, string company_name);
    event NewAssetGroupOpen(string groupName, string company_name);
    event NewAssetGroupClose(string groupName, string company_name);

    constructor() AccessControl(msg.sender) {}

    /**
    添加员工(到指定组) (admin)
    **/
    function addWorker(string memory _groupName, address worker_address) public AccessControl.onlyRole(ADMIN_ROLE) returns (bool)  {
        
        bytes32 groupRole = toRole(_groupName);
        require(dataGroupList[_groupName].isOpen, error("CompanyLogic", "addWorker", "No group found"));
        require(!hasRole(groupRole, worker_address), error("CompanyLogic", "addWorker", "worker has been added"));
        grantRole(groupRole, worker_address);
        workerList[worker_address] = DataStruct.Worker(worker_address, groupRole);
        emit NewWorkerAdd(worker_address, company_name);
        return true;
    }

    /**
    删除员工 (admin)
    **/
    function removedWorker(address worker_address) public AccessControl.onlyRole(ADMIN_ROLE) returns (bool) {
        
        DataStruct.Worker memory _removedWorker = workerList[worker_address];
        require(hasRole(_removedWorker.group, _removedWorker.addr), error("CompanyLogic", "removedWorker", "The Worker No Found"));
        revokeRole(_removedWorker.group, _removedWorker.addr);
        workerList[worker_address] = DataStruct.Worker(
             address(0), BE_FIRED_ROLE
        );
        emit NewWorkerRemoved(worker_address, company_name);
        return true;
    }

    /**
    启用数据组 (admin)
    **/
    function addDataGroup(string memory _groupName) public AccessControl.onlyRole(ADMIN_ROLE) returns (bool) {
        
        require(!dataGroupList[_groupName].isOpen, error("CompanyLogic", "addworker", "The group has exist"));
        dataGroupList[_groupName].isOpen = true;
        setRoleAdmin(toRole(_groupName), ADMIN_ROLE);
        grantRole(toRole(_groupName), admin);
        emit NewAssetGroupOpen(_groupName, company_name);
        return true;
    }

    /**
    关闭数据组 (admin)
    **/
    function closeDataGroup(string memory _groupName) public AccessControl.onlyRole(ADMIN_ROLE) returns (bool) {
        
        require(!dataGroupList[_groupName].isOpen, error("CompanyLogic", "closeDataGroup", "The group has been close"));
        dataGroupList[_groupName].isOpen = false;
        emit NewAssetGroupClose(_groupName, company_name);
        return true;
    }

    /**
    添加数据 （指定组Worker）
    **/
    function addDataInGroup(string memory _group, string memory _dataCid) public AccessControl.onlyRole(toRole(_group)) returns (bool) {
         
         require(dataGroupList[_group].isOpen, error("CompanyLogic", "addworker", "No group found"));
         uint256 size = dataGroupList[_group].assetSize;
         size++;
         DataStruct.AssetMetadata memory asset = DataStruct.AssetMetadata(_dataCid, block.timestamp, msg.sender, true);
         dataGroupList[_group].assetSize = size;
         dataGroupList[_group].assets[size] = asset;
         // strConcat(_group,toString(size)) 拼凑字符串
         _trace.add(toAssetIndex(_group, size),DataStruct.AssetTrace(asset,block.timestamp,msg.sender,"Create"));
         return true;
    }

    /**
    获取单个AssetData
    **/
    function getSingleDataInGroup(string memory _group, uint256 id ) public  AccessControl.onlyRole(toRole(_group)) returns (DataStruct.AssetMetadata memory) {
          
          require(dataGroupList[_group].isOpen, error("CompanyLogic", "getSingleDataInGroup", "Group isn't exist"));
          require(dataGroupList[_group].assets[id].isPublic, error("CompanyLogic", "getSingleDataInGroup", "Asset have closed"));
          DataStruct.AssetMetadata memory asset =dataGroupList[_group].assets[id];
          _trace.add(toAssetIndex(_group, id),DataStruct.AssetTrace(asset,block.timestamp,msg.sender,"BeGet"));
          return  dataGroupList[_group].assets[id];
    }

    /**
    更新数据 （指定组Worker）
    **/
    function updateDataInGroup(string memory _group, uint256 id, string memory _dataCid) public AccessControl.onlyRole(toRole(_group)) returns (bool) {
         
         require(dataGroupList[_group].isOpen, error("CompanyLogic", "updateDataInGroup", "No group found"));
         require(dataGroupList[_group].assets[id].isPublic, error("CompanyLogic", "updateDataInGroup", "Has been deleted"));
         dataGroupList[_group].assets[id].cid = _dataCid;
         DataStruct.AssetMetadata memory asset =dataGroupList[_group].assets[id];
          _trace.add(toAssetIndex(_group, id),DataStruct.AssetTrace(asset,block.timestamp,msg.sender,"Update"));
         return true;
    }

    /**
    删除数据 （指定组Worker）
    **/
    function deleteDataInGroup(string memory _group, uint256 id) public AccessControl.onlyRole(toRole(_group)) returns (bool) {
         
         require(dataGroupList[_group].isOpen, error("CompanyLogic", "deleteDataInGroup", "No group found"));
         require(dataGroupList[_group].assets[id].isPublic, error("CompanyLogic", "deleteDataInGroup", "Has been deleted"));
         dataGroupList[_group].assets[id].cid = "";
         dataGroupList[_group].assets[id].creator = address(0);
         dataGroupList[_group].assets[id].isPublic = false;
         DataStruct.AssetMetadata memory asset =dataGroupList[_group].assets[id];
          _trace.add(toAssetIndex(_group, id),DataStruct.AssetTrace(asset,block.timestamp,msg.sender,"Delete"));
         return true;
    }

    function getTraceAddr() public view returns(address) {
        return address(_trace);
     }
}
