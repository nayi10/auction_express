import 'package:auction_express/main.dart';
import 'package:auction_express/views/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication extends StatefulWidget {
  Authentication({Key? key}) : super(key: key);

  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isObscure = true;
  bool _isProgress = false;
  String? _error;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 50.0),
              ),
              if (_isProgress)
                Container(
                  margin: EdgeInsets.only(top: 60.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation(Colors.blue),
                    ),
                  ),
                ),
              SizedBox(height: 30.0),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (_error != null && !_isProgress)
                            Container(
                              child: Text(
                                _error ?? "",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 17),
                                softWrap: true,
                              ),
                              margin: EdgeInsets.symmetric(vertical: 15.0),
                            ),
                          if (!_isLogin)
                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                  labelText: "Your Name",
                                  hintText: "Your name..."),
                              textInputAction: TextInputAction.next,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Please provide your name";
                                } else if (value.trim().characters.length < 3) {
                                  return "Not a valid name";
                                }
                                return null;
                              },
                            ),
                          SizedBox(height: 15.0),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                labelText: "Email", hintText: "Email Address"),
                            textInputAction: TextInputAction.next,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "You must provide an email address";
                              } else if (!value.contains("@") ||
                                  !value.contains('.')) {
                                return "Invalid email address";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15.0),
                          TextFormField(
                            controller: _passwordController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                labelText: "Password",
                                suffix: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                  icon: Icon(_isObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                )),
                            obscureText: _isObscure,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Password is required";
                              } else if (value.length < 8) {
                                return "Password must be longer than 7 characters.";
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          ElevatedButton(
                              onPressed: () => submitForm(),
                              child: Text(_isLogin ? "Login" : "Register")),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 15.0),
                            child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? "Not registered? Register"
                                    : "Already registered? Login")),
                          ),
                          TextButton.icon(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 2,
                                  padding: EdgeInsets.all(12.0)),
                              onPressed: () => signInWithGoogle(),
                              icon: Image(
                                image: AssetImage("assets/google.png"),
                                height: 20,
                                width: 20,
                                color: null,
                              ),
                              label: Text("Login with Google"))
                        ],
                      ))),
            ],
          ),
        ),
      ),
    );
  }

  submitForm() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      if (_isLogin) {
        login(email, password);
      } else {
        register(email, password);
      }
    }
  }

  void register(String email, String password) async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _isProgress = true;
    });
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await cred.user!.updateDisplayName(_nameController.text);
      createUserInFirebase(cred.user!);
      pref.setString('username', _nameController.text);
      setState(() {
        _isProgress = false;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          _isProgress = false;
          _error = 'The password provided is too weak.';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _isProgress = false;
          _error = 'An account already exists for that email.';
        });
      }
    } catch (e) {
      setState(() {
        _isProgress = false;
        _error = "An unknown error occurred: $e";
      });
    }
  }

  void login(String email, String password) async {
    setState(() {
      _isProgress = true;
    });
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      setState(() {
        _isProgress = false;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String err;
      if (e.code == 'user-not-found') {
        err = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        err = 'Wrong password provided.';
      } else {
        err = "An unknown error occurred. Try later";
      }
      setState(() {
        _isProgress = false;
        _error = err;
      });
    } catch (e) {
      setState(() {
        _isProgress = false;
        _error = 'An unknown error occurred. Try later';
      });
    }
  }

  createUserInFirebase(User user) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .get();

    if (result.docs.length == 0) {
      String name;
      if (user.displayName != null) {
        name = user.displayName!;
      } else if (_nameController.text.trim().isNotEmpty) {
        name = _nameController.text;
      } else {
        name = "New User";
      }

      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': user.email,
        'avatar': user.photoURL ?? "https://i.pravatar.cc/300",
        'id': user.uid
      });
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    setState(() {
      _isProgress = true;
    });
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    createUserInFirebase(userCredential.user!);
    setState(() {
      _isProgress = false;
    });
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Homepage()),
      (Route<dynamic> route) => false,
    );

    return userCredential;
  }
}
