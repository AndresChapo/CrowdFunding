pragma solidity ^0.4.24;

import "./Utils.sol";

contract CrowdFundingWithDeadline {
    using Utils for *;
    enum State { Ongoing, Failed, Succeeded, PaidOut }

    event CampaingnFinished(
        address addr,
        uint totalCollected,
        bool succeded
    );

    string public name;
    uint public targetAmount;
    uint public fundingDeadline;
    address public beneficiary;
    State public state;
    mapping(address => uint) public amounts;
    bool public collected;
    uint public totalCollected;

    modifier inState(State expectedState){
        require(expectedState == state, "Invalid state");
        _;
    }

    constructor(
        string contractName,
        uint targetAmountEth,
        uint durationInMin,
        address beneficiaryAddress
    )
    public
    {
        name = contractName;
        targetAmount = Utils.etherToWei(targetAmountEth);
        fundingDeadline = currentTime() + Utils.minutesToSeconds(durationInMin);
        beneficiary = beneficiaryAddress;
        state = State.Ongoing;
    }

    function contribute() public payable inState(State.Ongoing) {
        require(
            beforeDeadline(),
            "No contributions after the deadline"
        );
        amounts[msg.sender] += msg.value;
        totalCollected += msg.value;

        if (totalCollected >= targetAmount){
            collected = true;
        }
    }

    function finishCrowdFunding() public inState(State.Ongoing){
        require(!beforeDeadline(), "Cannot finish campaign before a deadline");

        if(collected) {
            state = State.Succeeded;
        } else {
            state = State.Failed;
        }

        emit CampaingnFinished(this, totalCollected, collected);
    }

    function collect() public inState(State.Succeeded){
        if(beneficiary.send(totalCollected)) {
            state = State.PaidOut;
        } else {
            state = State.Failed;
        }
    }

    function withdraw() public inState(State.Failed){
        require(amounts[msg.sender] > 0, "Nothing was contributed");
        uint contributed = amounts[msg.sender];
        amounts[msg.sender] = 0;

        if(!msg.sender.send(contributed)) {
            amounts[msg.sender] = contributed;
        } 
    }

    function beforeDeadline() public view returns(bool){
        return currentTime() < fundingDeadline;
    }

    function currentTime() internal view returns(uint){
        return now;
    }
}