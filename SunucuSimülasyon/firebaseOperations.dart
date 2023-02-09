import 'dart:core';

import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'order_tracking.dart';


class firebaseOperations {
  LatLng changeStringToLatlng(String location)
  {
    double? latitude;
    double? longitude;
    String a = location.replaceAll(':', '.');
    List<String> data= a.split(',');
    latitude=double.parse(data[0]);
    longitude=double.parse(data[1]);
    LatLng ready= new LatLng(latitude!, longitude!);
    print(ready);
    return ready;
  }
  void tunel(String location, String personID)
  {
    personID="5e63VtVOtEhI7EAMjPwUjabWUT12";
    location ="39.9314, 32.8465";
  }
  Future<String> readData(String ID, String DataPath) async {
    print("girdi read");
    print(DataPath);
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child(DataPath).get();
    if (snapshot.exists) {
      print("var");
      print(snapshot.value.toString());
      tunel(snapshot.value.toString(),ID);
      return(snapshot.value.toString());
    } else {
      return('null');
    }
  }
  void listenAddedEmergencyCase(String ecnumber) {
    print("dinliyor");
    DatabaseReference ref = FirebaseDatabase.instance.ref(ecnumber);
    Stream<DatabaseEvent> stream = ref.onChildAdded;
    stream.listen((DatabaseEvent event) {
      Object? s_s = event.snapshot.key;
      //Map<bool,String,bool,String,bool,int> ecObject= jsonDecode(s_s);
      print("Eklenen Deger: ${event.snapshot.key} : ${event.snapshot.child(s_s.toString()).value}");
      readData(event.snapshot.key.toString(),
          'acilDurumListesi/${event.snapshot.key.toString()}/location');

      /*print('Event Type: ${event.type}'); // DatabaseEventType.value;
    print('Snapshot: ${event.snapshot}'); // DataSnapshot*/
    });
  }
  void listenRemovedEmergencyCase(String ecnumber) {
    print("dinliyor");
    DatabaseReference ref = FirebaseDatabase.instance.ref(ecnumber);
    Stream<DatabaseEvent> stream = ref.onChildRemoved;
    stream.listen((DatabaseEvent event) {
      Object? s_s = event.snapshot.value;
      //Map<bool,String,bool,String,bool,int> ecObject= jsonDecode(s_s);
      print("Silinen Deger: ${event.snapshot.key} :$s_s");
    });
  }
  void listenChangedEmergencyCase(String ecnumber) {
    print("dinliyor");
    DatabaseReference ref = FirebaseDatabase.instance.ref(ecnumber);
    Stream<DatabaseEvent> stream = ref.onChildChanged;
    stream.listen((DatabaseEvent event) {
      Object? s_s = event.snapshot.value;
      //Map<bool,String,bool,String,bool,int> ecObject= jsonDecode(s_s);
      print("Değiştirilen Deger: ${event.snapshot.key} :$s_s");
    });
  }
}
Future<String> readAiderId (String DataPath)
async {
  print("girdi readAiderId");
  print(DataPath);
  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child(DataPath).get();
  if (snapshot.exists) {
    print("var");
    String x= snapshot.value as String;
    ref.onDisconnect();
    return x.toString();

  } else {
    ref.onDisconnect();
    return('null');
  }
}
Future<String> readAiderType (String DataPath)
async {
  print("girdi readAiderType");
  print(DataPath);
  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child(DataPath).get();
  if (snapshot.exists) {
    print("var");
    String x= snapshot.value.toString();
    ref.onDisconnect();
    return x.toString();

  } else {
    ref.onDisconnect();
    return('null');
  }
}
Future<String> readAiderLocation (String DataPath)
async {
  print("girdi readAiderType");
  print(DataPath);
  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child(DataPath).get();
  if (snapshot.exists) {
    print("var");
    String x= snapshot.value as String;
    ref.onDisconnect();
    return x.toString();


  } else {
    ref.onDisconnect();
    return('null');
  }
}
setInfoAiderActiveCase(String DataPath, String info)
{
  print("girdi setInfoAiderActiveCase");
  print("$DataPath:::$info");
  final ref = FirebaseDatabase.instance.ref();
  ref.child(DataPath).update({'activeCase':info});
  ref.onDisconnect();
}
String fotanya(LocationData ld)
{
  String kutuld="${ld.latitude};${ld.longitude}";
  String kutu = kutuld.toString().replaceAll('.', '-');
  //kutu = kutu.replaceAll(',', ';');
  return kutu;
}

LatLng yadanfo(String ld)
{
  print(ld);
  ld=ld.replaceAll('-', '.');
  List<String> kutu= ld.split(';');
  LatLng fo=LatLng(double.parse(kutu[0]),double.parse(kutu[1]));
  return fo;
}

Future<List<String>> getTokens(List<String> id) async
{
  print(id.toString());
  List<String> tl=[];
  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child("users").get();
  snapshot.children.forEach((element)
  {
    if(false==id.contains(element.key.toString()))
    {
      if(element.child("type").value.toString()!="0"&&element.key.toString()!="null") {
        tl.add(element.child("token").value.toString());
      }
    }

  });
  print("${tl.toString()} ___00000000000000000000000");
  return tl;
}
void sendLocationInfo(int ecType,String personID,LatLng konum1)
{
  String konum=konum1.latitude.toString()+";"+konum1.longitude.toString();
  konum=konum.replaceAll(".", "-");
  personID=personID.replaceAll(".", "-");
  print("islem basladi _ firebase");
  final database=FirebaseDatabase.instance.ref();
  database.child("/acilDurumListesi/"+personID).set(
      {
        'ill': personID,
        'ecType':ecType,
        'location': konum,
        'completed' : false,
        'cancel' : false,
        'first':'null',
        'second':personID.substring(0, 4),
        'info':"null",
      });
  print("islem  _ firebase");
  print("islem basladı _ firebase 2");
  database.child("/ADL/$personID/").set(
      {
        personID: true,
      }
  );
  print("islem sonladı _ firebase 2");
}
void cancelEC(String iptalEdilecekAcilDurum)
{
  iptalEdilecekAcilDurum=iptalEdilecekAcilDurum.replaceAll(".", "-");
  print("testediyi $iptalEdilecekAcilDurum");
  final database=FirebaseDatabase.instance.ref();
  final adl =database.child('/acilDurumListesi');
  adl.update({
    iptalEdilecekAcilDurum+'/cancel':true,
  });
  final adl1=database.child('/ADL/$iptalEdilecekAcilDurum/');
  adl1.update({iptalEdilecekAcilDurum:false});
}
void hazirEt()
{
  final database=FirebaseDatabase.instance.ref();
  final adl =database.child('/acilDurumListesi');
  adl.remove();
  adl.onDisconnect();
  final adl1=database.child('/ADL');
  adl1.remove();
  adl1.onDisconnect();
  final adl2=database.child('/KL');
  adl2.remove();
  adl2.onDisconnect();
  final adl3=database.child('/rkl');
  adl3.remove();
  adl3.onDisconnect();
}

Future<bool?> readCancelorCompleteandSetInfo(String code) async {
  print("girdi readCancelorComplete");
  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child("/acilDurumListesi/$code").get();
  if(snapshot.child("cancel").value.toString()=="true")
    {
      return false;
    }
  else if(snapshot.child("completed").value.toString()=="true")
    {
      return true;
    }
  else
  {
    readCancelorCompleteandSetInfo(code);
  }
}
Future<String> readInfoIll (String DataPath)
async {
  print("girdi read");
  print(DataPath);
  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child(DataPath).get();
  if (snapshot.exists) {
    print("var");
    String x= snapshot.value.toString();
    return x.toString();

  } else {
    return('null');
  }
}
Future<String> readKlIndex (String klValue)
async {
  print("girdi readKlIndex");
  print(klValue);
  final ref = FirebaseDatabase.instance.ref("/KL/");
  final snapshot = await ref.get();
  if (snapshot.exists) {
    print("var");
    String x="";
    snapshot.children.forEach((element) {if(element.value==klValue){x=element.key.toString();}});
    ref.onDisconnect();
    return x;

  } else {
    ref.onDisconnect();
    return('null');
  }
}
Future<void> removerklValue (String rklValue)
async {
  print("girdi readRKlIndex");
  print(rklValue);
  final ref = FirebaseDatabase.instance.ref("/rkl/$rklValue/$rklValue");
  await ref.remove();
  ref.onDisconnect();
}

