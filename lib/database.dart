import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class Database {

  static handleSignIn(String username, String password){
    Future<FirebaseUser> newUser= FirebaseAuth.instance.createUserWithEmailAndPassword(email: username, password: password)
        .then((user){print("user created: $user");})
        .catchError((Object error)=>print(error));
  }

  static Future<FirebaseUser> handleLogIn(String email, String password) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password)
        .then((user)=>user)
        .catchError((Object error){print("email is null");});
  }

  FirebaseUser currentUser;

  static Future<String> createMountain() async {
    String accountKey = await _getAccountKey();

    var mountain = <String, dynamic>{
      'name' : '',
      'created': _getDateNow(),
    };

    DatabaseReference reference = FirebaseDatabase.instance
        .reference()
        .child("accounts")
        .child(accountKey)
        .child("mountains")
        .push();

    reference.set(mountain);

    return reference.key;
  }

  static Future<void> saveName(String mountainKey, String name) async {
    String accountKey = await _getAccountKey();

    return FirebaseDatabase.instance
        .reference()
        .child("accounts")
        .child(accountKey)
        .child("mountains")
        .child(mountainKey)
        .child('name')
        .set(name);
  }

  static Future<void> deleteMountainKey(String mountainKey) async {
    String accountKey = await _getAccountKey();

    return FirebaseDatabase.instance
        .reference()
        .child("accounts")
        .child(accountKey)
        .child("mountains")
        .child(mountainKey)
        //.child('name')
        .remove();
  }


  static Future<String> getMountainName(String mountainKey) async{
    String accountKey = await _getAccountKey();
    Completer<String> completer = new Completer<String>();

    FirebaseDatabase.instance
        .reference()
        .child("accounts")
        .child(accountKey)
        .child("mountains")
        .child(mountainKey)
        .child('name')
        .once()
        .then((DataSnapshot snapshot){
          String mountainName = snapshot.value;
          completer.complete(mountainName);
        });

    return completer.future;
  }

  static Future<Query> queryMountainName(String keyWord) async{
    String accountKey = await _getAccountKey();


    var ref = FirebaseDatabase.instance
        .reference()
        .child("accounts")
        .child(accountKey)
        .child("mountains")
        .orderByChild("name")
        .equalTo(keyWord);

    return ref;
  }

  static Future<StreamSubscription<Event>> getNameStream(String mountainKey,
      void  onData(String name)) async {
    String accountKey = await _getAccountKey();

    StreamSubscription<Event> subscription = FirebaseDatabase.instance
        .reference()
        .child("accounts")
        .child(accountKey)
        .child("mountains")
        .child(mountainKey)
        .child("name")
        .onValue
        .listen((Event event) {
      String name = event.snapshot.value as String;
      if (name == null) {
        name = "";
      }
      onData(name);
    });

    return subscription;
  }

  static Future<Query> queryMountains() async {
    String accountKey = await _getAccountKey();
    print("account key is: $accountKey");
    return FirebaseDatabase.instance
        .reference()
        .child("accounts")
        .child(accountKey)
        .child("mountains")
        .orderByChild("name");
  }

}

Future<String> _getAccountKey() async {
  return FirebaseAuth.instance.currentUser().then((user){return user.uid;}).catchError((error){print("uid is null");});
}

/// requires: intl: ^0.15.2
String _getDateNow() {
  var now = new DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
  return formatter.format(now);
}

