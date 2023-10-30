// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import  "./CommonUtil.sol";
import "./TraceAsset.sol";
contract CompanyProxy is AccessControl,CommonUtil {
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
    
    
     constructor(address founder,string memory _company_name,address commonLogicAddress) AccessControl(msg.sender){
        _trace=new TraceAsset();
        admin = founder;
        setRoleAdmin(ADMIN_ROLE,DEFAULT_ADMIN);
        grantRole(ADMIN_ROLE, founder);
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