import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
module {
  public type Result<Ok, Err> = Result.Result<Ok, Err>;
  public type HashMap<Ok, Err> = HashMap.HashMap<Ok, Err>;
  public type Member = {
    name : Text;
    age : Nat;
  };

  public type ProposalId = Nat64;
  public type ProposalContent = {
    #ChangeManifesto : Text;
    #AddGoal : Text;
  };
  public type ProposalStatus = {
    #Open;
    #Accepted;
    #Rejected;
  };
  public type Vote = {
    member : Principal;
    votingPower : Nat;
    yesOrNo : Bool;
  };
  public type Proposal = {
    id : Nat64;
    content : ProposalContent;
    creator : Principal;
    created : Time.Time;
    executed : ?Time.Time;
    votes : [Vote];
    voteScore : Int;
    status : ProposalStatus;
  };

};