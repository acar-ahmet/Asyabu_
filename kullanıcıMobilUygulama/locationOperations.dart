import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:fluttertoast/fluttertoast.dart';


Future<LocationData?> getLctn() async {
  Location locationn = Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  //locationn.enableBackgroundMode(enable: true);
  _serviceEnabled = await locationn.serviceEnabled();
  //print(_serviceEnabled);
  if (!_serviceEnabled) {
    _serviceEnabled = await locationn.requestService();
    if (!_serviceEnabled) {
      return null;
    }
  }

  _permissionGranted = await locationn.hasPermission();
  //print(_permissionGranted);
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await locationn.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }

  _locationData = await locationn.getLocation();
  //double? aa = _locationData.altitude;
  return _locationData;
}

void getCurrentLctn() async {
  Location location = Location();
  //location.enableBackgroundMode(enable: true);
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      Fluttertoast.showToast(msg: "Service isn't enable");
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      Fluttertoast.showToast(msg: "Permission isn't granted");
    }
  }
  location.onLocationChanged.listen((LocationData currentData) {
    print(currentData);

  });
}