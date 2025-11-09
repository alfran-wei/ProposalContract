// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    address public owner;
    uint256 public counter;

    struct MoreDescription {
        string title;
        uint date;
        string total_description;
    }

    struct Proposal {
        MoreDescription description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 total_vote_to_end;
        bool current_state;
        bool is_active;
        address[] voters;
    }

    mapping(uint256 => Proposal) public proposal_history;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can run this function");
        _;
    }

    modifier active(uint256 id) {
        require(proposal_history[id].is_active, "Proposal not active");
        _;
    }

    // Create a new proposal
    function create(
        string memory title,
        string calldata _description,
        uint256 _total_vote_to_end
    ) external onlyOwner {
        counter += 1;
        Proposal storage p = proposal_history[counter];
        p.description = MoreDescription(title, block.timestamp, _description);
        p.total_vote_to_end = _total_vote_to_end;
        p.is_active = true;
    }

    // Vote on a specific proposal by ID
    function vote(uint256 proposalId, uint8 choice) external active(proposalId) {
        Proposal storage proposal = proposal_history[proposalId];
        require(!hasVoted(proposalId, msg.sender), "You already voted");

        proposal.voters.push(msg.sender);

        if (choice == 1) proposal.approve += 1;
        else if (choice == 2) proposal.reject += 1;
        else if (choice == 0) proposal.pass += 1;

        proposal.current_state = (proposal.approve > proposal.reject);

        uint256 total_votes = proposal.approve + proposal.reject + proposal.pass;
        if (total_votes >= proposal.total_vote_to_end) {
            proposal.is_active = false;
        }
    }

    // Check if address already voted for this proposal
    function hasVoted(uint256 id, address voter) public view returns (bool) {
        address[] storage voters = proposal_history[id].voters;
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i] == voter) return true;
        }
        return false;
    }

    // Get one proposal by ID
    function getProposal(uint256 id) external view returns (Proposal memory) {
        return proposal_history[id];
    }

    // Get all proposals
    function getAllProposals() external view returns (Proposal[] memory) {
        Proposal[] memory all = new Proposal[](counter);
        for (uint256 i = 0; i < counter; i++) {
            all[i] = proposal_history[i + 1];
        }
        return all;
    }

    // Manually close a proposal
    function closeProposal(uint256 id) external onlyOwner {
        proposal_history[id].is_active = false;
    }

    // Change owner
    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }
}
