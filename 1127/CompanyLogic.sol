// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "1127/util/AccessControl.sol";
import "1127/DataStruct.sol";
contract CompanyLogic is AccessControl{

    address private implementationAddress;

    string private company_name;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    bytes32 public constant WORKER_ROLE = keccak256("WORKER");

    mapping (string => DataStruct.Worker) private  workerList;
    
    mapping  (string => DataStruct.AssetGroup) private  dataGroupList;

    event NewWorkerAdd(string did,string company_name);

    event NewWorkerRemoved(string did,string company_name);

    event NewAssetGroupAdd(string groupName,string company_name);

    event NewAssetGroupClose(string groupName,string company_name);


    constructor() AccessControl(msg.sender){
       
    }
   
    /**
    增加员工 (admin)
    **/
    function addWorker(string memory worker_did,address worker_address) public AccessControl.onlyRole(ADMIN_ROLE) returns (bool)  {
        if(hasRole(WORKER_ROLE,worker_address)){
            return false;
        }
        require(!hasRole(WORKER_ROLE,worker_address),"The worker has been added");
        grantRole(WORKER_ROLE,worker_address);
        workerList[worker_did] = DataStruct.Worker(
             worker_did,worker_address
        );
        emit NewWorkerAdd(worker_did,company_name);
        return true;
    }
    
    /**
    删除员工 (admin)
    **/
   function removedWorker(string memory worker_did) public  AccessControl.onlyRole(ADMIN_ROLE) returns (bool) {
        DataStruct.Worker memory _removedWorker = workerList[worker_did];
        require(hasRole(WORKER_ROLE,_removedWorker.addr),"The Worker has been deleted");
        revokeRole(WORKER_ROLE, _removedWorker.addr);
        workerList[worker_did] = DataStruct.Worker(
             "",address(0)
        );
        emit NewWorkerRemoved(worker_did,company_name);
        return true;
    }
    
    /**
    增加数据组 (admin)
    **/
    function addDataGroup(string memory _groupName) public AccessControl.onlyRole(ADMIN_ROLE) returns (bool) {
        require(!dataGroupList[_groupName].isOpen,"The group has exist");
        dataGroupList[_groupName].isOpen=true;
        emit NewAssetGroupAdd(_groupName, company_name);
        return true;
    }
    
    /**
    关闭数据组 (admin)
    **/
    function closeDataGroup(string memory _groupName) public AccessControl.onlyRole(ADMIN_ROLE) returns (bool){
        require(!dataGroupList[_groupName].isOpen,"The group has been close");
        dataGroupList[_groupName].isOpen=false;
        emit NewAssetGroupClose(_groupName, company_name);
        return true;
    }

    /**
    添加数据 （Worker）

    假设有一个数据库专门来存资产的索引 公司did+group+id
    **/
    function addDataInGroup(string memory _group,string memory _dataCid) public AccessControl.onlyRole(WORKER_ROLE) returns (bool){
         require(dataGroupList[_group].isOpen,"No group found");
         uint256 size = dataGroupList[_group].assetSize;
         size++;
         dataGroupList[_group].assetSize = size;
         dataGroupList[_group].assets[size] = DataStruct.Asset(_dataCid,block.timestamp,block.timestamp,address(0));
         return true;
    }

        /**
    更新数据 （Worker）

    假设有一个数据库专门来存资产的索引 公司did+group+id
    **/
    function updateDataInGroup(string memory _group,uint256 id,string memory _dataCid) public AccessControl.onlyRole(WORKER_ROLE) returns (bool){
         require(dataGroupList[_group].isOpen,"No group found");
         dataGroupList[_group].assets[id] = DataStruct.Asset(_dataCid);
         return true;
    }


}