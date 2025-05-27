import Result "mo:base/Result";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Types "types";
import Array "mo:base/Array";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";

actor {
        type Result<A, B> = Result.Result<A, B>;
        type Member = Types.Member;
        type Role = Types.Role;
        type ProposalContent = Types.ProposalContent;
        type ProposalId = Types.ProposalId;
        type Proposal = Types.Proposal;
        type Vote = Types.Vote;
        type ProposalStatus = Types.ProposalStatus;
        type HttpRequest = Types.HttpRequest;
        type HttpResponse = Types.HttpResponse;

        stable var manifesto = "My best manifesto";
        stable let name = "This my ICP dao";
        let goals = Buffer.Buffer<Text>(0);
        let members = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);

        let defaultPrincipal = Principal.fromText("nkqop-siaaa-aaaaj-qa3qq-cai");
        let defaultMember = {
                name = "motoko_bootcamp";
                role = #Mentor;
        };
        members.put(defaultPrincipal, defaultMember);

        let Token = actor ("jaamb-mqaaa-aaaaj-qa3ka-cai") : actor {
                mint : (Principal, Nat) -> async Result<(), Text>;
                burn : (Principal, Nat) -> async Result<(), Text>;
                balanceOf : (Principal) -> async Nat;
        };

        let principalIdWebpage = Principal.fromText("75i2c-tiaaa-aaaab-qacxa-cai");
        let Webpage = actor (Principal.toText(principalIdWebpage)) : actor {
                setManifesto : (Text) -> async Result<(), Text>;
        };

        type Hash = Nat32;
        let proposals = HashMap.HashMap<ProposalId, Proposal>(0, Nat.equal,   func(x: ProposalId): Hash = Nat32.fromNat(x));
        stable var nextProposalId : Nat = 0;

        public query func getName() : async Text {
                return name;
        };

        public query func getManifesto() : async Text {
                return manifesto;
        };

        public query func getGoals() : async [Text] {
                Buffer.toArray(goals);
        };

        public shared ({ caller }) func registerMember(member : Member) : async Result<(), Text> {
                switch (members.get(caller)) {
                        case (null) {
                                members.put(caller, member);
                                let mintRes = await Token.mint(caller, 10);
                                switch (mintRes) {
                                        case (#ok()) return #ok();
                                        case (#err(e)) return #err("Token mint error: " # e);
                                };
                                return #ok();
                        };
                        case (?member) {
                                return #err("Member already exists");
                        };
                };
        };

        public query func getMember(p : Principal) : async Result<Member, Text> {
                switch (members.get(p)) {
                        case (null) {
                                return #err("Member does not exist");
                        };
                        case (?member) {
                                return #ok(member);
                        };
                };
        };

        public shared ({ caller }) func graduate(student : Principal) : async Result<(), Text> {
                switch (members.get(caller)) {
                        case (null) {
                                return #err("Caller not a member, cannot create a proposal");
                        };
                        case (?member) {
                                if (member.role == #Mentor) {
                                        switch (members.get(student)) {
                                                case (null) {
                                                        return #err("Student not found");
                                                };
                                                case (?s) {
                                                        if (s.role != #Student) return #err("Target is not a student");
                                                        members.put(student, { name = s.name; role = #Graduate });
                                                        return #ok();
                                                };
                                        };
                                } else return #err("Only mentors can graduate students");

                        };
                };

        };

        public shared ({ caller }) func createProposal(content : ProposalContent) : async Result<ProposalId, Text> {
                switch (members.get(caller)) {
                        case null return #err("Member not found");
                        case (?m) {
                                if (m.role != #Mentor) return #err("Only mentors can create proposals");
                                let balance = await Token.balanceOf(caller);
                                if (balance < 1) return #err("Insufficient MBT to create proposal");
                                let burnRes = await Token.burn(caller, 1);
                                if (burnRes != #ok()) return #err("Failed to burn MBT");

                                switch (content) {
                                        case (#AddMentor(principal)) {
                                                switch (members.get(principal)) {
                                                        case null return #err("Student in proposal not found");
                                                        case (?stu) {
                                                                if (stu.role != #Graduate) return #err("Only graduates can become mentors");
                                                        };
                                                };
                                        };
                                        case _ {};
                                };

                                let prop : Proposal = {
                                        id = nextProposalId;
                                        content = content;
                                        creator = caller;
                                        created = Time.now();
                                        executed = null;
                                        votes = [];
                                        voteScore = 0;
                                        status = #Open;
                                };
                                proposals.put(nextProposalId, prop);
                                nextProposalId += 1;
                                return #ok(prop.id);
                        };
                };
        };

        public query func getProposal(id : ProposalId) : async ?Proposal {
                return proposals.get(id);
        };

        public query func getAllProposals() : async [Proposal] {
                return Iter.toArray(proposals.vals());
        };

        public query func getIdWebpage() : async Principal {
                return principalIdWebpage;
        };

        public shared ({ caller }) func voteProposal(proposalId : ProposalId, yesOrNo : Bool) : async Result<(), Text> {
                switch (proposals.get(proposalId)) {
                        case (null) {
                                return #err("The proposal does not exist");

                        };
                        case (?proposal) {
                                if (proposal.status != #Open) return #err("Proposal is not open for voting");
                                switch (members.get(caller)) {
                                        case (null) {
                                                return #err("Caller is not a member, cannot vote proposal");
                                        };
                                        case (?member) {
                                                if (member.role == #Student) return #err("Students cannot vote");

                                                let tokens = await Token.balanceOf(caller);
                                                let power = switch (member.role) {
                                                        case (#Graduate) tokens;
                                                        case (#Mentor) tokens * 5;
                                                        case _ 0;
                                                };

                                                let signedPower : Int = if (yesOrNo) power else -1 * power;
                                                let newScore = proposal.voteScore + signedPower;
                                                let votes : [Vote] = proposal.votes;
                                                let newVotes = Array.append(votes, [{ member = caller; votingPower = power; yesOrNo = yesOrNo }]);

                                                var newStatus = proposal.status;
                                                var executed : ?Time.Time = null;

                                                if (newScore >= 100) {
                                                        newStatus := #Accepted;
                                                        executed := ?Time.now();
                                                        switch (proposal.content) {
                                                                case (#ChangeManifesto(txt)) {
                                                                        manifesto := txt;
                                                                        let res = await Webpage.setManifesto(txt);
                                                                        switch res {
                                                                                case (#ok()) {};
                                                                                case (#err(e)) {
                                                                                        return #err("Failed to set new manifesto in webpage");
                                                                                };
                                                                        };
                                                                };
                                                                case (#AddGoal(goal)) {
                                                                        goals.add(goal);
                                                                };
                                                                case (#AddMentor(p)) {
                                                                        switch (members.get(p)) {
                                                                                case (?m) {
                                                                                        let updatedMember = {
                                                                                                name = m.name;
                                                                                                role = #Mentor;
                                                                                        };
                                                                                        members.put(p, updatedMember);
                                                                                };
                                                                                case null {
                                                                                        return #err("Member to add as mentor not found");
                                                                                };
                                                                        };
                                                                };
                                                        };
                                                } else if (newScore <= -100) {
                                                        newStatus := #Rejected;
                                                        executed := ?Time.now();
                                                };

                                                let newProposal : Proposal = {
                                                        id = proposal.id;
                                                        content = proposal.content;
                                                        creator = proposal.creator;
                                                        created = proposal.created;
                                                        executed = executed;
                                                        votes = newVotes;
                                                        voteScore = newScore;
                                                        status = newStatus;
                                                };
                                                proposals.put(proposalId, newProposal);

                                                return #ok();
                                        }

                                };
                        }

                };
        };
};
