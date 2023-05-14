import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Array "mo:base/Debug";

actor {
  type Homework = {
    title : Text;
    description : Text;
    dueDate : Time.Time;
    completed : Bool;

  };

  var homework_diary = Buffer.Buffer<Homework>(0);

  // Add a new homework task
  public shared func addHomework(homework : Homework) : async Nat {
    homework_diary.add(homework);
    return homework_diary.size() -1;
  };

  // Get a specific homework task by id

  public shared query func getHomework(id : Nat) : async Result.Result<Homework,Text> {

    if (id <= homework_diary.size()) { 
      let res = homework_diary.get(id);     
       return #ok(res);
    } else {
      return #err("not implemented");
    };

  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> { 
   
    let todo = homework_diary.getOpt(id);
    
    if (todo != null) {      
     homework_diary.put(id,homework);
       #ok();
    } else {
      return #err("not implemented");
    };
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    if (homework_diary.getOpt(id) == null) {
      return #err("Id invalid");
    } else {
      let homework = homework_diary.get(id);
      let updateHomework : Homework = {
        title : Text = homework.title;
        description : Text = homework.description;
        dueDate : Time.Time = homework.dueDate;
        completed : Bool = true;
      };
      homework_diary.put(id, updateHomework);
    };

    return #ok();
  };
  func deleteHomework(id : Nat) : Result.Result<Null, Text> {
    let newid : Nat = id - 1;
    let todo = homework_diary.getOpt(newid);
    if (todo != null) {
      let x = homework_diary.remove(newid);
      return #ok(null);
    } else {
      return #err("not implemented");
    };
  };
  public shared query func getAllHomework() : async [Homework] {

    let lista = Buffer.toArray(homework_diary);
    return lista;
  };
  public shared query func getPendingHomework() : async [Homework] {

    let arrayRes = Buffer.Buffer<Homework>(0);
    for (element in homework_diary.vals()) {
      if (not element.completed) {
        arrayRes.add(element);
      };
    };
    let res = Buffer.toArray(arrayRes);
    return res;
  };
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
    let result = Buffer.Buffer<Homework>(0);
    for (element in homework_diary.vals()) {
      if (element.title == searchTerm or element.description == searchTerm) {
        result.add(element);
      };
    };
    let res = Buffer.toArray(result);
    return res;
  };

};
