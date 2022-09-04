pragma solidity ^0.4.24;

contract CrowdFundingWithDeadline {
    enum State { Ongoing, Failed, Succeeded, PaidOut }

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
        targetAmount = targetAmountEth * 1 ether;
        fundingDeadline = currentTime() + durationInMin * 1 minutes;
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
    }

    function beforeDeadline() public view returns(bool){
        return currentTime() < fundingDeadline;
    }

    function currentTime() internal view returns(uint){
        return now;
    }
}