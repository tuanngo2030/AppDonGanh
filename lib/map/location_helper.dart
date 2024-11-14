import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    // Get distance in meters and convert it to kilometers
    double distanceInMeters = Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
    return distanceInMeters / 1000;  // Convert meters to kilometers
  }
}
