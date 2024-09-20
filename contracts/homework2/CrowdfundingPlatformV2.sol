// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./CrowdfundingPlatform.sol";

contract CrowdfundingPlatformV2 is UUPSUpgradeable, OwnableUpgradeable {
    // 在 V2 中添加的新状态变量或功能
    uint256 public newFeature;

    // 在 V2 中的构造函数可以为空，因为不需要初始化新的变量
    function initialize(address addr) public initializer {
        __Ownable_init(addr);
        __UUPSUpgradeable_init();
    }

    // 新功能的设置函数
    function setNewFeature(uint256 _value) external onlyOwner {
        newFeature = _value;
    }

    // 可以在 V2 中重写 V1 中的方法或添加新的方法
    function newMethod() external pure returns (string memory) {
        return "This is a new method in V2.";
    }

    // 必须重写授权升级的方法
    function _authorizeUpgrade(address newImplementation) internal view override onlyOwner {
        // 这里可以加入任何额外的权限控制逻辑
    }
}
