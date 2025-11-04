import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationService {
  static Future<LatLng?> getLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    locationData = await location.getLocation();
    return LatLng(locationData.latitude!, locationData.longitude!);
  }

  static int getDistanceInMeters(LatLng point1, LatLng point2) {
    const double earthRadiusMeters = 6371000;
    double lat1 = point1.latitude;
    double lon1 = point2.longitude;
    double lat2 = point2.latitude;
    double lon2 = point2.longitude;

    double toRadians(double degrees) {
      return degrees * math.pi / 180;
    }

    double dLat = toRadians(lat2 - lat1);
    double dLon = toRadians(lon2 - lon1);

    double radLat1 = toRadians(lat1);
    double radLat2 = toRadians(lat2);

    double a = math.pow(math.sin(dLat / 2), 2) + math.pow(math.sin(dLon / 2), 2) * math.cos(radLat1) * math.cos(radLat2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    double distanceMeters = earthRadiusMeters * c;

    return distanceMeters.round();
  }
}