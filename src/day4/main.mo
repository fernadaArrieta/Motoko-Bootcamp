import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Nat "mo:base/Debug";
import Account "Account";
import BootcampLocalActor "BootcampLocalActor";
import Hash "mo:base/Hash";

actor class MotoCoin() {
  public type Account = Account.Account;

  let ledger = TrieMap.TrieMap<Account.Account, Nat>(Account.accountsEqual, Account.accountsHash);
  var count : Nat = 0;

  let motoScool : actor { getAllStudentsPrincipal : () -> async [Principal] } = actor ("rww3b-zqaaa-aaaam-abioa-cai");

  // Returns the name of the token
  //Implementa name, que devuelve el nombre del token como un Text. El nombre del token es MotoCoin
  public query func name() : async Text {

    return "MotoCoin";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {

    return "MOC";
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
   
    for (val in ledger.vals()) count += val;

    return count;
  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {
    var value = ledger.get(account);
    return Option.get(value, 0);
  };

  /* Implementa transfer que acepta tres parámetros: un objeto Account para el remitente (from), un objeto Account para el destinatario (to) y un valor Nat para la cantidad a transferir. Esta función debe transferir la cantidad especificada de tokens de la cuenta del remitente a la cuenta del destinatario. Esta función debe devolver un mensaje de error envuelto en un resultado Err si el remitente no tiene suficientes tokens en su cuenta principal. */
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {
    if (caller != from.owner) {
      return #err("No puedes enviar activos a nombre de una cuenta que no te pertenece");
    };
    let balFrom = await balanceOf(from);
    if (balFrom < amount) {
      return #err("No hay fondos suficientes para efectuar la operación");
    };
    let balTo = await balanceOf(to);
    ledger.put(from, balFrom - amount);
    ledger.put(from, balTo + amount);
    return #ok();

  };

  // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {
    let allStudens = await motoScool.getAllStudentsPrincipal();

       var currentBal : Nat = 0;
        for(val in allStudens.vals()){
            var student : Account = {owner = val; subaccount = null};
            currentBal := await balanceOf(student);
            ledger.put(student, currentBal + 100);
            count += 100;
        };
        return #ok ();
    };  
  };

