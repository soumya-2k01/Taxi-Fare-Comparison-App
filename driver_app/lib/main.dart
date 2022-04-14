// ignore_for_file: prefer_const_constructors, import_of_legacy_library_into_null_safe, avoid_print

import 'package:driver_app/pages/carinfo.dart';
import 'package:driver_app/secret.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:driver_app/pages/login.dart';
import 'package:driver_app/pages/mapscreen.dart';
import 'package:driver_app/pages/register.dart';
import 'package:driver_app/pages/searchdestination.dart';
import 'package:driver_app/pages/splash_page.dart';
import 'package:driver_app/provider/appdata.dart';
import 'package:driver_app/widgets/navigation.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance-channel',
  'High Importnace Notifications',
  description: 'This channel is used for important notifications',
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage msg) async
{
  await Firebase.initializeApp();
  print('A Msg showed up $msg');
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  
  currentDriver = FirebaseAuth.instance.currentUser;
  runApp(TaxiApp());
}

DatabaseReference usersReference = FirebaseDatabase.instance.reference().child('USERS');
DatabaseReference driverReference = FirebaseDatabase.instance.reference().child('DRIVERS');
DatabaseReference tripReference = FirebaseDatabase.instance.reference().child('DRIVERS').child(currentDriver!.uid).child('NEWRIDE');

class TaxiApp extends StatelessWidget {
  const TaxiApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Drivers App',
        home: SplashPage(),
        debugShowCheckedModeBanner: false,
        routes: {
            Navigation.splash: (context) => SplashPage(),
            Navigation.login: (context) => LoginPage(),
            Navigation.register: (context) => RegisterPage(),
            Navigation.map: (context) => MapScreen(),
            Navigation.searchDestination: (context) => SearchDestination(),
            Navigation.carinfo: (context) => CarInfo(),
          },
      ),
    );
  }
}