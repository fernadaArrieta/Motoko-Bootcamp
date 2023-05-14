import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Option "mo:base/Option";
import Order "mo:base/Order";
import Int "mo:base/Int";



actor class StudentWall() {
  type Message = Type.Message;
  type Content = Type.Content;
  type Survey = Type.Survey;
  type Answer = Type.Answer;

  var messageId : Nat = 0;

  var wall = HashMap.HashMap<Nat, Message>(1, Nat.equal, Hash.hash);

  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
   
    messageId += 1;
    let newMessage = {
      content = c;
      vote = 0;
      creator = caller;
    };

    wall.put(messageId, newMessage);
    return messageId;
  };

  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    let res : ?Message = wall.get(messageId);
    switch (res) {
      case (null) { #err("not implemented") };
      case(?message){
        #ok(message); 
      };
     
    };

  };

  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    let res : ?Message = wall.get(messageId);
    switch (res) {
      case (null) {
        #err("you are trying to updated a non existent message");
      };
      case (?currentMessage){
        if (currentMessage.creator == caller) {
          let updateMessage = {
            content = c;
            vote = currentMessage.vote;
            creator = caller;
          };
          wall.put(messageId, updateMessage);
          #ok(());
        } else {
          #err("This not your message");
        };

      };
    };

  };

  // Delete a specific message by ID
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    let res : ?Message = wall.get(messageId);
    switch (res) {
      case (null) {
        #err("not implemented");
      };
      case (_) {
        ignore wall.remove(messageId);
        #ok();
      };
    };

   
  };

  // Voting
  public func upVote(messageId : Nat) : async Result.Result<(), Text> {
    let res : ?Message = wall.get(messageId);
    switch (res) {
      case (null) {
        #err("this message don't exist");
      };
      case (?ok) {
        let upVote = {
          content = ok.content;
          vote = ok.vote + 1;
          creator = ok.creator;
        };
        wall.put(messageId, upVote);
        #ok(());
      };

    };

  };

  public func downVote(messageId : Nat) : async Result.Result<(), Text> {

    let res : ?Message = wall.get(messageId);
    switch (res) {
      case (null) {
        #err("this message don't exist");
      };
      case (?ok) {
        let upVote = {
          content = ok.content;
          vote = ok.vote - 1;
          creator = ok.creator;
        };
        wall.put(messageId, upVote);
        #ok();
      };

    };
  };

  // Get all messages
  public func getAllMessages() : async [Message] {
    //Implementa la función de consulta getAllMessages, que devuelve la lista de todos los mensajes.

    var messages = Buffer.Buffer<Message>(0);

    for (message in wall.vals()) {
      messages.add(message);
    };
    let messageList = Buffer.toArray(messages);

    return messageList;   
  };

  public func getAllMessagesRanked() : async [Message] {
        var messages = Buffer.Buffer<Message>(0);

        func compare(messageA : Message , messageB : Message) : Order.Order{
            switch (Int.compare(messageA.vote , messageB.vote)){
                case (#greater){
                    return #less;
                };
                case(#less){
                    return #greater;
                };
                case(_){
                    return #equal
                }
            }
        };
        for (message in wall.vals()) {
            messages.add(message);

        };

        messages.sort(compare);

        return Buffer.toArray(messages);
    };
};
