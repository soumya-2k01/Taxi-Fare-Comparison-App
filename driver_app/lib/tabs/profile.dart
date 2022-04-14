// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers

import 'package:driver_app/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Container(
                  child: Icon(Icons.logout_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}