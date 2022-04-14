// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:taxi_fare_comparision_application/main.dart';
import 'package:taxi_fare_comparision_application/pages/register.dart';
import 'package:taxi_fare_comparision_application/widgets/dialog.dart';
import 'package:taxi_fare_comparision_application/widgets/navigation.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(50.0)),
                    color: Colors.black87),
                child: Stack(children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width * 0.3,
                        70.0,
                        0.0,
                        0.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 60.0,
                          backgroundImage:
                              AssetImage('assets/images/logo1.png'),
                        ),
                        SizedBox(height: 15.0),
                        Text('SIGN IN',
                            style: TextStyle(
                              fontFamily: 'Capriola',
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: Colors.white,
                            )),
                        SizedBox(height: 10.0)
                      ],
                    ),
                  )
                ])),
            Container(
                padding: EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      title: TextFormField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            hintText: 'Enter your email',
                            labelStyle: TextStyle(
                              fontFamily: '',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    ListTile(
                      leading: Icon(
                        Icons.lock,
                        color: Colors.black,
                      ),
                      title: TextFormField(
                        controller: password,
                        decoration: InputDecoration(
                            hintText: 'Enter password',
                            labelStyle: TextStyle(
                              fontFamily: '',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      alignment: Alignment(1.0, 0.0),
                      padding: EdgeInsets.only(top: 15.0, left: 20.0),
                      child: InkWell(
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: '',
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25.0),
                    GestureDetector(
                      onTap: () {
                        if (email.text.isEmpty) {
                          displayToast('Email cannot be empty', context);
                        } 
                        else if (!email.text.contains('@')) {
                          displayToast('Invalid Email', context);
                        }

                        if (password.text.isEmpty) {
                          displayToast('Password cannot be empty', context);
                        } 
                        else if (password.text.length < 5) {
                          displayToast('Invalid Password', context);
                        } 
                        else {
                          loginUser(context);
                        }
                      },
                      child: SizedBox(
                        height: 45.0,
                        width: 175.0,
                        child: Material(
                            //borderRadius: BorderRadius.circular(20.0),
                            //shadowColor: Colors.redAccent,
                            color: Colors.black54,
                            elevation: 3.0,
                            child: Center(
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Capriola'),
                              ),
                            )),
                      ),
                    ),
                    SizedBox(height: 40.0),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Don't have an account?",
                            style: TextStyle(fontSize: 18.0, fontFamily: ''),
                          ),
                          SizedBox(width: 5.0),
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(),
                              ),
                            ),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.black,
                                  fontFamily: '',
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ])
                  ],
                ))
          ],
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void loginUser(BuildContext context) async
  {
    showDialog(context: context, 
    barrierDismissible: false,
    builder: (BuildContext context)
    {
      return ProgressDialog(msg: "Logging User...",);
    }
    );

    final User? user = (
      await _firebaseAuth.signInWithEmailAndPassword
      (
        email: email.text, 
        password: password.text
      ).catchError((errormsg)
      {
        Navigator.pop(context);
        displayToast("Error: ${errormsg.toString()}", context);
      }
      )
    ).user;
    
    if( user != null)
    {
      usersReference.child(
        user.uid
      ).once().
      then((DataSnapshot snap)
      {
        if(snap.value != null)
        {
          Navigator.pushNamedAndRemoveUntil(context, Navigation.map, (route) => false);
          displayToast('Login Successfull', context);
        }
        else
        {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToast('No Record exist for this User, create an account', context);
        }
      });

      
      
    }
    else
    {
      // error
      Navigator.pop(context);
      displayToast('Login Failed', context);
    }
  }
}
