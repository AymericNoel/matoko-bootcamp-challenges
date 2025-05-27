import Result "mo:base/Result";

module {
  public type Result<A, B> = Result.Result<A, B>;

  public type Actor = actor {
    tokenName : () -> async Text;
    tokenSymbol : () -> async Text;
    mint : (Principal, Nat) -> async Result<(), Text>;
    burn : (Principal, Nat) -> async Result<(), Text>;
    balanceOf : (Principal) -> async Nat;
    balanceOfArray : ([Principal]) -> async [Nat];
    totalSupply : () -> async Nat;
    transfer : (Principal, Principal, Nat) -> async Result<(), Text>;
  };
}
