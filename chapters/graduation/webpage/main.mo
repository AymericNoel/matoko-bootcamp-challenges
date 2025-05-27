import Types "types";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Principal "mo:base/Principal";

actor Webpage {
    type Result<A, B> = Result.Result<A, B>;
    type HttpRequest = Types.HttpRequest;
    type HttpResponse = Types.HttpResponse;

    stable var manifesto : Text = "Let's graduate!";

    stable var daoCanisterId : Principal = Principal.fromText("aaaaa-aa");

    public query func http_request(req : HttpRequest) : async HttpResponse {
        let responseText = switch (req.url) {
            case "/" manifesto;
            case _ "404: Not Found";
        };
        return {
            status_code = if (req.url == "/") 200 else 404;
            headers = [("Content-Type", "text/plain; charset=utf-8")];
            body = Text.encodeUtf8(responseText);
            streaming_strategy = null;
        };
    };

    public shared func initDaoCanister(daoPrincipal : Principal) : async Result<(), Text> {
        if (Principal.toText(daoCanisterId) != "aaaaa-aa") {
            return #err("DAO canister already initialized");
        };
        daoCanisterId := daoPrincipal;
        #ok(())
    };

    public shared ({ caller }) func setManifesto(newManifesto : Text) : async Result<(), Text> {
        if (caller != daoCanisterId) {
            return #err("Unauthorized: only DAO can set the manifesto");
        };
        manifesto := newManifesto;
        return #ok();
    };
};
