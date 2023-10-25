// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

//权限控制合约
contract AccessControl {
    struct RoleData {
        mapping(address => bool) hasRoles;
        bytes32 adminRole;
    }

    bytes32 public constant DEFAULT_ADMIN = 0x00;

    mapping(bytes32 => RoleData) private roles;
    
    //某角色的管理员变更
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );
    
    //某角色人员的增加
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    
    //某角色人员的减少
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    
    modifier onlyRole(bytes32 role) {
        checkRole(role);
        _;
    }

    constructor(address admin){
        roles[DEFAULT_ADMIN].hasRoles[admin] = true;
    }

    
    //检查身份
    function checkRole(bytes32 role) public view returns (bool) {
        if (!hasRole(role, msg.sender)) {
            revert("UnAuthorizedAccount");
        }
        return true;
    }
    
    
    function hasRole(bytes32 role, address member) public view returns (bool) {
        return roles[role].hasRoles[member];
    }
    
    //获得某角色管理员的
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return roles[role].adminRole;
    }
    
    //设置角色管理员
    function setRoleAdmin(bytes32 role ,bytes32 admin) internal virtual  {
        bytes32 oldAdmin = getRoleAdmin(role);
        roles[role].adminRole=admin;
        emit RoleAdminChanged(role,oldAdmin, admin);
    }
    
    //将某账户加入某角色
    function grantRole(bytes32 role, address member)
        public
        onlyRole(getRoleAdmin(role))
        returns (bool)
    {
        if (hasRole(role, member)) {
            return false;
        }
        roles[role].hasRoles[member] = true;
        emit RoleGranted(role, member, msg.sender);
        return true;
    }
    
    //将某账户从某角色中删除
    function revokeRole(bytes32 role, address member)
        public
        onlyRole(getRoleAdmin(role))
        returns (bool)
    {
        if (!hasRole(role, member)) {
            return false;
        }
        roles[role].hasRoles[member] = false;
        emit RoleRevoked(role, member, msg.sender);
        return true;
    }
    
    //当账户有威胁时 可以自主消除权限
    function renounceRole(bytes32 role, address callerConfirmation)
        public
        
    {
        if (callerConfirmation != msg.sender) {
            revert("BadConfirmation");
        }
        revokeRole(role, callerConfirmation);
    }
}
