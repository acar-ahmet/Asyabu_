import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


void sendLocationInfo(int ecType,String personID,String konum)
{

  final database=FirebaseDatabase.instance.ref();
  database.child("/acilDurumListesi/"+personID).set(
      {
        'ill': personID,
        'ecType':ecType,
        'location': konum,
        'completed' : false,
        'cancel' : false,
        'first':'null',
        'second': personID.substring(0, 4),
        'info':"null",
      });

  database.child("/ADL/$personID").set(
    {
      personID: true,
    }
  );

}
void cancelEC(String iptalEdilecekAcilDurum)
{

  final database=FirebaseDatabase.instance.ref();
  final adl =database.child('/acilDurumListesi');
  adl.update({
    iptalEdilecekAcilDurum+'/cancel':true,
  });
  final adl1=database.child('/ADL/$iptalEdilecekAcilDurum/');
  adl1.update({iptalEdilecekAcilDurum:false});
}
void updateInfoIll(String iptalEdilecekAcilDurum,String infoF,String? UserID)
{

  readInfoIll("/acilDurumListesi/$iptalEdilecekAcilDurum/second").then((value) {
    if(infoF.contains(value)){
      final database=FirebaseDatabase.instance.ref();
      final adl =database.child('/acilDurumListesi');
      adl.update({
        iptalEdilecekAcilDurum+'/info':infoF,
        iptalEdilecekAcilDurum+'/completed':true,
      });
      adl.onDisconnect();
      final adl1 =database.child('/ADL/$iptalEdilecekAcilDurum/');
      adl1.update({iptalEdilecekAcilDurum:false});
      adl1.onDisconnect();
      updateAcceptCase(UserID!,completed: true);
      //exit(0);
    }
    else{Fluttertoast.showToast(msg: "Kod yanlış tekrar gir veya doğru vakada olduğundan emin ol!!!");}
  });
}
void updateAcceptCase(String iptalKurtar,{bool completed=false}) async
{
  String iptal="iptal";
  if(completed!=false){iptal == "tamamladı";}
  Fluttertoast.showToast(msg:iptalKurtar);
  final database=FirebaseDatabase.instance.ref();
  final adl =database.child('/users/$iptalKurtar/');
  adl.update({
      'activeCase':iptal,
  });
  await adl.onDisconnect();
  if(completed!=true)
  {
    final rkl=database.child('/rkl/');
    await rkl.child(iptalKurtar).set({iptalKurtar:"false"});
    await rkl.onDisconnect();
  }
  Fluttertoast.showToast(msg:"işlemler yapıldı");
  if(completed==true){}
  else
  {Future.delayed(const Duration(seconds: 2), (){exit(0);});}
}

Future<String> readData (String DataPath)
async {

  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child(DataPath).get();
  if (snapshot.exists) {
    bool x= snapshot.value as bool;
    return x.toString();

  } else {
    return('null');
  }
}
Future<String> readInfoIll (String DataPath)
async {

  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child(DataPath).get();
  if (snapshot.exists) {

    String x= snapshot.value.toString();
    return x.toString();

  } else {
    return('null');
  }
}
Future<String> readKL (String DataPath)
async {

  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child(DataPath).get();
  if (snapshot.exists) {
    //("var");
    List<Object?> data =  snapshot.value as List<Object?>;
    return data.toString();
  } else {
    return('null');
  }
}
Future<String> readLocationofCases (String DataPath)
async {

  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child(DataPath).get();
  if (snapshot.exists) {
    //("var");
    String data =  snapshot.value as String;
    return data.toString();
  } else {
    return('null');
  }
}
Future<String> readInfoofTheCase (String DataPath)
async {

  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child(DataPath).get();
  if (snapshot.exists) {
    //("var");
    String data =  snapshot.value.toString();
    return data;
  } else {
    return('null');
  }
}
void setKL(List<String> data,String personID)
async {

  final database = FirebaseDatabase.instance.ref();
  database.child("/KL/$personID/").set(
      {
        personID:true,
      }
  );
  database.child("/users/$personID").update(
      {
        'activeCase':"waitForIll",
      }
  );
}
void setLocation(String personID, String konum)
{

  final database = FirebaseDatabase.instance.ref();
  database.child("/users/$personID").update(
      {
        'location': konum,
      }
  );
}

setToken(String id, String token)
{

  final database = FirebaseDatabase.instance.ref();
  database.child("/users/$id").update(
      {
        'token': token,
      }
  );
}



