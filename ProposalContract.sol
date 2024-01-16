// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    address owner ;
    uint256 counter ;
    struct MoreDescription {
        string title;
        uint date;
        string total_description;
    }
    struct Proposal {
        MoreDescription description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether if passes of fails
        bool is_active; // This shows if others can vote to our contract
    }
    
    mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals
    address[]  private voted_addresses;//recording address already use for vote


    constructor() { // for define owner of contract
         owner = msg.sender;
         voted_addresses.push(msg.sender);
    }

    modifier onlyOwner() { // for give access for some function just owner 
        require(msg.sender == owner,"only owner can run this function");
    _;
    }

    modifier newVoter(address _address) {
        require(!isVoted(_address), "Address has already voted");
    _;
    }
    
    //create a new proposal 
    function create(string memory title,string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
    counter += 1;
    proposal_history[counter] = Proposal(MoreDescription(title,block.timestamp,_description), 0, 0, 0, _total_vote_to_end, false, true);
    }
    
    // owner can change address to another owner 
    function setOwner(address new_owner) external onlyOwner {
    owner = new_owner;
    }

    // function to make a vote 
    function vote(uint8 choice) external {
    // Function logic
    // First part
        Proposal storage proposal = proposal_history[counter];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;

        // Second part
        voted_addresses.push(msg.sender);
        if (choice == 1) {
            proposal.approve += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 2) {
            proposal.reject += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 0) {
            proposal.pass += 1;
            proposal.current_state = calculateCurrentState();
        }

        // Third part
        if ((proposal.total_vote_to_end - total_vote == 1) && (choice == 1 || choice == 2 || choice == 0)) {
            proposal.is_active = false;
            voted_addresses = [owner];
        }
            }

    modifier active() {
    require(proposal_history[counter].is_active == true, "The proposal is not active");
    _;
    }


    // in my logic i don't consider pass voted
    function calculateCurrentState() private view returns(bool) {
    Proposal storage proposal = proposal_history[counter];

    uint256 approve = proposal.approve;
    uint256 reject = proposal.reject;
    
    if (approve > reject ) {
        return true;
    } else {
        return false;
    }
    }

    function teminateProposal() external onlyOwner active {
    proposal_history[counter].is_active = false;
    }


    function isVoted(address _address) public view returns (bool) {
    for (uint i = 0; i < voted_addresses.length; i++) {
        if (voted_addresses[i] == _address) {
            return true;
        }
    }
    return false;
    }

    function getCurrentProposal() external view returns(Proposal memory) {
    return proposal_history[counter];
    }

    function getProposal(uint256 number) external view returns(Proposal memory) {
    return proposal_history[number];
    }


}
