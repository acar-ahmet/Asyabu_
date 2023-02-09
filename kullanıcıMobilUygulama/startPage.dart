import 'dart:io';
import 'package:bitirme_projesi_iki/acceptorreject.dart';
import 'package:bitirme_projesi_iki/declareEmergencyCase.dart';
import 'package:bitirme_projesi_iki/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'cevirici.dart';
import 'locationOperations.dart';
import 'loginpage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'messageOperations.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  //await Firebase.initializeApp();
  if(message.notification!.body.toString().contains('Kimlik'))
  {
  FlutterRingtonePlayer.play(
      android: AndroidSounds.alarm, // will be the sound on Android
      ios: IosSounds.glass ,			   // will be the sound on iOS
      asAlarm: true
  );
  }
  else
  {/*print('CHECKPOINT');*/}

}

void startChangepage(RemoteMessage message) async {
  if (message.notification != null) {
    List<String> tmp = message.notification!.body.toString().split(':');
    LocationData ld_MSG;
    LatLng LL_MSG;
    final Directory directory = await getApplicationDocumentsDirectory();
    bool a=await File('${directory.path}/myLocation.txt').exists();
    if(a!=true){return;}
    final File file = File('${directory.path}/myLocation.txt');
    String text = await file.readAsString();
    List<String> data=text.split(";");
    LL_MSG = LatLng(double.parse(data[0]), double.parse(data[1]));
    {
      if (tmp[2] == "1" &&
          0.500 > calculateDistance(LL_MSG, yadanfo(tmp[0]))) {
        FlutterRingtonePlayer.play(
            android: AndroidSounds.alarm, // will be the sound on Android
            ios: IosSounds.glass, // will be the sound on iOS
            asAlarm: true);
        _write(tmp[0].toString());
      } else if (tmp[2] == "2" &&
          1.00 > calculateDistance(LL_MSG, yadanfo(tmp[0]))) {
        FlutterRingtonePlayer.play(
            android: AndroidSounds.alarm, // will be the sound on Android
            ios: IosSounds.glass, // will be the sound on iOS
            asAlarm: true);
        _write(tmp[0].toString());
      }
    }

  }
}
_write(String text) async {
  print("bildirim işlendi");
  print(text);
  final Directory directory = await getApplicationDocumentsDirectory();
  bool a=await File('${directory.path}/caseLocation.txt').exists();
  if(a==true){await File('${directory.path}/caseLocation.txt').delete();}
  final File file = File('${directory.path}/caseLocation.txt');
  await file.writeAsString(text);
}
class startPage extends StatefulWidget {

  @override
  _startPage createState() => _startPage();
}
class _startPage extends State<startPage>{
  void startAction() async
  {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _read();

  }
  void _read() async {
    Future.delayed(Duration(seconds: 5));
    String? text;
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/my_file.txt');
      text = await file.readAsString();
      print(text);
      List<String> tmp= text.split(",");
      LOGINACTION_START(tmp[0],tmp[1]);
    } catch (e) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => loginSection()),
              (Route<dynamic> route) => false);

    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startAction();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          /*image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover,
          ),*/
        ),
        child: const Center(child: Image(image: AssetImage('assets/images/asyabu.gif'),),),
        ),
      );

  }
  void LOGINACTION_START(String email_F,String password_F) {
        FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email_F, password: password_F)
            .then((user) {
          //if login is successful, enter this section

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => DECSection(user.user!.uid)),
                  (Route<dynamic> route) => false);
        }).catchError((hata) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => loginSection()),
                  (Route<dynamic> route) => false);
        });


  }

}