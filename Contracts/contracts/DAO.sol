// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/* ================= INTERFACE ================= */

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/* ================= DAO ================= */

contract Dao {

    /* ========== TOKENS ========== */

    IERC20 public profi;
    IERC20 public rtk;

    /* ========== OWNER ========== */

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /* ========== USERS ========== */

    struct UserInfo {
        bool registered;
        bool daoMember;
    }

    mapping(address => UserInfo) public users;

    modifier onlyRegistered() {
        require(users[msg.sender].registered, "Not registered");
        _;
    }

    modifier onlyDaoMember() {
        require(users[msg.sender].daoMember, "Not DAO member");
        _;
    }

    /* ========== PROPOSALS ========== */

    enum ProposalType { A, B, C, D, E, F }
    enum ProposalStatus { Active, Accepted, Rejected }
    enum QuorumType { Simple, Super, Weighted }

    struct Proposal {
        ProposalType pType;
        address proposer;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 endTime;
        QuorumType quorum;
        ProposalStatus status;
    }

    Proposal[] public proposals;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _profi, address _rtk) {
        profi = IERC20(_profi);
        rtk = IERC20(_rtk);

        owner = msg.sender;

        users[msg.sender] = UserInfo({
            registered: true,
            daoMember: true
        });
    }

    /* ========== USER MANAGEMENT ========== */

    function registerUser() external {
        require(!users[msg.sender].registered, "Already registered");

        users[msg.sender].registered = true;
    }

    function makeDaoMember(address user) external onlyOwner {
        require(users[user].registered, "User not registered");
        users[user].daoMember = true;
    }

    /* ========== CREATE PROPOSAL ========== */

    function createProposal(
        ProposalType pType,
        uint256 duration,
        QuorumType quorum
    ) external onlyDaoMember {

        proposals.push(
            Proposal({
                pType: pType,
                proposer: msg.sender,
                votesFor: 0,
                votesAgainst: 0,
                endTime: block.timestamp + duration,
                quorum: quorum,
                status: ProposalStatus.Active
            })
        );
    }

    /* ========== VOTE WITH PROFI ========== */

    function vote(
        uint256 id,
        bool support,
        uint256 profiAmount
    ) external onlyDaoMember {

        require(id < proposals.length, "Wrong id");

        Proposal storage p = proposals[id];
        require(block.timestamp < p.endTime, "Voting ended");
        require(p.status == ProposalStatus.Active, "Not active");

        profi.transferFrom(msg.sender, address(this), profiAmount);

        // 3 PROFI = 1 vote
        uint256 votes = profiAmount / (3 * 10 ** 12);

        if (support) {
            p.votesFor += votes;
        } else {
            p.votesAgainst += votes;
        }
    }

    /* ========== DELEGATE WITH RTK ========== */

    function delegate(
        uint256 id,
        uint256 rtkAmount
    ) external {

        require(id < proposals.length, "Wrong id");

        Proposal storage p = proposals[id];
        require(p.status == ProposalStatus.Active, "Not active");

        rtk.transferFrom(msg.sender, address(this), rtkAmount);

        // 2 RTK = 1 vote
        uint256 votes = rtkAmount / (2 * 10 ** 12);
        p.votesFor += votes;
    }

    /* ========== FINALIZE ========== */

    function finalize(uint256 id) external {
        require(id < proposals.length, "Wrong id");

        Proposal storage p = proposals[id];
        require(block.timestamp >= p.endTime, "Too early");
        require(p.status == ProposalStatus.Active, "Already finalized");

        uint256 total = p.votesFor + p.votesAgainst;
        bool accepted;

        if (p.quorum == QuorumType.Simple) {
            accepted = p.votesFor > total / 2;
        }
        else if (p.quorum == QuorumType.Super) {
            accepted = p.votesFor * 3 >= total * 2;
        }
        else {
            accepted = p.votesFor > p.votesAgainst;
        }

        p.status = accepted
            ? ProposalStatus.Accepted
            : ProposalStatus.Rejected;
    }

}
