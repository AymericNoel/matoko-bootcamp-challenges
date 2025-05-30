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
};