import 'package:taxi_fare_comparision_application/models/nearbydrivers.dart';

class GeoFireAssistant
{
  static List<NearbyDrivers> nearbyDriversList = [];

  static void removeDriver(String key)
  {
    int index = nearbyDriversList.indexWhere((element) => element.key == key);
    nearbyDriversList.removeAt(index);
  }

  static void updateDriver(NearbyDrivers driver)
  {
    int index = nearbyDriversList.indexWhere((element) => element.key == driver.key);
    nearbyDriversList[index].latitude = driver.latitude;
    nearbyDriversList[index].longitude = driver.longitude;
  }
}