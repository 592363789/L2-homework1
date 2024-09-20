// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Project {
    address public creator;
    string public description;
    uint256 public goalAmount;
    uint256 public deadline;
    uint256 public currentAmount;
    enum ProjectState {
        Ongoing,
        Successful,
        Failed
    }
    ProjectState public state;
    struct Donation {
        address donor;
        uint256 amount;
    }
    Donation[] public donations;

    event DonationReceived(address indexed donor, uint256 amount);
    event ProjectStateChanged(ProjectState newState);
    event FundsWithdrawn(address indexed creator, uint256 amount);
    event FundsRefunded(address indexed donor, uint256 amount);

    modifier onlyCreator() {
        require(msg.sender == creator);
        _;
    }

    modifier onlyAfterDeadline() {
        require(block.timestamp > deadline, "only after dealine!");
        _;
    }

    function initialize(address _creator, string memory _description, uint256 _goalAmount, uint256 _duration) public {
        creator = _creator;
        description = _description;
        goalAmount = _goalAmount;
        deadline = block.timestamp + _duration;
        state = ProjectState.Ongoing;
    }

    function donate() external payable {
        require(state == ProjectState.Ongoing, "Project is not ongoing.");
        require(block.timestamp < deadline, "Project deadline has passed.");
        donations.push(Donation(msg.sender, msg.value));
        currentAmount += msg.value;
        emit DonationReceived(msg.sender, msg.value);

    }

    function withdrawFunds() external onlyCreator onlyAfterDeadline {
        require(state == ProjectState.Successful, "Project is not successful");
        uint256 amount = address(this).balance;
        payable(creator).transfer(amount);
        emit FundsWithdrawn(creator, amount);
    }

    function refund() external onlyAfterDeadline {
        require(state == ProjectState.Failed, "Project is not failed");
        uint256 amount = 0;
        for (uint256 i = donations.length - 1; i >= 0; i--) {
            if (donations[i].donor == msg.sender) {
                amount += donations[i].amount;
            }
        }
        require(amount > 0, "no funds to refund");
        payable(msg.sender).transfer(amount);
        emit FundsRefunded(msg.sender, amount);
    }

    function updateProjectState() external onlyAfterDeadline {
        require(state == ProjectState.Ongoing, "Project is not ongoing");
        if (currentAmount >= goalAmount) {
            state = ProjectState.Successful;
        } else {
            state = ProjectState.Failed;
        }
        emit ProjectStateChanged(state);
    }
}