// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, unnecessary_null_comparison, import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:driver_app/helpers/requests.dart';
import 'package:driver_app/models/address.dart';
import 'package:driver_app/models/predictions.dart';
import 'package:driver_app/pages/mapscreen.dart';
import 'package:driver_app/provider/appdata.dart';
import 'package:driver_app/secret.dart';
import 'package:driver_app/widgets/dialog.dart';
import 'package:driver_app/widgets/divider.dart';

class SearchDestination extends StatefulWidget {
  const SearchDestination({Key? key}) : super(key: key);

  @override
  _SearchDestinationState createState() => _SearchDestinationState();
}

class _SearchDestinationState extends State<SearchDestination> {
  TextEditingController pickUpController = TextEditingController();
  TextEditingController dropOffController = TextEditingController();
  List<Predictions> places = [];

  @override
  Widget build(BuildContext context) {
    String pickUpAddress = '';
    if (Provider.of<AppData>(context).userPickUp != null) {
      pickUpAddress =
          Provider.of<AppData>(context).userPickUp.placeName as String;
    }
    pickUpController.text = pickUpAddress;

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade600,
                              blurRadius: 6,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7)),
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(),
                            ),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, top: 10.0),
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                // ignore: prefer_const_literals_to_create_immutables
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
                                Icons.arrow_left,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Container(
                            height: 45,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1.0),
                            ),
                            child: TextFormField(
                              controller: pickUpController,
                              decoration: InputDecoration(
                                hintText: 'PickUp',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                  left: 10.0,
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Container(
                            height: 45,
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1.0),
                            ),
                            child: TextFormField(
                              onChanged: (value) async {
                                findPlace(value);
                              },
                              controller: dropOffController,
                              decoration: InputDecoration(
                                hintText: 'Enter Destination',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 10.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  flex: 3,
                  child: (places.isNotEmpty)
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListView.separated(
                            padding: EdgeInsets.all(8.0),
                            itemBuilder: (context, index) {
                              return PredictionTile(place: places[index]);
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    CustomDivider(),
                            itemCount: places.length,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                          ),
                        )
                      : Container(),
                  // child: Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void findPlace(String place) async {
    if (place.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$place&key=$apiKey&components=country:in';

      var response = await Requests.getRequest(url);

      if (response == 'Failed') {
        return;
      }

      if (response['status'] == 'OK') {
        var preds = response['predictions'];
        var placeList =
            (preds as List).map((e) => Predictions.fromJson(e)).toList();

        setState(() {
          places = placeList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final Predictions place;
  const PredictionTile({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        getPlaceDetails(place.placeId as String, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Icon(
                  Icons.add_location,
                ),
                SizedBox(
                  width: 14.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.mainText as String,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        place.secondaryText as String,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  void getPlaceDetails(String placeId, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(msg: 'Setting DropOff Location...'),
    );

    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    var response = await Requests.getRequest(url);

    Navigator.pop(context);

    if (response == 'Failed') {
      return;
    }

    if (response['status'] == 'OK') {
      Address address = Address();
      address.placeName = response['result']['name'];
      address.placeId = placeId;
      address.latitude = response['result']['geometry']['location']['lat'];
      address.longitude = response['result']['geometry']['location']['lng'];
      address.formattedAddress = response['result']['formatted_address'];

      Provider.of<AppData>(context, listen: false).updateDropOff(address);

      Navigator.pop(context, "obtainDirections");
    }
  }
}
