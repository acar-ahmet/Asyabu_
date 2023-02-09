import 'package:flutter/cupertino.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Polyline> getPolyLine(LatLng from,LatLng to) async
{
  List<LatLng> tempList=[];
  PolylinePoints polylinePoints = PolylinePoints();
  Polyline polyline;
  PolylineResult way = await polylinePoints.getRouteBetweenCoordinates(
    "YOUR GOOGLE CLOUD POLYKEY" ,
    PointLatLng(from.latitude,from.longitude),
    PointLatLng(to.latitude,to.longitude),
    travelMode: TravelMode.driving,

  );
  if(way.points.isNotEmpty){
    for (var point in way.points) {
      tempList.add(
        LatLng(point.latitude, point.longitude),
      );
    }
  }
  polyline=Polyline(
    polylineId: PolylineId("routeToIll"),
    points: tempList,
    color: CupertinoColors.systemBlue,
    width: 5,
  );
  return polyline;
}