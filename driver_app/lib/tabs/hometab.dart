// ignore_for_file: prefer_const_constructors, file_names, unused_import, prefer_final_fields, avoid_print, prefer_const_literals_to_create_immutables, import_of_legacy_library_into_null_safe, await_only_futures, unnecessary_null_comparison

import 'dart:async';
import 'package:driver_app/helpers/assistants.dart';
import 'package:driver_app/main.dart';
import 'package:driver_app/pages/register.dart';
import 'package:driver_app/provider/appdata.dart';
import 'package:driver_app/secret.dart';
import 'package:driver_app/widgets/pushnotification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    super.initState();
    
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      RemoteNotification notification = msg.notification as RemoteNotification;
      AndroidNotification android = msg.notification?.android as AndroidNotification;

      if(notification != null && android != null)
      {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            )
          )
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      print('A new onMessageOpend event was published');
      RemoteNotification notification = msg.notification as RemoteNotification;
      AndroidNotification android = msg.notification?.android as AndroidNotification;

      if(notification != null && android != null)
      {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title as String),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body as String)],
                  ),
                ),
              );
      }
        );
    }
  });
  }

  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _newController;

  late Position currentPosition;

  String status = 'Go Online';
  Color statusColor = Colors.red;
  Color driverStatus = Colors.black;
  bool driverAvailable = false;

  void pointUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng positionCoordinates = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = CameraPosition(
      target: positionCoordinates,
      zoom: 15,
    );
    _newController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String currentAddress =
        await Assistants.reverseGeocodedAddress(position, context);
    print(
        "Address :: ${Provider.of<AppData>(context, listen: false).userPickUp.placeName}");
    print('Address :: $currentAddress');
  }

  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.08832357078792),
    zoom: 15,
  );

  // @override
  // void initState() {
  //   super.initState();

  //   getCurrentDriverInfo();
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          GoogleMap(
            // padding: EdgeInsets.only(
            //   top: MediaQuery.of(context).size.height * 0.19,
            // ),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              _newController = controller;
              pointUserLocation();
            },
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.20,
            width: double.infinity,
            color: Colors.black54,
          ),
          Positioned(
            top: 60.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      if(driverAvailable != true)
                      {
                        
                        makeDriverOnline();
                        getLiveLocation();

                        setState(() {
                          status = 'Go Offline';
                          statusColor = Colors.green;
                          driverStatus = Colors.white;
                          driverAvailable = true;
                        });

                        displayToast('You are Online Now', context);
                      }
                      else
                      {
                        Geofire.removeLocation(currentDriver!.uid);
                        tripReference.onDisconnect();
                        tripReference.remove();

                        setState(() {
                          status = 'Go Online';
                          statusColor = Colors.red;
                          driverStatus = Colors.white;
                          driverAvailable = false;
                        });
                        displayToast('You are Offline Now', context);
                      }
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.92,
                        color: statusColor,
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: driverStatus,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.phone_android_outlined,
                                color: driverStatus,
                                size: 26.0,
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void makeDriverOnline() async
  {
    Position position = await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    Geofire.initialize("AVAILABLEDRIVERS");
    Geofire.setLocation(currentDriver!.uid, currentPosition.latitude, currentPosition.longitude);

    tripReference.onValue.listen((event) {
      
    });
  }

  void getLiveLocation()
  {
    homeTab = Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if(driverAvailable == true)
      {
        Geofire.setLocation(currentDriver!.uid, position.latitude, position.longitude);
      }
      LatLng latlng = LatLng(position.latitude, position.longitude);
      _newController.animateCamera(CameraUpdate.newLatLng(latlng));
    });
  }

  // void getCurrentDriverInfo() async
  // {
  //   currentDriver = await FirebaseAuth.instance.currentUser;
  //   PushNotification pushNotification = PushNotification();

  //   pushNotification.initialize();
  //   pushNotification.getToken();
  // }
}
