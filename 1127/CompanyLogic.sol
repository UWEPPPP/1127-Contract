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
 

    event NewWorkerAdd(string did,string company_name);

    event NewWorkerRemoved(string did,string company_name);

    constructor() AccessControl(msg.sender){
       
    }
   

    
    /**
    增加员工
    **/
    function addWorker(string memory worker_did,address worker_address) public AccessControl.onlyRole(ADMIN_ROLE) returns (bool)  {
        if(hasRole(WORKER_ROLE,worker_address)){
            return false;
        }
        grantRole(WORKER_ROLE,worker_address);
        workerList[worker_did] = DataStruct.Worker(
             worker_did,worker_address
        );
        emit NewWorkerAdd(worker_did,company_name);
        return true;
    }
    
    /**
    删除员工
    **/
   function removedWorker(string memory worker_did) public  AccessControl.onlyRole(ADMIN_ROLE) returns (bool) {
        DataStruct.Worker memory _removedWorker = workerList[worker_did];
        if(!hasRole(WORKER_ROLE,_removedWorker.addr)){
            return false;
        }
        revokeRole(WORKER_ROLE, _removedWorker.addr);
        workerList[worker_did] = DataStruct.Worker(
             "",address(0)
        );
        emit NewWorkerRemoved(worker_did,company_name);
        return true;
    }

    function addDataGroup(string memory _groupName) public AccessControl.onlyRole(ADMIN_ROLE) ret
}