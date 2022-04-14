// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taxi_fare_comparision_application/main.dart';
import 'package:taxi_fare_comparision_application/pages/login.dart';
import 'package:taxi_fare_comparision_application/widgets/dialog.dart';
import 'package:taxi_fare_comparision_application/widgets/navigation.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController mobile = TextEditingController();

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
                        Text('SIGN UP',
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
                padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      title: TextFormField(
                        controller: name,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            hintText: 'Enter your Name',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey))),
                      ),
                    ),
                    SizedBox(height: 4.0),
                    ListTile(
                      leading: Icon(
                        Icons.phone,
                        color: Colors.black,
                      ),
                      title: TextFormField(
                        controller: mobile,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            hintText: 'Enter your phone number',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey))),
                      ),
                    ),
                    SizedBox(height: 4.0),
                    ListTile(
                      leading: Icon(
                        Icons.mail,
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
                                borderSide: BorderSide(color: Colors.grey))),
                      ),
                    ),
                    SizedBox(height: 4.0),
                    ListTile(
                      leading: Icon(
                        Icons.vpn_key,
                        color: Colors.black,
                      ),
                      title: TextFormField(
                        controller: password,
                        decoration: InputDecoration(
                            hintText: 'Enter Password',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey))),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    ListTile(
                      leading: Icon(
                        Icons.lock,
                        color: Colors.black,
                      ),
                      title: TextFormField(
                        controller: confirmPassword,
                        decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black))),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 14.0),
                    SizedBox(
                      height: 45.0,
                      width: 175.0,
                      child: Material(
                          //borderRadius: BorderRadius.circular(20.0),
                          //shadowColor: Colors.redAccent,
                          color: Colors.black54,
                          elevation: 3.0,
                          child: GestureDetector(
                              onTap: () {
                                  if(name.text.isEmpty)
                                  {
                                    displayToast('Name cannot be empty', context);
                                  }
                                  else if (name.text.length < 4)
                                  {
                                    displayToast('Name cannot be less than four letters', context);
                                  }

                                  if(email.text.isEmpty)
                                  {
                                    displayToast('Email cannot be empty', context);
                                  }
                                  else if(!email.text.contains('@'))
                                  {
                                    displayToast('Invalid Email', context);
                                  }

                                  if(mobile.text.isEmpty)
                                  {
                                    displayToast('Mobile cannot be empty', context);
                                  }
                                  else if(mobile.text.length != 10)
                                  {
                                    displayToast('Invalid Mobile', context);
                                  }

                                  if(password.text.isEmpty)
                                  {
                                    displayToast('Password cannot be empty', context);
                                  }
                                  else if(password.text.length < 5)
                                  {
                                    displayToast('Password cannot be less than 5 letters', context);
                                  }

                                  if(confirmPassword.text.isEmpty)
                                  {
                                    displayToast('Confirm Password cannot be empty', context);
                                  }
                                  else if(password.text != confirmPassword.text)
                                  {
                                    displayToast('Passwords do not match', context);
                                  }

                                  else
                                  {
                                    registerNewUser(context);
                                  }
                              },
                              child: Center(
                                child: Text(
                                  'REGISTER',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Capriola'),
                                ),
                              ))),
                    ),
                    SizedBox(height: 15.0),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Already have an account?",
                            style: TextStyle(fontSize: 18.0, fontFamily: ''),
                          ),
                          SizedBox(width: 5.0),
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.black,
                                  fontFamily: '',
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ]),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void registerNewUser(BuildContext context) async
  {
    showDialog(context: context, 
    barrierDismissible: false,
    builder: (BuildContext context)
    {
      return ProgressDialog(msg: "Registering User...",);
    }
    );
    
    final User? user = (
      await _firebaseAuth.createUserWithEmailAndPassword
      (
        email: email.text, 
        password: password.text
      ).catchError((errormsg)
      {
        Navigator.pop(context);
        displayToast("Error: ${errormsg.toString()}", context);
      })
      ).user;
    
    if( user != null)
    {
      // save info to database
      
      Map userData = {
        'Name': name.text.trim(),
        'Email': email.text.trim(),
        'Mobile': mobile.text.trim(),
        // 'Password': password.text
      };

      usersReference.child(
        user.uid
      ).set(userData);

      displayToast('User Creation successfull', context);
      Navigator.pushNamedAndRemoveUntil(context, Navigation.map, (route) => false);
    }
    else
    {
      // error
      Navigator.pop(context);
      displayToast('User not created', context);
    }
  }
}

void displayToast(msg, BuildContext context)
  {
    Fluttertoast.showToast(msg: msg);
  }