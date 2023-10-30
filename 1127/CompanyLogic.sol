// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import  "./CommonUtil.sol";
import "./TraceAsset.sol";

contract CompanyLogic is AccessControl,CommonUtil {
   TraceAsset private _trace;

    address private admin;
    address private implementationAddress;
    string private company_name;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 public constant BE_FIRED_ROLE = keccak256("Fired");

    mapping (address => DataStruct.Worker) private workerList;

    // 资产总数
    uint256 public assetCount;
    // id => AssetMateData
    mapping (uint256 => DataStruct.AssetMetadata) private assetList;
    // 用于判断是否有重复的cid
    mapping (string => bool) cidIsValid;
    // 记录创建资产事件
    event LogCreateAsset(address indexed creator,uint256 indexed groupId,string assetName,uint256 createTime,string encodeCid);

    event NewWorkerAdd(address worker_address, string company_name);
    event NewWorkerRemoved(address worker_address, string company_name);

    constructor() AccessControl(msg.sender) {}

    /**
     * 判断有无重复cid
     */
    modifier checkCid(string memory _cid){
        require(!cidIsValid[_cid],"CompanyLogic::CheckCid:: cid is invalid");
        _;
    }

    /**
     * 检查asset有效性
     */
    modifier checkAssetValid(uint id){
        require(assetList[id].isValid,"CompanyLogic::CheckAssetValid:: asset is invalid");
        _;
    }

    /**
    添加员工(到指定组) (admin)
    **/
    function addWorker(string memory _groupName, address worker_address) public AccessControl.onlyRole(ADMIN_ROLE) returns (bool)  {
        bytes32 groupRole = toRole(_groupName);
        require(!hasRole(groupRole, worker_address), error("CompanyLogic", "addWorker", "worker has been added"));
        setRoleAdmin(groupRole,ADMIN_ROLE);
        grantRole(groupRole, worker_address);
        workerList[worker_address] = DataStruct.Worker(groupRole);
        emit NewWorkerAdd(worker_address, company_name);
        return true;
    }

    /**
    删除员工 (admin)
    **/
    function removedWorker(address worker_address) public AccessControl.onlyRole(ADMIN_ROLE) returns (bool) {
        DataStruct.Worker memory _removedWorker = workerList[worker_address];
        require(hasRole(_removedWorker.group, worker_address), error("CompanyLogic", "removedWorker", "The Worker No Found"));
        revokeRole(_removedWorker.group, worker_address);
        workerList[worker_address] = DataStruct.Worker(
             BE_FIRED_ROLE
        );
        emit NewWorkerRemoved(worker_address, company_name);
        return true;
    }

    /**
     * 添加数据资产
     */
    function addAsset(
            string memory _encodeCid,
            string memory _name,
            uint256 _groupId
        ) public AccessControl.onlyRole(ADMIN_ROLE) checkCid(_encodeCid) {
        DataStruct.AssetMetadata memory data = DataStruct.AssetMetadata({
            encodeCid: _encodeCid,
            name: _name,
            createdAt: block.timestamp,
            creator: msg.sender,
            groupId: _groupId,
            traceCount: 0,
            isValid: true
        });

        assetList[assetCount] = data;
        // 添加追溯信息
        DataStruct.AssetTrace memory traceNode = DataStruct.AssetTrace(data.createdAt,msg.sender,"create");
        _trace.add(assetCount,traceNode);
        ++assetCount;
        emit LogCreateAsset(msg.sender,_groupId,_name,data.createdAt,_encodeCid);
    }

    /**
     * 获取单个AssetData
     */
    function getAsset(uint256 id) public view checkAssetValid(id) returns (DataStruct.AssetMetadata memory) {
        return assetList[id];
    }
     /**
     * 更新数据
     **/
    function updateGroup(uint256 id,uint256 _groupId) public AccessControl.onlyRole(ADMIN_ROLE) checkAssetValid(id){
        DataStruct.AssetMetadata memory data = assetList[id];

        data.groupId = _groupId;
        assetList[id] = data;

        // 记录
        DataStruct.AssetTrace memory traceNode = DataStruct.AssetTrace(block.timestamp,msg.sender,strConcat("update groupId to",toString(_groupId)));
        _trace.add(id,traceNode);

    }

    /**
     * 删除数据
     */
    function deleteAsset(uint256 id) public AccessControl.onlyRole(ADMIN_ROLE) checkAssetValid(id){
         DataStruct.AssetMetadata memory data = assetList[id];

        data.isValid = false;
        assetList[id] = data;

        // 记录
        DataStruct.AssetTrace memory traceNode = DataStruct.AssetTrace(block.timestamp,msg.sender,strConcat("delete asset,id: ",toString(id)));
        _trace.add(id,traceNode);
    }

    /**
     * 获取追溯合约地址
     */
    function getTraceAddr() public view returns(address) {
        return address(_trace);
    }

    /**
     * 获取assetCount
     */
    function getAssetCount() public view returns(uint256){
        return assetCount;
    }
}
