// ignore_for_file: unused_import, await_only_futures

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:taxi_fare_comparision_application/helpers/requests.dart';
import 'package:taxi_fare_comparision_application/models/address.dart';
import 'package:taxi_fare_comparision_application/models/direction.dart';
import 'package:taxi_fare_comparision_application/models/user.dart';
import 'package:taxi_fare_comparision_application/provider/appdata.dart';
import 'package:taxi_fare_comparision_application/secret.dart';

class Assistants
{
  static Future<String> reverseGeocodedAddress(Position position, BuildContext context) async
  {
    String address = '';
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

    var response = await Requests.getRequest(url);

    if(response != 'Failed')
    {
      address = response["results"][0]["formatted_address"];

      Address userAddress = Address();

      userAddress.latitude = position.latitude;
      userAddress.longitude = position.longitude;
      userAddress.formattedAddress = address;
      userAddress.placeName = 
        response["results"][0]["address_components"][0]['long_name'] + ", " + response["results"][0]["address_components"][1]['long_name'] + ", " + response["results"][0]["address_components"][2]['long_name'];

      Provider.of<AppData>(context, listen: false).updatePickUp(userAddress);
    }

    return address;
  }

  static Future<Directions> getPolyLines(LatLng pickup, LatLng dropoff) async
  {
    String url = 'https://maps.googleapis.com/maps/api/directions/json?destination=${dropoff.latitude},${dropoff.longitude}&origin=${pickup.latitude},${pickup.longitude}&key=$apiKey';

    var response = await Requests.getRequest(url);
    Directions directions = Directions();

    if(response == 'Failed')
    {
      return directions;
    }

    directions.encodedPoints = response['routes'][0]['overview_polyline']['points'];
    directions.distanceText = response['routes'][0]['legs'][0]['distance']['text'];
    directions.durationText = response['routes'][0]['legs'][0]['duration']['text'];
    directions.distanceValue = response['routes'][0]['legs'][0]['distance']['value'];
    directions.durationValue = response['routes'][0]['legs'][0]['duration']['value'];
    directions.uberPrice = double.parse((43.5 + 2.1*(directions.durationValue!.toDouble() )/60 + 8.7*(directions.distanceValue!.toDouble())/1000).toStringAsFixed(2));
    directions.olaPrice = double.parse((50 + 2*(directions.durationValue!.toDouble() )/60 + 14*(directions.distanceValue!.toDouble())/1000).toStringAsFixed(2));
    directions.olaAutoPrice = double.parse((15 + 9*(directions.distanceValue!.toDouble())/1000).toStringAsFixed(2));
    directions.uberAutoPrice = double.parse((15 + 7*(directions.distanceValue!.toDouble())/1000).toStringAsFixed(2));
    return directions;
  }

  static void getUser() async
  {
    user = await FirebaseAuth.instance.currentUser;

    String userId = user!.uid;

    DatabaseReference ref = FirebaseDatabase.instance.reference().child('USERS').child(userId);

    ref.once().then(
      (DataSnapshot snap)
      {
        if(snap.value != null)
        {
          currentUser = Users.fromSnapshot(snap);
        }
      }
    );
  }


  static double randomNumbers(int num)
  {
    var random = Random();
    int number = random.nextInt(num);
    return number.toDouble();
  }
}