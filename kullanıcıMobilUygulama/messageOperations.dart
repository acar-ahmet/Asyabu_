import 'package:bitirme_projesi_iki/cevirici.dart';
import 'package:bitirme_projesi_iki/locationOperations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'acceptorreject.dart';
import 'firebaseOperation.dart';

class messageOperations
{
  bool checkPassive=false;
  void xx(BuildContext context,String id) async{
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    var fcmToken = await messaging.getToken();
    setToken(id,fcmToken.toString());
    FirebaseMessaging.instance.onTokenRefresh
        .listen((fcmTokenn) {
          if(fcmToken!=fcmTokenn)
          {
            setToken(id,fcmTokenn.toString());
            fcmToken = fcmTokenn;
          }

      // TODO: If necessary send token to application server.

      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    })
        .onError((err) {
      // Error getting token.
    });
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      if(checkPassive==true){print("CheckPoint:kendisi vaka");}
      else {

        /*if (message.data == "aa") {
          FlutterRingtonePlayer.play(
              android: AndroidSounds.alarm, // will be the sound on Android
              ios: IosSounds.glass, // will be the sound on iOS
              asAlarm: true);
        }*/

        if (message.notification != null) {
          List<String> tmp = message.notification!.body.toString().split(':');

          LocationData ld_MSG;
          LatLng LL_MSG;
          getLctn().then((data) {
            ld_MSG = data!;
            LL_MSG = new LatLng(ld_MSG!.latitude!, ld_MSG!.longitude!);

            if (tmp[2] == "1" &&
                0.500 > calculateDistance(LL_MSG, yadanfo(tmp[0]))) {
              FlutterRingtonePlayer.play(
                  android: AndroidSounds.alarm, // will be the sound on Android
                  ios: IosSounds.glass, // will be the sound on iOS
                  asAlarm: true);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => acceptorreject(id, tmp[1])),
                  (route) => false);
            } else if (tmp[2] == "2" &&
                1.00 > calculateDistance(LL_MSG, yadanfo(tmp[0]))) {
              FlutterRingtonePlayer.play(
                  android: AndroidSounds.alarm, // will be the sound on Android
                  ios: IosSounds.glass, // will be the sound on iOS
                  asAlarm: true);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => acceptorreject(id, tmp[1])),
                  (route) => false);
            }
            else if (tmp[2] == "3" &&
                1.50 > calculateDistance(LL_MSG, yadanfo(tmp[0]))) {
              FlutterRingtonePlayer.play(
                  android: AndroidSounds.alarm, // will be the sound on Android
                  ios: IosSounds.glass, // will be the sound on iOS
                  asAlarm: true);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => acceptorreject(id, tmp[1])),
                      (route) => false);
            }
          });
        }
      }
    });

  }
}

double calculateDistance(LatLng one, LatLng two){
  mp.LatLng source = mp.LatLng(one.latitude, one.longitude);
  mp.LatLng destination = mp.LatLng(two.latitude, two.longitude);

  double distance =mp.SphericalUtil.computeDistanceBetween(source, destination)/1000;
  return distance;
}
