actor MotivationLetter {
    let name : Text = "This is my best name";

    var message : Text = "My bets message";

    public shared func setMessage(newMessage : Text) : async () {
        message := newMessage;
    };

    public query func getMessage() : async Text {
        return message;
    };

    public query func getName() : async Text {
        return name;
    };
};
