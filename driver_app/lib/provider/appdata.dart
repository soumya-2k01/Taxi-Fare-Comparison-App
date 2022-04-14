import 'package:flutter/cupertino.dart';
import 'package:driver_app/models/address.dart';

class AppData extends ChangeNotifier
{
  late Address userPickUp;
  late Address userDropOff;

  void updatePickUp(Address address)
  {
    userPickUp = address;
    notifyListeners();
  }

  void updateDropOff(Address address)
  {
    userDropOff = address;
    notifyListeners();
  }
}