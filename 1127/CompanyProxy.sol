// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "1127/util/AccessControl.sol";
import "1127/DataStruct.sol";

contract CompanyProxy is AccessControl {
    address private implementationAddress;

    string private company_name;

    bytes32 public constant COMPANY_ADMIN_ROLE = keccak256("ADMIN");

    bytes32 public constant COMPANY_WORKER_ROLE = keccak256("WORKER");

    mapping (string => DataStruct.Worker) private  workerList; 

    event NewWorkerAdd(string did,string company_name);
    
    
     constructor(address founder,string memory _company_name,address commonLogicAddress) AccessControl(msg.sender){
        setRoleAdmin(COMPANY_ADMIN_ROLE,DEFAULT_ADMIN);
        setRoleAdmin(COMPANY_WORKER_ROLE,COMPANY_ADMIN_ROLE);
        grantRole(COMPANY_ADMIN_ROLE, founder);
        implementationAddress = commonLogicAddress;
        company_name = _company_name;
     }

 
    function _delegate(address implementation) internal  {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function updateImplementation(address newLogicAddress) public AccessControl.onlyRole(DEFAULT_ADMIN) returns (bool){
         if(newLogicAddress == address(0)){
            return false;
         }
         implementationAddress = newLogicAddress;
         return true;
    }


    function _implementation() internal view  returns (address){
        return implementationAddress;
    }

    function _fallback() internal  {
        _delegate(_implementation());
    }

    fallback() external   {
        _fallback();
    }

}