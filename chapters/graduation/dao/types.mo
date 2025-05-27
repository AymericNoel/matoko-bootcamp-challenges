import Principal "mo:base/Principal";
import Time "mo:base/Time";
module {

    public type Role = {
        #Student;
        #Graduate;
        #Mentor;
    };

    public type Member = {
        name : Text;
        role : Role;
    };

    public type ProposalId = Nat;

    public type ProposalContent = {
        #ChangeManifesto : Text;
        #AddGoal : Text;
        #AddMentor : Principal;
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
        id : ProposalId;
        content : ProposalContent;
        creator : Principal;
        created : Time.Time;
        executed : ?Time.Time;
        votes : [Vote];
        voteScore : Int;
        status : ProposalStatus;
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