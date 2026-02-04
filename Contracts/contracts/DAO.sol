// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

  interface IERC20 {
      function transferFrom(address from, address to, uint256 amount) external returns (bool);
  }

contract Dao  {

  IERC20 public profi;
  IERC20 public rtk;

  constructor(address _profi, address _rtk) {
    profi = IERC20 (_profi);
    rtk = IERC20(_rtk);
  } 

  mapping(address => bool) public isMembers;

  enum ProposalType { A, B, C, D, E, F}
  enum ProposalStatus { Active, Accepted, Rejected }
  enum QuorumType {Simple, Super, Weighted} 

  struct Proposal {
    ProposalType pType;
    address proposer;
    uint votesFor;
    uint votesAgainst;
    uint endTime;
    QuorumType quorum;
    ProposalStatus status;
  }

  Proposal[] public proposals;
  
  function createProposal(
    ProposalType pType,
    uint duration,
    QuorumType quorum
  ) external {
    require(isMembers[msg.sender],"Not a member");

    proposals.push(Proposal({
      pType: pType,
      proposer: msg.sender,      
      votesFor: 0 ,
      votesAgainst: 0,
      endTime: block.timestamp + duration,
      quorum: quorum,
      status: ProposalStatus.Active
    })
  
    );

}
}