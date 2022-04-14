// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_fare_comparision_application/pages/login.dart';
import 'package:taxi_fare_comparision_application/pages/mapscreen.dart';
import 'package:taxi_fare_comparision_application/pages/register.dart';
import 'package:taxi_fare_comparision_application/pages/searchdestination.dart';
import 'package:taxi_fare_comparision_application/pages/splash_page.dart';
import 'package:taxi_fare_comparision_application/provider/appdata.dart';
import 'package:taxi_fare_comparision_application/widgets/navigation.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TaxiApp());
}

DatabaseReference usersReference = FirebaseDatabase.instance.reference().child('USERS');
DatabaseReference driversReference = FirebaseDatabase.instance.reference().child('DRIVERS');

class TaxiApp extends StatelessWidget {
  const TaxiApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'TaxiFare Comparision App',
        home: SplashPage(),
        debugShowCheckedModeBanner: false,
        routes: {
            Navigation.splash: (context) => SplashPage(),
            Navigation.login: (context) => LoginPage(),
            Navigation.register: (context) => RegisterPage(),
            Navigation.map: (context) => MapScreen(),
            Navigation.searchDestination: (context) => SearchDestination(),
          },
      ),
    );
  }
}