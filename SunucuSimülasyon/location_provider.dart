import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationProvider with ChangeNotifier{

  BitmapDescriptor? _pinLocationIcon;
  BitmapDescriptor? get pinlocationIcon => _pinLocationIcon;
  Map<MarkerId, Marker>? _markers;
  Map<MarkerId, Marker>? get markers => _markers;

  final MarkerId markerId = const MarkerId("1");

  Location? _location;
  Location? get location => _location;
  LatLng? _locationPosition;
  LatLng? get locationPosition => _locationPosition;

  bool locationServiceActive = true;

  LocationProvider(){
    _location = Location();
  }
  initalization() async{

    await getUserLocation();

    await setCustomMapPiin();


  }
  getUserLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location!.serviceEnabled();
    if(!_serviceEnabled){
      _serviceEnabled = await location!.requestService();

      if(!_serviceEnabled)
      {return;}
    }
    _permissionGranted = await location!.hasPermission();
    if(_permissionGranted== PermissionStatus.denied){
      _permissionGranted = await location!.requestPermission();
      if(_permissionGranted != PermissionStatus.granted)
        {return;}
    }
    location!.onLocationChanged.listen((LocationData currentLocationData) {
      _locationPosition = LatLng(
          currentLocationData.latitude!,
          currentLocationData.longitude!,
      );

      print(currentLocationData);

      _markers = <MarkerId, Marker>{};
      Marker marker = Marker(
        markerId: markerId,
        position: LatLng(
            currentLocationData.latitude!,
            currentLocationData.longitude!
        ),
        draggable: true,
        icon: pinlocationIcon!,
        onDragEnd: ((newLocation){
          _locationPosition = LatLng(
              newLocation.latitude,
              newLocation.longitude,
          );
          notifyListeners();
          print("cp_18");
        }),
      );
      _markers![markerId]= marker;
      print("cp_3");
      notifyListeners();
    });
  }
  setCustomMapPiin () async {
    print("cp_1");
    _pinLocationIcon = await BitmapDescriptor.defaultMarker;
    print("cp_2");
  }
}