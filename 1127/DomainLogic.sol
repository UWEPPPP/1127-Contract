// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "./CompanyProxy.sol";
contract DomainContract is AccessControl,CommonUtil{
    address private  _commonlogicContract; 
    bytes32 public constant DOMAIN_ADMIN = keccak256("Domain_ADMIN");

    mapping ( string => DataStruct.Company) companies;

    event NewCompanyRegistered(string did,string name,address company_address);

    event NewCompanyRemoved(string did,string name,address company_address);

    constructor(address _domainAdminAddress,address _commonlogicAddress) AccessControl(msg.sender){
          
          setRoleAdmin(DOMAIN_ADMIN,DEFAULT_ADMIN);
          grantRole(DOMAIN_ADMIN, _domainAdminAddress);
          _commonlogicContract = _commonlogicAddress;
    }

    function registerCompany(string memory company_did,string memory company_name,address company_owner)public AccessControl.onlyRole(DOMAIN_ADMIN) returns (address companyAddr) {
       
       require(companies[company_did].addr == address(0),error("DomainLogic","registerCompany","The company is existed"));
       CompanyProxy companyAddress = new CompanyProxy(company_owner,company_name,_commonlogicContract);
       companies[company_did]= DataStruct.Company(company_did,company_owner,company_name);
       emit NewCompanyRegistered(company_did,company_name,address(companyAddress));
       return address(companyAddress);
    }

    function removeCompany(string memory company_did)public AccessControl.onlyRole(DOMAIN_ADMIN) returns (bool result) {
       
       require(companies[company_did].addr != address(0),error("DomainLogic","removeCompany","The company doesn't exist"));
       DataStruct.Company memory _removedcompany = companies[company_did];
       companies[company_did]= DataStruct.Company("",address(0),"");
       //理论上还得做更多操作 暂定这样先
       emit NewCompanyRemoved(company_did,_removedcompany.name,_removedcompany.addr);
       return true;
    }
}
