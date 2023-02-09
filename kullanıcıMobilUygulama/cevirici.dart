import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

String fotanya(LocationData ld)
{
  String kutuld="${ld.latitude};${ld.longitude};";
  String kutu = kutuld.toString().replaceAll('.', '-');
  //kutu = kutu.replaceAll(',', ';');
  return kutu;
}

LatLng yadanfo(String ld)
{
  ld=ld.replaceAll('-', '.');
  List<String> kutu= ld.split(';');
  LatLng fo=LatLng(double.parse(kutu[0]),double.parse(kutu[1]));
  return fo;
}

Future<String> readInfoFromFile() async
{
  String appDocPath = "";
  Directory appDocDir = await getApplicationDocumentsDirectory();
  appDocPath = appDocDir.path;
  return appDocPath;
}