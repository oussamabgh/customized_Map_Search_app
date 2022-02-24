import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart' hide LatLng;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:search_map_location/utils/google_search/place.dart';
import 'package:search_map_location/utils/google_search/place_type.dart';
import 'package:taskapp/Models/location_map.dart';
import '../Models/place_model.dart';
import '../models/directions_model.dart';
import 'package:search_map_location/search_map_location.dart';
import 'package:google_place/google_place.dart';
import 'directions_repository.dart';
class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {

  bool posButton= false;
  var posi;
  var posd;
  late Position currentPosition;
   late CameraPosition kGooglePlex= CameraPosition(
     target: LatLng(33.8884523,35.5030162),
     zoom: 14.08,
   );
  late GoogleMapController newGoogleMapController;
  late Directions _info;
  final myController = TextEditingController();
  double bottomPaddingOfMap=30;
  bool polyLoad=false;
  late PlaceInfo placeInfo;
  bool hasSearch=false;
  var googlePlace = GooglePlace(' AIzaSyAiAir1uMz3NwJDd9vjIhqeEuTUgw2S7VM');
  List<Marker> allMarkers = [];
  late Marker _origin;
  late Marker _dest;
  late MapLocation mapLocation;
  @override
  void initState() {
    // TODO: implement initState
    initialize();
    mapLocation=MapLocation(latitude: kGooglePlex.target.latitude, longitude: kGooglePlex.target.longitude);
  }
  @override
  void dispose(){
    newGoogleMapController.dispose();
    super.dispose();
    myController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(body: Stack(children:  [
      SafeArea(
        child: GoogleMap(
          padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
          mapType: MapType.normal,
            myLocationButtonEnabled: false,
            initialCameraPosition: kGooglePlex,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            markers: Set.of(allMarkers),
            polylines: {
            if(polyLoad)
                Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 5,
                    points: _info.polylinePoints
                        .map((e) => LatLng(e.latitude,e.longitude)).toList()
                ),
            },
            onMapCreated: (controller){
              newGoogleMapController=controller;
            },
          ),
      ),
      if(hasSearch)
      Positioned(
        left: 30.0,
        right: 30.0,
        bottom: 35.0,
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      height: 70,
                      width: 70,
                      child: Image.memory(placeInfo.image)
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Container(
                      height: 70,
                      child: Column(

                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            placeInfo.name!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          RichText(
                              textAlign: TextAlign.start,
                              text: TextSpan(
                                  text: placeInfo!.open==true ?'Open':'Close',
                                  style: TextStyle(color: Colors.orange),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: '•',
                                        style: TextStyle(
                                          color: Colors.black,
                                        )),
                                    TextSpan(
                                        text: placeInfo.closeHour!=""? placeInfo.closeHour : 'place always open',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 11))
                                  ])),

                          Row(
                            children: [
                              Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Simple_icon_time.svg/1000px-Simple_icon_time.svg.png',
                                height: 15,
                                width: 15,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                placeInfo.distance,
                                style: TextStyle(fontSize: 11),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                  child: GestureDetector(
                    onTap: () {
                      addDirections();
                    },
                    child: Container(
                      child: const Center(
                        child: Text(
                          'Show Directions',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20)),
                        color: Colors.blue,
                      ),
                    ),
                  ))
            ],
          ),
          decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0.5, 0.5),
                    blurRadius: 5,
                    spreadRadius: 0.3),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: size.height * 0.2,
          width: size.width * 0.7,
        )
      ),
      Positioned(
        left: 30.0,
        right: 30.0,
        top: 70,
        child: SearchLocation(
    apiKey: ' AIzaSyAiAir1uMz3NwJDd9vjIhqeEuTUgw2S7VM',
     radius: 3000,
     strictBounds: true,
     location: mapLocation.getLocation(),
     placeType: PlaceType.establishment,
    onSelected: (Place place) async {
    final geolocation = await place.geolocation;
    final latLng = LatLng(geolocation?.coordinates.latitude,geolocation?.coordinates.longitude);
    //final bounds =  LatLngBounds(southwest: latLng, northeast: latLng);
      posd=latLng;
  await AjoutPoly();

    CameraPosition cameraPosition=new CameraPosition(target: latLng,zoom: 17);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    var result = await googlePlace.details.get(place.placeId,
        fields: "name,rating,opening_hours,photos");
    var day=DateTime.now().weekday;
    var  resultt=result?.result?.openingHours?.weekdayText?.removeAt(day);
    var name=result?.result?.name;
    var tst=result?.result?.photos;
    print('=======================================testtttt=================================================');
    print(tst);
    var imageRef=result?.result?.photos?.first.photoReference;
    var open=result?.result?.openingHours?.openNow;
    var distance;
    _dest = Marker(
      markerId: const MarkerId('destination'),
      infoWindow:  InfoWindow(title: name),
      icon:
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      position: latLng,
    );
    if(_info!=null){
      print('==============================Duration===========================================');
      print(_info.totalDuration);
      distance=_info.totalDuration+' by car';
    }else{
        distance='not available';
    }
    var lit;
    if (resultt != null) {
                          if(resultt.contains('–')){
                            if(open!=null){
                              if(open){
                                lit=result?.result?.openingHours?.weekdayText?.removeAt(day).split('–');
                                lit="Close at "+lit[1];
                              }else{
                                lit=result?.result?.openingHours?.weekdayText?.removeAt(day).split(': ');
                                lit=lit[1].split('–');
                                lit="Open at "+lit[0];
                              }
                            }
                          }
                  }
    else{
      lit="";

    }
     await googlePlace.photos.get(imageRef!, 70, 70).then((value) => setState(() {
       allMarkers.add(_dest);
       polyLoad=false;
       placeInfo=PlaceInfo(name:name,open: open,distance: distance,closeHour: lit,image: value);
       hasSearch=true;
     }));


    },
    ),
      ),
    ],
    ),

    );
  }
  void initialize() async {
    await locatePosition();
  }
  Future<void> AjoutPoly()async{
    if(posi!=null){
      final directions = await DirectionsRepository().getDirections(
          origin: posi, destination: posd);
      setState(() {
        _info = directions! ;
      });
    }
  }
  Future<void> addDirections() async {
  if(posi!=null){
    setState(() {
      polyLoad=true;
    });
    newGoogleMapController.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: LatLng(
                  posi.latitude <= posd.latitude
                      ? posi.latitude
                      : posd.latitude,
                  posi.longitude <= posd.longitude
                      ? posi.longitude
                      : posd.longitude),
              northeast: LatLng(
                  posi.latitude <= posd.latitude
                      ? posd.latitude
                      : posi.latitude,
                  posi.longitude <= posd.longitude
                      ? posd.longitude
                      : posi.longitude)),100),
    );
  }
    else{
     await locatePosition();
      if(posi!=null){
        final directions = await DirectionsRepository().getDirections(
            origin: posi, destination: posd);
        setState(() {
          _info = directions! ;
          placeInfo.distance=_info.totalDuration+' by car';
          polyLoad=true;
        });
        newGoogleMapController.animateCamera(
          CameraUpdate.newLatLngBounds(
              LatLngBounds(
                  southwest: LatLng(
                      posi.latitude <= posd.latitude
                          ? posi.latitude
                          : posd.latitude,
                      posi.longitude <= posd.longitude
                          ? posi.longitude
                          : posd.longitude),
                  northeast: LatLng(
                      posi.latitude <= posd.latitude
                          ? posd.latitude
                          : posi.latitude,
                      posi.longitude <= posd.longitude
                          ? posd.longitude
                          : posi.longitude)),100),
        );
      }
  }
  }
  Future<void> locatePosition() async{
    Position position =await _determinePosition();
    currentPosition=position;

    LatLng latLatPosition=LatLng(position.latitude, position.longitude);
    setState(() {
      mapLocation=MapLocation(latitude: position.latitude, longitude: position.longitude);
      posi=latLatPosition;
    });

    CameraPosition cameraPosition=new CameraPosition(target: latLatPosition,zoom: 17);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
