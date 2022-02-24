import 'package:search_map_location/utils/google_search/latlng.dart';

class MapLocation{
  late double latitude;
  late double longitude;
  late LatLng latLng;
  MapLocation({
    required this.latitude,
    required this.longitude,

  });
  LatLng getLocation(){
    latLng=LatLng(latitude: latitude, longitude: longitude);
    return latLng;
  }



}