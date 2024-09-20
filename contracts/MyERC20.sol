// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyERC20 {

    address immutable _owner;
    string private _name;
    string private _symbol;
    uint8 constant _decimals = 18;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances; //myAccount => (others => allowance)

    modifier onlyOwner() {
        require(msg.sender == _owner, "onlyOwner!");
        _;
    }

    modifier hasBalance(address account, uint256 amount) {
        require(_balances[account] >= amount, "do not have enough balance");
        _;
    }

    modifier hasAllowance(address from, uint256 amount) {
        require(_allowances[from][msg.sender] >= amount, "not enough allowance");
        _;
    }

    constructor(string memory name, string memory symbol) {
        _name = name;
        _symbol = symbol;
        _owner = msg.sender;
    }

    function approve(address thirdParty, uint256 amount) external {//授权
        if (thirdParty == address(0)) {
            revert("address cannot be 0.");
        }
        require(amount > 0, "allowance should be greater than 0.");
        _allowances[msg.sender][thirdParty] = amount;
        emit Approval(msg.sender, thirdParty, amount);
    }

    function transferTo(address to, uint256 amount) external hasBalance(msg.sender, amount) {
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function transferFromTo(address from, address to, uint256 amount) external hasBalance(from, amount) hasAllowance(from, amount) {
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }
    event Approval(address owner, address thirdParty, uint256 amount);
    event Transfer(address from, address to, uint256 amount);
    
    function mint(address account, uint256 amount) external onlyOwner {
        _balances[account] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner hasBalance(account, amount) {
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function getName() external view returns(string memory) {
        return _name;
    }

    function getDecimals() external pure returns(uint256) {
        return _decimals;
    }

    function getSymbol() external view returns(string memory) {
        return _symbol;
    }

    function getBalance(address add) external view returns(uint256 balance) {
        return _balances[add];
    }

    function getTotalSupply() external view returns(uint256) {
        return _totalSupply;
    }

    function getOwner() external view returns(address) {
        return _owner;
    }

}