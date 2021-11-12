import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as lib_auth;
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:ui';
//import 'dart:typed_data';

final lib_auth.FirebaseAuth _auth = lib_auth.FirebaseAuth.instance;
FirebaseFirestore fire = FirebaseFirestore.instance;

//final lib_auth.FirebaseFirestore _firestore = FirebaseFirestore.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // ChangeNotifierProvider(
    //   create: (BuildContext context) => User('',''),
    //child:
    App(),
    //),
  );
  // FirebaseAuth.instance
  //     .authStateChanges()
  //     .listen(User? user) {
  //   if (user == null)
  //   {
  //     print('User is currently signed out!');
  //   } else {
  //     print('User is signed in!');
  //   }
  // };
  // runApp(App());
}

class User extends ChangeNotifier {
  String email = '';
  String password = '';

  User({this.email = '', this.password = ''});

  User.signed(this.email, this.password) {
    signIn(email, password);
    notifyListeners();
  }

  String getMail() {
    return email;
  }

  String getPassword() {
    return password;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      //FirebaseAuth _auth = FirebaseAuth.instance;

      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) => notifyListeners());
      return true;
    } catch (e) {
      notifyListeners();
      return false;
    }
  }
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

//login functions
enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }
//the sign in code using firebase

class MyApp extends StatelessWidget with ChangeNotifier {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          primaryColor: Colors.deepPurple,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple, //primary color is purple
            foregroundColor: Colors.white,
          ),
        ),
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => User(),
            )
          ],
          child: RandomWords(),
        )

        //   home: StreamBuilder<User?>(
        // stream: _auth.authStateChanges(),
        // builder: (_, snapshot) {
        // final isSignedIn = snapshot.data != null;
        // return isSignedIn ? HomePage() : RandomWords();
        // },
        // ),
        //   //RandomWords(),
        );
  }
}

// class MyLogin extends StatefulWidget {
//   const MyLogin({Key? key}) : super(key: key);
//
//   @override
//   _MyLoginState createState() => _MyLoginState();
// }

//login screen

class LoadLogin extends StatefulWidget {
  const LoadLogin({Key? key}) : super(key: key);

  @override
  _LoadLoginState createState() => _LoadLoginState();
}

//the loading screen
class _LoadLoginState extends State<LoadLogin> with ChangeNotifier {
  // Future<bool> signIn(String email, String password) async {
  //   try {
  //     FirebaseAuth _auth = FirebaseAuth.instance;
  //
  //     Status _status = Status.Authenticating;
  //     notifyListeners();
  //     await _auth.signInWithEmailAndPassword(email: email, password: password);
  //     return true;
  //   } catch (e) {
  //     Status _status = Status.Unauthenticated;
  //     notifyListeners();
  //     return false;
  //   }
  // }
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return loading();
  }

  FutureBuilder<FirebaseApp> loading() {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: SnackBar(
                      content:
                          Text('There was an error logging into the app'))));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          //_auth.currentUser; //is null here

          return RandomWords();
        }
        return Center(
            child: LinearProgressIndicator(
          value: null,
        ));
      },
    );
  }
}

//         (
//             Column(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 TextButton(onPressed: ()
//                 {//ScaffoldMessenger.of(context).showSnackBar(snackBar);
//                   LoadLogin;
//                 },
//                   child:const Text( 'Login'),),
//                 TextButton(onPressed: ()
//                 {ScaffoldMessenger.of(context).showSnackBar(snackBar);},
//                   child:const Text( 'Login'),),
//                 TextButton(onPressed: ()
//                 {ScaffoldMessenger.of(context).showSnackBar(snackBar);},
//                   child:const Text( 'Login'),),
//               ],
//             )
//
//         )
//
//     );
//
//   }
// }

class RandomWords extends StatefulWidget {
  //this isn't in part 1
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

//.then((docReference) => docReference.get());
class _RandomWordsState extends State<RandomWords> with ChangeNotifier {
  bool valid = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<lib_auth.User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          lib_auth.User? u = _auth.currentUser;

          if (u == null) //user not signed in
          {
            return Builder(builder: (context) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Startup Name Generator',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.star),
                      color: Colors.white,
                      onPressed: _pushSaved,
                      tooltip: 'Saved Suggestions',
                    ),
                    IconButton(
                      onPressed: _pushLogin,
                      icon: const Icon(Icons.login),
                      color: Colors.white,
                    ),

                    //logout button
                    //IconButton(onPressed: _pushLogin, icon: const Icon(Icons.exit_to_app),color: Colors.white,)
                  ],
                ),
                body: _buildSuggestions(),
              );
            });
          } else //user signed in
          {
            return Builder(builder: (context) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Startup Name Generator',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.star),
                      color: Colors.white,
                      onPressed: _pushSaved,
                      tooltip: 'Saved Suggestions',
                    ),
                    //logout button
                    IconButton(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Successfully logged out')));
                        await lib_auth.FirebaseAuth.instance.signOut();
                        notifyListeners();
                      },
                      icon: const Icon(Icons.exit_to_app),
                      color: Colors.white,
                    ),
                  ],
                ),
                body: buildSnappingSheet(),
              );
            });
          }
        } //bulder of stream builder
        );
  }

  late SnappingSheetController _controller;

  // TextEditingController _textcontrol=TextEditingController();

  @override
  void initState() {
    //
    _controller = SnappingSheetController();
  //  controller=TextEditingController();
    //_textcontrol= TextEditingController();
    super.initState();
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection

      var collectionRef = fire.collection('users');

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      //not suppose to et here
      throw e;
    }
  }

  Future<void> addUser(String? email) async {
//create document with user id as document id
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    if (!await checkIfDocExists(_auth.currentUser!.uid)) {
      Map<WordPair, WordPair> saveInCloud = Map();
      try {
        await users
            .doc(_auth.currentUser!.uid)
            .set({'email': email, 'saved': saveInCloud});
      } catch (e) {
        //print(e);
      }
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      //FirebaseAuth _auth = FirebaseAuth.instance;


      //assume user is in database
      // _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await addUser(email);
      notifyListeners();

      return true;
    } catch (e) {
      notifyListeners();
      return false;
    }
  }

  //final _suggestions = <WordPair>[];
  final _suggestions = <WordPair>[];

  //for dry
  // final _suggestions = generateWordPairs().take(10).toList();
  //var _saved = <WordPair>{};
  var _saved = <WordPair>{};

  //final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);

  void _pushSaved() async {
    await getSaved();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          //getSaved();
          //  getSavedInNav();
          final tiles = _saved.map(
            (pair) {
              String p = pair.asPascalCase;
              return Dismissible(
                  key: ValueKey(pair),
                  confirmDismiss: (DismissDirection dismissDirection) async {
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Delete Suggestion'),
                            content: Text(
                                'Are you sure you want to delete $pair from your saved suggestions'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    //remove from suggstions list
                                    Navigator.of(context).pop(true);
                                    notifyListeners();
                                  },
                                  child: const Text('Yes')),
                              TextButton(
                                  onPressed: () {
                                    //don't remove from suggestions list
                                    Navigator.of(context).pop(false);
                                  },
                                  child: const Text('No'))
                            ],
                          );
                        },
                        barrierDismissible: true);

                    //return false;
                  },
                  background: Container(
                    color: Colors.deepPurple,
                    child: Row(
                      children: [
                        Icon(
                          (Icons.delete),
                          color: Colors.white,
                        ),
                        Text(
                          'Delete Suggestion',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (direction) {
                    // Remove the item from the data source.
                    setState(() {
                      _saved.remove(pair);
                      updateSaved(_saved);
                      notifyListeners();
                    });
                  },
                  child: ListTile(
                    title: Text(
                      p,
                      style: _biggerFont,
                    ),
                  ));
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return streamBuilder(divided);
        },
      ),
    );
  }

  StreamBuilder<lib_auth.User?> streamBuilder(List<Widget> divided) {
    return savedSuggestions(divided);
  }

  StreamBuilder<lib_auth.User?> savedSuggestions(List<Widget> divided) {
    return StreamBuilder(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          return FutureBuilder(
              future: getSaved(),
              builder: (context, snapshot) {
                return Builder(builder: (context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text(
                        'Saved Suggestions',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    body: ListView(children: divided),
                  );
                });
              });
        });
  }

  void _pushLogin() {
    String password = '';
    String email = '';
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
//login screen
          return Login(email, password, context);
        },
      ),
    );
  }

  Future<bool> signUp(String email, password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await addUser(email);
      notifyListeners();
      // _auth.currentUser;
      return true;
    } catch (e) {
      notifyListeners();
      return false;
    }
  }

  //final _formkey=GlobalKey<FormState>();
  // bool validateTextField(String userInput,String password)
  // {
  //   if (userInput.isEmpty || userInput==password)
  //   {
  //     setState(() {
  //       valid = true;
  //     });
  //     return false;
  //   }
  //   setState(() {
  //     valid = false;
  //   });
  //   return true;
  // }
  Scaffold Login(String email, String password, BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: (Column(
        children: [
          Text('Welcome to startup name generator,please log in below'),
          SizedBox(height: 40),
          TextField(
              onChanged: (val) {
                email = val;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              )),
          SizedBox(height: 40),
          TextField(
              onChanged: (val) {
                password = val;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              )),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                        create: (BuildContext context) =>
                            User.signed(email, password),
                        child: FutureBuilder(
                          future: signIn(email, password),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Scaffold(
                                  body: Center(
                                      child: SnackBar(
                                          content: Text(
                                              'There was an error logging into the app'))));
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              //_auth.currentUser; //is null here

                              //return ChangeNotifierProxyProvider(create: create, update: update,child: RandomWords(),);
                              return RandomWords();
                            }
                            return Center(
                                child: LinearProgressIndicator(
                              value: null,
                            ));
                          },
                        ),
                      )));
              notifyListeners();
            }, //on pressed
            style: ElevatedButton.styleFrom(
              primary: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 15.0,
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: const Text('Log in'),
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              // final GlobalKey<FormState> _formkey=GlobalKey<FormState>();
              String confirmPassword = '';
              // bool valid=true;
              //TODO: errortext problem
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return modalsheet(context, confirmPassword, password, email);
                  });
            }, //on pressed
            style: ElevatedButton.styleFrom(
              primary: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              elevation: 15.0,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: const Text(
                'New user? Click to sign up',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      )), //body
    );
  }
 TextEditingController controller=TextEditingController();
  Container modalsheet(BuildContext context, String confirmPassword, String password, String email) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Text(
            'Please confirm your password below',
            style: TextStyle(fontSize: 10),
          ),

          TextFormField(

            onSaved: (value) => confirmPassword = value!,
            controller: controller,
            decoration: InputDecoration(
                labelText: 'password',

                errorText:
                    !valid ? 'Passwords must match' : null),
            onChanged: (val) {
              confirmPassword = val;
            },
          ),
          ElevatedButton(
              onPressed: () async {

                setState(() {
                  confirmPassword == password && controller.text.isNotEmpty
                      ? valid = true
                      : valid = false;
                });
                if (valid)
                //sign in
                {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) =>
                              ChangeNotifierProvider(
                                create:
                                    (BuildContext context) =>
                                        User.signed(
                                            email, password),
                                child: FutureBuilder(
                                  future:
                                      signUp(email, password),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      //no need to handle error
                                      return Scaffold(
                                          body: Center(
                                              child: SnackBar(
                                                  content: Text(
                                                      'There was an error logging into the app'))));
                                    }
                                    if (snapshot
                                            .connectionState ==
                                        ConnectionState.done) {
                                      return RandomWords();
                                    }
                                    return Center(
                                        child:
                                            LinearProgressIndicator(
                                      value: null,
                                    ));
                                  },
                                ),
                              )));
                  // _auth.signInWithEmailAndPassword(email: email, password: password);
                }
                // notifyListeners();
              },
              child: Text('Confirm'))
        ],
      ),
    );
  }

  @override
  dispose() {
    //_controller.dispose();
    controller.dispose();
    //_textcontrol.dispose();
    super.dispose();
  }

  // Widget Blur() {
  //   return Stack(
  //     children: [
  //       RandomWords(),
  //       //blurred child
  //       BackdropFilter(
  //         filter: ImageFilter.blur(
  //           sigmaX: 8.0,
  //           sigmaY: 8.0,
  //         ),
  //       ),
  //       buildSnappingSheet()
  //       //non blurred stuff
  //     ],
  //   );
  // }
  bool open = false;
// Widget SnapWithBlur()
// {
//   if(open)
//     {
//       !open;
//       return Blur();
//
//     }
//   else
//     {
//       return buildSnappingSheet();
//     }
// }
  //TODO:add blur effect to snapsheet

  Widget buildSnappingSheet() {
    FirebaseStorage.instance.ref();
    return FutureBuilder(
        future: LoadProfile(),
        builder: (context, snapshot) {
          return SnappingSheet(
            controller: _controller,
            lockOverflowDrag: true,
            //we need to blur this
            child: _buildSuggestions(),
            grabbingHeight: 75,
            grabbing: Material(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (open) {

                      //closing the sheet
                      //unblur
                      _controller.snapToPosition(
                          SnappingPosition.factor(positionFactor: 0.05));
                      open = !open;
                    } else {
                      //opening the sheet
                      //blur
                      //Blur();
                      _controller.snapToPosition(
                          SnappingPosition.factor(positionFactor: 0.5));
                      open = !open;
                    }
                  });
                },
                child: Container(
                  height: MediaQuery.of(context).size.height / 10,
                  color: Colors.grey,
                  child: Row(
                    children: [
                      Text(
                        'Welcome back, ${_auth.currentUser!.email}',
                        style: TextStyle(fontSize: 10),
                      ),
                      Icon(Icons.keyboard_arrow_up),
                    ],
                  ),
                ),
              ),
            ),
            //persistent area

            sheetAbove: null,
            //but not this
            sheetBelow: SnappingSheetContent(
                child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Row(
                    children: [

                      FutureBuilder<NetworkImage>(
                          future: LoadProfile(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return CircleAvatar(
                                //default empty

                                foregroundImage:
                                    //ImageProvider(),
                                    snapshot.hasData
                                        ? snapshot.data
                                        : NetworkImage(''),
                                backgroundColor: Colors.white,
                                radius: 40,
                              );
                            }
                          }),
                      Column(
                        children: [
                          Text('${_auth.currentUser!.email}'),
                          ElevatedButton(
                              onPressed: () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles();

                                if (result != null) {
                                  File file = File(result.files.single.path!);
                                  String fileName = result.files.first.name;
                                  await FirebaseStorage.instance
                                      .ref(fileName)
                                      .putFile(file);
                                  final String downloadUrl =
                                      await FirebaseStorage.instance
                                          .ref(fileName)
                                          .getDownloadURL();

                                  await SaveProfile(downloadUrl);
                                } else {
                                  // User canceled the picker
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No image selected'),
                                    ),
                                  );
                                }
                              },
                              child: Text('Change Avatar'))
                        ],
                      )
                    ],
                  ),
                ],
              ),
            )),
          );
        });
  }

  Future<NetworkImage> LoadProfile() async {
    String res = '';
    if (await checkIfDocExists(_auth.currentUser!.uid)) {
      await fire
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          res = snapshot.data()!['image'] == null
              ? ''
              : snapshot.data()!['image'];
        }
      });
      //var ref = FirebaseStorage.instance.ref().child(res);
      // var ref = FirebaseStorage.instance.ref(res);
      //var url = res == '' ? '' : await ref.getDownloadURL();
      notifyListeners();
      return NetworkImage(res);
      //return url;
    }
    //return res;
    return NetworkImage('');
  }

  //assign profile image to user
  Future SaveProfile(String filename) async {
    if (await checkIfDocExists(_auth.currentUser!.uid)) {
      fire
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set({'image': filename}, SetOptions(merge: true));
    }
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }
          final int index = i ~/ 2;
          // If you've reached the end of the available word
          // pairings...
          //for dry exercise

          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Future<void> updateSaved(Set<WordPair> saved) async {
    bool isExist = await checkIfDocExists(_auth.currentUser!.uid);
    if (isExist) {
      Map<String, String> savedMap = Map.fromIterable(saved,
          key: (e) => e.toString(), value: (e) => e.first);

      fire
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'saved': savedMap});
    } else {
      addUser(_auth.currentUser!.email);
    }
    notifyListeners();
  }

  Future getSaved() async {
    if (_auth.currentUser != null) {
      await fire
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> res = snapshot.data()!['saved'];

          res.forEach((key, value) {
            String newkey = key.replaceFirst(value.toString(), "");
            _saved.add(WordPair(value, newkey));
            //  key.replaceFirst(value.toString(), '');
          });

          // res.forEach((key, value) {_saved.add(WordPair(value, key)); });
          // _saved.addAll();

          //_saved;
          notifyListeners();
        }
      });
    }
  }

  // void getSavedInNav() async {
  //   if (_auth.currentUser != null) {
  //     await fire
  //         .collection('users')
  //         .doc(_auth.currentUser!.uid)
  //         .get()
  //         .then((snapshot) {
  //       if (snapshot.exists) {
  //         Map<String, dynamic> res = snapshot.data()!['saved'];
  //
  //         res.forEach((key, value) {
  //           String newkey = key.replaceFirst(value.toString(), "");
  //           _saved.add(WordPair(value, newkey));
  //         });
  //
  //         notifyListeners();
  //       }
  //     });
  //   }
  // }

  // Future<void> _getSaved() async
  // {
  //
  //
  //
  //
  //  if(await checkIfDocExists(_auth.currentUser!.uid))
  //    {
  //      var docSnapshot= await fire.collection('users').doc(_auth.currentUser!.uid).get();
  //      Map<String, dynamic>? data = docSnapshot.data();
  //      Map<WordPair,WordPair> saved_map = data?['saved'];
  //      saved_map.forEach((k, v) => _saved.add(v));
  //
  //    }
  //
  // }
  // Stream<DocumentSnapshot> _getSaved() {
  //return fire.collection('users').doc(documentId).snapshots();
  // }
  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.star : Icons.star_border,
        color: alreadySaved ? Colors.deepPurple : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () async {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
        await updateSaved(_saved);
        notifyListeners();
      },
    );
  }
}
