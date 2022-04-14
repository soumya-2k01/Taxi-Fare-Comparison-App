// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, must_be_immutable, prefer_const_literals_to_create_immutables

import 'package:driver_app/main.dart';
import 'package:driver_app/pages/mapscreen.dart';
import 'package:driver_app/pages/register.dart';
import 'package:driver_app/secret.dart';
import 'package:flutter/material.dart';

class CarInfo extends StatelessWidget {
  TextEditingController carModel = TextEditingController();
  TextEditingController carNumber = TextEditingController();
  TextEditingController carColor = TextEditingController();
  TextEditingController carService = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 22.0,
              ),
              Image.asset(
                'assets/images/logo.png',
                width: 390,
                height: 250,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(22, 22, 22, 32),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Enter Car Detials',
                      style: TextStyle(
                        fontSize: 24.0,
                      ),
                    ),
                    SizedBox(
                      height: 26.0,
                    ),
                    TextField(
                      controller: carModel,
                      decoration: InputDecoration(
                        labelText: 'Car Model',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      controller: carNumber,
                      decoration: InputDecoration(
                        labelText: 'Car Number',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      controller: carColor,
                      decoration: InputDecoration(
                        labelText: 'Car Color',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      controller: carService,
                      decoration: InputDecoration(
                        labelText: 'Service Provider',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 42,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          if(carModel.text.isEmpty)
                          {
                            displayToast('Car Model is required', context);
                          }
                          else if(carNumber.text.isEmpty)
                          {
                            displayToast('Car Number is required', context);
                          }
                          else if(carColor.text.isEmpty)
                          {
                            displayToast('Car Color is required', context);
                          }
                          else if(carService.text.isEmpty)
                          {
                            displayToast('Service provider is required', context);
                          }
                          else
                          {
                            saveCarInfo(context);
                          }
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
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
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
            ],
          ),
        ),
      ),
    );
  }

  void saveCarInfo(context) async {
    String userId = currentDriver!.uid;

    Map carInfoMap = {
      'Model': carModel.text.trim(),
      'Colour': carColor.text.trim(),
      'Number': carNumber.text.trim(),
      'ServiceProvider': carService.text.trim()
    };

    driverReference.child(userId).child('Car Details').set(carInfoMap);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(),
      ),
    );
  }
}
