import Time "mo:base/Time";
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

    public type DAOStats = {
        name : Text;
        manifesto : Text;
        goals : [Text];
        members : [Text];
        logo : Text;
        numberOfMembers : Nat;
    };
    public type HeaderField = (Text, Text);
    public type HttpRequest = {
        body : Blob;
        headers : [HeaderField];
        method : Text;
        url : Text;
    };
    public type HttpResponse = {
        body : Blob;
        headers : [HeaderField];
        status_code : Nat16;
        streaming_strategy : ?StreamingStrategy;
    };
    public type StreamingStrategy = {
        #Callback : {
            callback : StreamingCallback;
            token : StreamingCallbackToken;
        };
    };
    public type StreamingCallback = query (StreamingCallbackToken) -> async (StreamingCallbackResponse);
    public type StreamingCallbackToken = {
        content_encoding : Text;
        index : Nat;
        key : Text;
    };
    public type StreamingCallbackResponse = {
        body : Blob;
        token : ?StreamingCallbackToken;
    };
};