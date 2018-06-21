import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firstflutter/edit_mountain.dart';
import 'package:flutter/material.dart';
import 'package:firstflutter/database.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
      routes: <String, WidgetBuilder>{
        EditMountianPage.routeName: (context) => new EditMountianPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _LoginData {
  String email = '';
  String password = '';
}

class _MyHomePageState extends State<MyHomePage> {
  Query _query;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();


  @override
  void initState() {
    Database.queryMountains().then((Query query) {
      setState(() {
        _query = query;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = new ListView(
      children: <Widget>[
        new ListTile(
          title: new Text("The list is empty..."),
        ),
      ],
    );
    final Size screenSize = MediaQuery.of(context).size;


    if (_query != null) {
      body = new TabBarView(children: <Widget>[
        new FirebaseAnimatedList(
          query: _query,
          itemBuilder: (
            BuildContext context,
            DataSnapshot snapshot,
            Animation<double> animation,
            int index,
          ) {
            String mountainKey = snapshot.key;
            Map map = snapshot.value;
            String name = map['name'] as String;
            return new Column(
              children: <Widget>[
                new ListTile(
                  title: new Text('$name'),
                  onTap: () {
                    _edit(mountainKey);
                  },
                ),
                new Divider(
                  height: 2.0,
                ),
              ],
            );
          },
        ),
        new Container(
            padding: new EdgeInsets.all(20.0),
            child: new Form(
              key: this._formKey,
              child: new ListView(
                children: <Widget>[
                  new TextFormField(
                      keyboardType: TextInputType.emailAddress, // Use email input type for emails.
                      decoration: new InputDecoration(
                          hintText: 'you@example.com',
                          labelText: 'E-mail Address'
                      )
                  ),
                  new TextFormField(
                      obscureText: true, // Use secure text for passwords.
                      decoration: new InputDecoration(
                          hintText: 'Password',
                          labelText: 'Enter your password'
                      )
                  ),
                  new Container(
                    width: screenSize.width,
                    child: new RaisedButton(
                      child: new Text(
                        'Login',
                        style: new TextStyle(
                            color: Colors.white
                        ),
                      ),
                      onPressed: () => null,
                      color: Colors.blue,
                    ),
                    margin: new EdgeInsets.only(
                        top: 20.0
                    ),
                  )
                ],
              ),
            )
        ),
      ]);
    }

    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text("Home"),
          bottom: new TabBar(
            tabs: <Widget>[
              new Tab(text: "First Tab"),
              new Tab(text: "Second Tab"),
            ],
          ),
        ),
        body: body,
        floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.add),
          onPressed: () {
            _createMountain();
            _filpState("Aircon_On", true);
          },
        ),
      ),
    );
  }

  void _createMountain() {
    Database.createMountain().then((String mountainKey) {
      _edit(mountainKey);
    });
  }

  void _edit(String mountainKey) {
    var route = new MaterialPageRoute(
      builder: (context) => new EditMountianPage(mountainKey: mountainKey),
    );
    Navigator.of(context).push(route);
  }

  Future<String> _getAccountKey() async {
    return '12345678';
  }

  Future<void> _filpState(String devices, bool state) async {
    String accountKey = await _getAccountKey();
    return FirebaseDatabase.instance
        .reference()
        .child("accounts")
        .child(accountKey)
        .child("myButtons")
        .child(devices)
        .set(state);
  }

  void _consoleShowsQuery() {
    Database.queryMountainName("apple").then((result) {
      result.onValue.listen((event) {
        Map matchedName = event.snapshot.value as Map;
        print("matched name: ${matchedName.values}");
      });
    });
  }


  Future<FirebaseUser> _handleSignIn(String username, String password){
    Future<FirebaseUser> newUser= FirebaseAuth.instance.createUserWithEmailAndPassword(email: username, password: password)
        .then((user){print("user created: $user");})
        .catchError((Object error)=>print(error));
  }

}

