// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "1127/util/BytesUtil.sol";
import "1127/util/AccessControl.sol";
import "1127/DataStruct.sol";
import "1127/TraceAsset.sol";
contract CompanyLogic is AccessControl,BytesUtil{
    TraceAsset private _trace;
    
    address private admin;

    address private implementationAddress;

    string private company_name;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    bytes32 public constant BE_FIRED_ROLE = keccak256("Fired");

    mapping (string => DataStruct.Worker) private  workerList;
    
    mapping  (string => DataStruct.AssetGroup) private  dataGroupList;

    mapping (uint256 => DataStruct.Asset[]) private traceList;

    event NewWorkerAdd(string did,string company_name);

    event NewWorkerRemoved(string did,string company_name);

    event NewAssetGroupAdd(string groupName,string company_name);

    event NewAssetGroupClose(string groupName,string company_name);


    constructor() AccessControl(msg.sender){
       
    }
   
    /**
    添加员工(到指定组) (admin)
    **/
    function addWorker(string memory worker_did,string memory _groupName,address worker_address) public AccessControl.onlyRole(ADMIN_ROLE) returns (bool)  {
         
        bytes32  groupRole=toRole(_groupName);
        require(dataGroupList[_groupName].isOpen,"No group found");
        require(!hasRole(groupRole,worker_address),"The worker has been added");
        grantRole(groupRole,worker_address);
        workerList[worker_did]=DataStruct.Worker(worker_address,groupRole);
        emit NewWorkerAdd(worker_did,company_name);
        return true;
    }
    
    /**
    删除员工 (admin)
    **/
   function removedWorker(string memory worker_did) public  AccessControl.onlyRole(ADMIN_ROLE) returns (bool) {
        DataStruct.Worker memory _removedWorker = workerList[worker_did];
        // require(dataGroupList[_groupName].isOpen,"No group found");
        require(hasRole(_removedWorker.group,_removedWorker.addr),"The Worker No Found");
        revokeRole(_removedWorker.group, _removedWorker.addr);
        workerList[worker_did] = DataStruct.Worker(
             address(0),BE_FIRED_ROLE
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
        setRoleAdmin(toRole(_groupName), ADMIN_ROLE);
        grantRole(toRole(_groupName), admin);
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
    添加数据 （指定组Worker）
    **/
    function addDataInGroup(string memory _group,string memory _dataCid) public AccessControl.onlyRole(toRole(_group)) returns (bool){

         require(dataGroupList[_group].isOpen,"No group found");
         uint256 size = dataGroupList[_group].assetSize;
         size++;
         DataStruct.Asset memory asset= DataStruct.Asset(_dataCid,block.timestamp,block.timestamp,msg.sender,true);
         dataGroupList[_group].assetSize = size;
         dataGroupList[_group].assets[size] = asset;
         _trace.add(block.timestamp,asset);
         return true;
    }

    /**
    更新数据 （指定组Worker）
    **/
    function updateDataInGroup(string memory _group,uint256 id,string memory _dataCid) public AccessControl.onlyRole(toRole(_group)) returns (bool){

         require(dataGroupList[_group].isOpen,"No group found");
         require(dataGroupList[_group].assets[id].isPublic,"Has been deleted");
         dataGroupList[_group].assets[id].cid = _dataCid;
         dataGroupList[_group].assets[id].updatedAt = block.timestamp;
         dataGroupList[_group].assets[id].operator = msg.sender;
         _trace.add(block.timestamp,dataGroupList[_group].assets[id]);
         return true;
    }

     /**
    删除数据 （指定组Worker）
    **/
    function deleteDataInGroup(string memory _group,uint256 id) public AccessControl.onlyRole(toRole(_group)) returns (bool){
         require(dataGroupList[_group].isOpen,"No group found");
         require(dataGroupList[_group].assets[id].isPublic,"Has been deleted");
         _trace.add(block.timestamp,dataGroupList[_group].assets[id]);
         dataGroupList[_group].assets[id].cid = "";
         dataGroupList[_group].assets[id].updatedAt = 0;
         dataGroupList[_group].assets[id].operator = address(0);
         dataGroupList[_group].assets[id].isPublic = false;
         return true;
    }




     

     
     function getTraceAddr()public view returns(address){
        return address(_trace);
     }
}