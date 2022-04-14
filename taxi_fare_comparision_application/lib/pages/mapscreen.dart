// ignore_for_file: prefer_final_fields, unused_field, avoid_print, prefer_const_constructors, prefer_typing_uninitialized_variables, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, unused_import

import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:taxi_fare_comparision_application/helpers/assistants.dart';
import 'package:taxi_fare_comparision_application/helpers/geofireassistant.dart';
import 'package:taxi_fare_comparision_application/helpers/requests.dart';
import 'package:taxi_fare_comparision_application/main.dart';
import 'package:taxi_fare_comparision_application/models/direction.dart';
import 'package:taxi_fare_comparision_application/models/driver.dart';
import 'package:taxi_fare_comparision_application/models/nearbydrivers.dart';
import 'package:taxi_fare_comparision_application/pages/login.dart';
import 'package:taxi_fare_comparision_application/pages/searchdestination.dart';
import 'package:taxi_fare_comparision_application/provider/appdata.dart';
import 'package:taxi_fare_comparision_application/secret.dart';
import 'package:taxi_fare_comparision_application/widgets/dialog.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _newController;

  late Position currentPosition;

  String price = '';

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

    initGeoFire();
  }

  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.08832357078792),
    zoom: 15,
  );

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylineSet = {};
  List<Driver> driversList = [];

  Set<Marker> markers = {};
  Set<Circle> circles = {};

  double heightSearch = 300;
  double heightRides = 0;
  double maxRides = 0;

  Directions? tripDetails;
  var resObtain;

  var requestCab;

  bool driverKeyLoad = false;

  BitmapDescriptor? nearbyIcon;

  late DatabaseReference ridesRequest;

  @override
  void initState() {
    super.initState();

    Assistants.getUser();
  }

  void saveRideRequest() {
    ridesRequest =
        FirebaseDatabase.instance.reference().child("RIDE REQUESTS").push();

    var pickUp = Provider.of<AppData>(context, listen: false).userPickUp;
    var dropOff = Provider.of<AppData>(context, listen: false).userDropOff;

    Map pickUpLoc = {
      'latitude': pickUp.latitude.toString(),
      'longitude': pickUp.longitude.toString(),
    };

    Map dropOffLoc = {
      'latitude': dropOff.latitude.toString(),
      'longitude': dropOff.longitude.toString(),
    };

    Map rideInfo = {
      'driver_id': "waiting",
      'payment_method': 'cash',
      'pickUp': pickUpLoc,
      'dropOff': dropOffLoc,
      'created_at': DateTime.now().toString(),
      'rider_name': currentUser!.name,
      'rider_phone': currentUser!.phone,
      'pickUp_address': pickUp.placeName,
      'dropOff_address': dropOff.placeName,
    };

    ridesRequest.set(rideInfo);
  }

  void cancelRideRequest() {
    ridesRequest.remove();
  }

  @override
  Widget build(BuildContext context) {
    createIcon();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.21),
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
                setState(() {
                  heightSearch = MediaQuery.of(context).size.height * 0.21;
                });
              },
              polylines: polylineSet,
              markers: markers,
              circles: circles,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: (resObtain != null)
                  ? priceDetailsTab()
                  : searchDestinationTab(),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: (resObtain != null)
                  ? GestureDetector(
                      onTap: () {
                        resObtain = null;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 10.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 40,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 10.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          size: 30,
                        ),
                      ),
                    ),
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: (requestCab == true) ? requestRideTab() : Container(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getPolyLine() async {
    var pickUp = Provider.of<AppData>(context, listen: false).userPickUp;
    var dropOff = Provider.of<AppData>(context, listen: false).userDropOff;

    var pickUpCoordinates =
        LatLng(pickUp.latitude as double, pickUp.longitude as double);
    var dropOffCoordinates =
        LatLng(dropOff.latitude as double, dropOff.longitude as double);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              msg: 'Please Wait...',
            ));

    var details =
        await Assistants.getPolyLines(pickUpCoordinates, dropOffCoordinates);

    Navigator.pop(context);

    setState(() {
      tripDetails = details;
    });

    print('Encoded Points ::');
    print(details.encodedPoints);

    PolylinePoints points = PolylinePoints();
    List<PointLatLng> decodedPoints =
        points.decodePolyline(details.encodedPoints as String);

    polylineCoordinates.clear();

    if (decodedPoints.isNotEmpty) {
      for (var pointLatLng in decodedPoints) {
        polylineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.red.shade300,
        polylineId: PolylineId('PolylineID'),
        jointType: JointType.round,
        points: polylineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;

    if (pickUpCoordinates.latitude > dropOffCoordinates.latitude &&
        pickUpCoordinates.longitude > dropOffCoordinates.longitude) {
      latLngBounds = LatLngBounds(
        southwest: dropOffCoordinates,
        northeast: pickUpCoordinates,
      );
    } else if (pickUpCoordinates.latitude > dropOffCoordinates.latitude) {
      latLngBounds = LatLngBounds(
        southwest:
            LatLng(dropOffCoordinates.latitude, pickUpCoordinates.longitude),
        northeast:
            LatLng(pickUpCoordinates.latitude, dropOffCoordinates.longitude),
      );
    } else if (pickUpCoordinates.longitude > dropOffCoordinates.longitude) {
      latLngBounds = LatLngBounds(
        southwest:
            LatLng(pickUpCoordinates.latitude, dropOffCoordinates.longitude),
        northeast:
            LatLng(dropOffCoordinates.latitude, pickUpCoordinates.longitude),
      );
    } else {
      latLngBounds = LatLngBounds(
        southwest: pickUpCoordinates,
        northeast: dropOffCoordinates,
      );
    }

    _newController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickUp.placeName, snippet: 'My Location'),
      position: pickUpCoordinates,
      markerId: MarkerId('PickUpID'),
    );

    Marker dropOffMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow:
          InfoWindow(title: dropOff.placeName, snippet: 'DropOff Location'),
      position: dropOffCoordinates,
      markerId: MarkerId('DropOffID'),
    );

    setState(() {
      markers.add(pickUpMarker);
      markers.add(dropOffMarker);
    });

    Circle pickUpCircle = Circle(
      fillColor: Colors.greenAccent,
      center: pickUpCoordinates,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.green,
      circleId: CircleId('PickUpID'),
    );

    Circle dropOffCircle = Circle(
      fillColor: Colors.lightBlueAccent,
      center: dropOffCoordinates,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blue,
      circleId: CircleId('DropOffID'),
    );

    setState(() {
      circles.add(pickUpCircle);
      circles.add(dropOffCircle);
    });
  }

  Widget requestRideTab() {
    const colorizeColors = [
      Colors.green,
      Colors.purple,
      Colors.pink,
      Colors.blue,
      Colors.yellow,
      Colors.red,
    ];

    const colorizeTextStyle = TextStyle(
      fontSize: 55.0,
      fontFamily: 'Signatra',
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              spreadRadius: 0.5,
              blurRadius: 16,
              color: Colors.black,
              offset: Offset(0.7, 0.7)),
        ],
      ),
      // height: 150,
      child: Column(
        children: [
          SizedBox(
            height: 12,
          ),
          SizedBox(
            width: double.infinity,
            child: AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'Requesting Ride...',
                  textStyle: colorizeTextStyle,
                  colors: colorizeColors,
                  textAlign: TextAlign.center,
                ),
                ColorizeAnimatedText(
                  'Please Wait...',
                  textStyle: colorizeTextStyle,
                  colors: colorizeColors,
                  textAlign: TextAlign.center,
                ),
                ColorizeAnimatedText(
                  'Finding Driver...',
                  textStyle: colorizeTextStyle,
                  colors: colorizeColors,
                  textAlign: TextAlign.center,
                ),
              ],
              onTap: () {
                print("Tap Event");
              },
            ),
          ),
          SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: () {
              cancelRideRequest();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(),
                ),
              );
            },
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 4.0, color: Colors.black),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 20.0,
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          SizedBox(
            width: double.infinity,
            child: Text(
              'Cancel Ride',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget priceDetailsTab() {
    return Container(
      child: AnimatedSize(
        curve: Curves.bounceIn,
        duration: Duration(milliseconds: 160),
        child: SlidingUpPanel(
          maxHeight: maxRides,
          minHeight: heightRides,
          panel: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(20),
              child: AppBar(
                title: Icon(Icons.keyboard_arrow_up_rounded),
                centerTitle: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey.shade700,
                elevation: 0,
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 17.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 3.0,
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            left: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            right: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Container(
                            color: Colors.yellow,
                            child: Row(
                              children: [
                                // Image.asset(
                                //   'assets/images/auto.png',
                                //   height: 70.0,
                                //   width: 80.0,
                                // ),
                                Icon(
                                  Icons.electric_rickshaw_rounded,
                                  color: Colors.black,
                                  size: 70,
                                ),
                                SizedBox(
                                  width: 15.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Auto',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    Text(
                                      tripDetails!.distanceText as String,
                                      // '10km',
                                      // (distText != '')
                                      //     ? distText
                                      //     : '0 km',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(child: Container()),
                                Text(
                                  '(Ola)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Brand-Bold',
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${tripDetails!.olaAutoPrice.toString()} Rs',
                                  // '20rs',
                                  style: TextStyle(
                                    fontFamily: 'Brand-Bold',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 3.0,
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            left: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            right: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Container(
                            color: Colors.grey.shade200,
                            child: Row(
                              children: [
                                // Image.asset(
                                //   'assets/images/car_ios.png',
                                //   height: 70.0,
                                //   width: 80.0,
                                // ),
                                Icon(
                                  Icons.electric_rickshaw_rounded,
                                  color: Colors.black,
                                  size: 70,
                                ),
                                SizedBox(
                                  width: 15.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Auto',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    Text(
                                      tripDetails!.distanceText as String,
                                      // '10km',
                                      // (distText != '')
                                      //     ? distText
                                      //     : '0 km',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(child: Container()),
                                Text(
                                  '(Uber)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Brand-Bold',
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${tripDetails!.uberAutoPrice.toString()} Rs',
                                  // '20rs',
                                  style: TextStyle(
                                    fontFamily: 'Brand-Bold',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 3.0,
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            left: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            right: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Container(
                            color: Colors.grey.shade200,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/car_ios.png',
                                  height: 70.0,
                                  width: 80.0,
                                ),
                                SizedBox(
                                  width: 15.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mini',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    Text(
                                      tripDetails!.distanceText as String,
                                      // '10km',
                                      // (distText != '')
                                      //     ? distText
                                      //     : '0 km',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(child: Container()),
                                Text(
                                  '(Ola)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Brand-Bold',
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${tripDetails!.olaPrice.toString()} Rs',
                                  // '20rs',
                                  style: TextStyle(
                                    fontFamily: 'Brand-Bold',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 3.0,
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            left: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            right: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Container(
                            color: Colors.grey.shade200,
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/car_ios.png',
                                  height: 70.0,
                                  width: 80.0,
                                ),
                                SizedBox(
                                  width: 15.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'UberGo',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    Text(
                                      tripDetails!.distanceText as String,
                                      // '10km',
                                      // (distText != '')
                                      //     ? distText
                                      //     : '0 km',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(child: Container()),
                                Text(
                                  '(Uber)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Brand-Bold',
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${tripDetails!.uberPrice.toString()} Rs',
                                  // '20rs',
                                  style: TextStyle(
                                    fontFamily: 'Brand-Bold',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.moneyCheckAlt,
                            size: 18.0,
                            color: Colors.black54,
                          ),
                          SizedBox(
                            width: 16.0,
                          ),
                          Text(
                            'Cash',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black54,
                            size: 16.0,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          print('Requested');
                          setState(() {
                            requestCab = true;
                            heightRides = 0;
                            maxRides = 0;
                          });

                          saveRideRequest();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.92,
                          color: Colors.black,
                          child: Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Request Ride',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  FontAwesomeIcons.taxi,
                                  color: Colors.white,
                                  size: 26.0,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Container(),
        ),
      ),
    );
  }

  Widget searchDestinationTab() {
    return Container(
      child: AnimatedSize(
        curve: Curves.bounceIn,
        duration: Duration(milliseconds: 160),
        child: Container(
          height: heightSearch,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 16.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    var res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchDestination(),
                      ),
                    );
                    print(res);
                    if (res == 'obtainDirections') {
                      await getPolyLine();
                      setState(() {
                        resObtain = res;
                        heightSearch = 0;
                        heightRides = 150;
                        maxRides = 600;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.85,
                      decoration: BoxDecoration(
                        color: Colors.grey[350],
                        border: Border(
                          top: BorderSide(
                            style: BorderStyle.solid,
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                          left: BorderSide(
                            style: BorderStyle.solid,
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                          right: BorderSide(
                            style: BorderStyle.solid,
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                          bottom: BorderSide(
                            style: BorderStyle.solid,
                            color: Colors.grey.shade400,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Search Destination',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void initGeoFire() {
    Geofire.initialize("AVAILABLEDRIVERS");
    // comment
    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 15)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDrivers nearbyDrivers = NearbyDrivers();
            nearbyDrivers.key = map['key'];
            nearbyDrivers.latitude = map['latitude'];
            nearbyDrivers.longitude = map['longitude'];

            GeoFireAssistant.nearbyDriversList.add(nearbyDrivers);

            if (driverKeyLoad == true) {
              showDriver();
            }
            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeDriver(map['key']);
            showDriver();
            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            NearbyDrivers nearbyDrivers = NearbyDrivers();
            nearbyDrivers.key = map['key'];
            nearbyDrivers.latitude = map['latitude'];
            nearbyDrivers.longitude = map['longitude'];
            GeoFireAssistant.updateDriver(nearbyDrivers);
            showDriver();
            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            showDriver();
            break;
        }
      }

      setState(() {});
    });
    // comment
  }

  void showDriver() {
    setState(() {
      markers.clear();
    });

    Set<Marker> driverMarkers = {};

    for (NearbyDrivers driver in GeoFireAssistant.nearbyDriversList) {
      LatLng latlng =
          LatLng(driver.latitude as double, driver.longitude as double);

      Marker marker = Marker(
        markerId: MarkerId('Driver:${driver.key}'),
        position: latlng,
        icon: nearbyIcon as BitmapDescriptor,
        rotation: Assistants.randomNumbers(360),
      );

      Driver driverModel = Driver();
      driversReference
          .child(driver.key as String)
          .once()
          .then((DataSnapshot snap) {
        if (snap != null) {
          driverModel.carNo = snap.value['Car Details']['Number'];
          driverModel.key = driver.key;
          driverModel.carColor = snap.value['Car Details']['Colour'];
          driverModel.carModel = snap.value['Car Details']['Model'];
          driverModel.service = snap.value['Car Details']['ServiceProvider'];
        }
        // print('Data: ${snap.value['Car Details']}');
      });
      // print(driverModel.carModel);
      setState(() {
        driversList.add(driverModel);
      });

      print('Driver ready');
      driverMarkers.add(marker);
    }

    setState(() {
      markers = driverMarkers;
    });
  }

  void createIcon() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/car_ios.png")
          .then((value) {
        nearbyIcon = value;
      });
    }
  }
}
