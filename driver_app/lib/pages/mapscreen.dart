// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:driver_app/tabs/earnings.dart';
import 'package:driver_app/tabs/homeTab.dart';
import 'package:driver_app/tabs/profile.dart';
import 'package:driver_app/tabs/ratings.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  late TabController tabs;

  int selectedIndex = 0;

  void onChange(int index)
  {
    setState(() {
      selectedIndex = index;
      tabs.index = selectedIndex;
    });
  }

  @override
  void initState() {
    super.initState();

    tabs = TabController(
      length: 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    tabs.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabs,
        children: [
          Home(),
          Earning(),
          Rating(),
          Profile(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Earning', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Rating', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile', 
          ),
        ],
        unselectedItemColor: Colors.black54,
        selectedItemColor: Colors.yellow,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12.0,
        ),
        showUnselectedLabels: true,
        onTap: onChange,
        currentIndex: selectedIndex,
      ),
    );
  }
}
