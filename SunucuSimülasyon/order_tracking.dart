import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:simulation_university_project/liveLocationTracking/sendMessageGithub/sendMessage.dart';
import 'package:collection/collection.dart';
import 'firebaseOperations.dart';


class data
{
  String? key;
  String? value;
}
class EmergencyCase{
  late String ID;
  late DateTime goldenTime;
  late int caseNumber;
  late LatLng casePosition;
  late int caseType;
  Aider? firstAider;
  Aider? secondAider;
  List<Aider> ec_aiderList=[];
  List<Aider> wantSaving=[];
  List<Polyline> casePolylineList=[];
  List<Circle> caseCircleList=[];
}
class Aider
{
  late String aiderID;
  late int aiderType;
  int activeAndCaseNumber=0;
  late LatLng startPosition;
  LatLng? currentPosition;
  late int distanceToIll;
  int accept_rejectSaving=0;
  bool wntHlp=false;
  List<int> emergencyCases=[];
}


class orderTracking extends StatefulWidget {
  const orderTracking({Key? key}) : super(key: key);

  @override
  State<orderTracking> createState() => _orderTrackingState();
}

class _orderTrackingState extends State<orderTracking> {
  //boolean pop
  Timer? mytimer;
  static bool checkListenKL=false;
  int checkEmergency=1;
  bool? assigmentAider;
  bool? acilSBY_check;
  bool? bildirimYapti;
  //Marker? selectedMarker;
  String? selectedMarkerId;
  int? selectedAider;
  //LatLng? emercencyDot;
  //string contain
  String kod1= "EmergencyCaseLocation";
  //lists
  List<TextButton> acilListe=[];
  List<Aider> aiderList = [];
  List<Marker> markerList = [];
  List<EmergencyCase> ecList = [];
  List<Circle> circleList=[];
  List <Polyline> polylineCoordinatesList=[];
  //------------------------
  DateTime? goldenTimePanel=null;
  int counter = 0;
  int counterId= 0;
  int polylineCounter = 0;
  final Completer<GoogleMapController> _controller = Completer();
  Color wayColor= Colors.blueAccent;
  static const LatLng destinationLocation = LatLng(39.9318, 32.8461);
  static const LatLng sourceLocation = LatLng(39.934298, 32.843268);
  LocationData? currentLocation;
  //List<LatLng> polylineCoordinates = [];
  BitmapDescriptor sourceFirstLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor sourceCurrentLocationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationLocationIcon = BitmapDescriptor.defaultMarker;
  void emergencyCaseChange(int caseNumber){
    //circle list, polylinelist, marker change in this section
    //print(caseNumber);
    if(caseNumber==0)
      {
        circleList=[];
        polylineCoordinatesList=[];
        goldenTimePanel=null;
      }
    else{
      print("xxxxx___1");
      EmergencyCase ec=ecList.firstWhere((element) => element.caseNumber==caseNumber);
      print("xxxxx___2");
      circleList=ec.caseCircleList;
      polylineCoordinatesList=ec.casePolylineList;
      goldenTimePanel=ec.goldenTime;
    }
  }
  void reviewLocations() async
  {
        if(aiderList.length!=0)
          {
            for (var f_aider in aiderList)
            {
              if(f_aider!=null&&false==f_aider!.aiderID.contains("Yeni Kurtarıcı"))
              {
                readAiderLocation("users/${f_aider!.aiderID}/location").then((value)
                {
                  print(f_aider!.aiderID);
                  f_aider!.currentPosition=yadanfo(value);//
                  if(f_aider.activeAndCaseNumber!=0)
                  {
                    if (ecList[f_aider.activeAndCaseNumber - 1].firstAider != null && ecList[f_aider.activeAndCaseNumber - 1].firstAider!.aiderID == f_aider.aiderID)
                    {ecList[f_aider.activeAndCaseNumber - 1].firstAider!.currentPosition = f_aider.currentPosition;}
                    else if (ecList[f_aider.activeAndCaseNumber - 1].secondAider != null && ecList[f_aider.activeAndCaseNumber - 1].secondAider!.aiderID ==f_aider.aiderID)
                    {ecList[f_aider.activeAndCaseNumber - 1].secondAider!.currentPosition = f_aider.currentPosition;}
                  }
                  print(yadanfo(value));
                  final marker = markerList.firstWhere((element) => element.markerId.value == f_aider!.aiderID);
                  int index =markerList.indexOf(marker);
                  Marker _marker = Marker(
                    markerId: marker.markerId,
                    onTap: () {
                    },
                    position: LatLng(f_aider!.currentPosition!.latitude, f_aider!.currentPosition!.longitude),
                    icon: marker.icon,
                    infoWindow: InfoWindow(title: marker.markerId.value.toString()),
                  );
                  setState(() {
                    print(_marker.position);
                    markerList[index] = _marker;
                  });
                });
              }
            }
          }
        /*if(ecList.length!=0)
          {
              for (var ec in ecList)
              {
                if(ec.firstAider!=null&&(false==ec.firstAider!.aiderID.contains(kod1)&&false==ec.firstAider!.aiderID.contains("Yeni Kurtarıcı")))
                  {
                      print("++++++++++++");
                      readAiderLocation("users/${ec.firstAider!.aiderID}/location").then((value)
                      {
                        print(ec.firstAider!.aiderID);
                        ec.firstAider!.currentPosition=yadanfo(value);
                        print(yadanfo(value));
                        print(value);
                        print(ec.firstAider!.aiderID);
                        final marker = markerList.firstWhere((element) => element.markerId.value == ec.firstAider!.aiderID);
                        int index =markerList.indexOf(marker);
                        Marker _marker = Marker(
                          markerId: marker.markerId,
                          onTap: () {
                          },
                          position: LatLng(ec.firstAider!.currentPosition!.latitude, ec.firstAider!.currentPosition!.longitude),
                          icon: marker.icon,
                          infoWindow: InfoWindow(title: marker.markerId.toString()),
                        );
                        setState(() {
                          print(_marker.position);
                          markerList[index] = _marker;
                        });
                      });

                  }
                if(ec.secondAider!=null&&(false==ec.secondAider!.aiderID.contains(kod1)&&false==ec.secondAider!.aiderID.contains("Yeni Kurtarıcı")))
                  {
                    print("???????????????");
                      readAiderLocation("users/${ec.secondAider!.aiderID}/location").then((value){
                        print(ec.secondAider!.aiderID);
                        print(value);
                        ec.secondAider!.currentPosition=yadanfo(value);
                        print(yadanfo(value));
                        print(ec.secondAider!.aiderID);
                        final marker = markerList.firstWhere((element) => element.markerId.value == ec.secondAider!.aiderID);
                        int index =markerList.indexOf(marker);
                        Marker _marker = Marker(
                          markerId: marker.markerId,
                          onTap: () {
                          },
                          position: LatLng(ec.secondAider!.currentPosition!.latitude, ec.secondAider!.currentPosition!.longitude),
                          icon: marker.icon,
                          infoWindow: InfoWindow(title: marker.markerId.toString()),
                        );
                        setState(() {
                          print(_marker.position);
                          markerList[index] = _marker;
                        });
                      });
                  }
              }
          }*/
  }
  void acilDurumButonuEkle(String ecn){

    TextButton aa =TextButton(
      key: Key(ecn),
      style: TextButton.styleFrom(
        primary: Colors.black,
        backgroundColor: Colors.white60,
        padding: EdgeInsets.all(3.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
      ),
      onPressed: () {
        if(ecn=="test")
        {
          print("a1");
          if(checkListenKL==false)
            {
              print("a2");
              hazirEt();
              listenAddedRKL("rkl");
              listenAddedEmergencyCase("ADL");
              listenChangedEmergencyCase("ADL");
              ListenKLdirectory();checkListenKL=true;
              mytimer = Timer.periodic(Duration(seconds: 10), (timer) {reviewLocations();//mytimer.cancel() //to terminate this timer
              });
            }
          else{print("a3");/*mytimer!.cancel();*/}
          reviewLocations();

          /*listenRemovedEmergencyCase("ADL");
          listenChangedEmergencyCase("ADL");*/
          //readData("acilDurumListesi/deneme39:93173,32:84664/location");
        }
        else
        {
          if (ecn == "TEMiZLE") {
            ecn = "0";
          }
          checkEmergency = int.parse(ecn);
          emergencyCaseChange(checkEmergency);
          setState(() {});
        }
      },
      child: Text(ecn),);
      acilListe.add(aa);
  }
  void acilDurumButonuSil(String ecn){
    //yapılacak
  }
  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then(
        (location){
          print("lokasyonTEK:$location");
          currentLocation = location;
          setState(() {});
        },
    );

    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((newLocation) {
      currentLocation = newLocation;
      //print("lokasyon:$currentLocation");
      /*googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(
                  zoom: 18.5,
                  target: LatLng(
                      newLocation.latitude!,
                      newLocation.longitude!
                  )),
          ),
      );*/
      setState(() {
        //currentLocation = newLocation;
      });
      },
    );
  }
  void getPolyPoints(LatLng from, LatLng to,int cn,int priority) async {
    print("case $cn prio = $priority from= $from to= $to");

    Color wayColorsinFunction;
    int widthWay;
    List<LatLng> tempList=[];
    PolylinePoints polylinePoints = PolylinePoints();
    Polyline polyline;
    PolylineResult way = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyAyZ4SkhyHyyUbsmJD2BSybxWRXzI8g4ic" ,
      PointLatLng(from.latitude,from.longitude),
      PointLatLng(to.latitude,to.longitude),
      travelMode: TravelMode.walking,

    );
    print("dddd___1");
    if(way.points.isNotEmpty){
      polylineCounter++;
      for (var point in way.points) {
        tempList.add(
        LatLng(point.latitude, point.longitude),
      );
        print(point);
      }
      for (var emcase in ecList) {
        if(emcase.caseNumber==cn)
        {
          print("dddd___2");
              if(priority==2||priority==1||priority==6||priority==7)
                {
                  print("dddd___3");
                  wayColorsinFunction=Colors.blueAccent;
                  widthWay=6;
                }
              else if(priority==4||priority==3)
                {
                  wayColorsinFunction=Colors.deepOrange;
                  widthWay=3;
                }
              else
                {
                  wayColorsinFunction=Colors.black;
                  widthWay=10;
                }


          polyline=Polyline(
            polylineId: PolylineId("route$polylineCounter"),
            points: tempList,
            color: wayColorsinFunction,
            width: widthWay,
          );
          if(priority==1||priority==3||priority==6||priority==7)
            {
              print("dddd___4");
              if(priority==3 &&emcase.casePolylineList.length>1)
                {emcase.casePolylineList[1]=polyline;}
              else{emcase.casePolylineList.add(polyline);}
              emergencyCaseChange(cn);
            }
          else if(priority==2)
            {
              print("dddd___5");
              if(emcase.casePolylineList.isEmpty)
              {emcase.casePolylineList.add(polyline);}
              emcase.casePolylineList[0]=polyline;
              emergencyCaseChange(cn);

            }
          else if(priority==4)
            {
              if(emcase.casePolylineList.length<2)
              {
              emcase.casePolylineList.add(polyline);
              }
              print("dddd___6");
              emcase.casePolylineList[1]=polyline;
              emergencyCaseChange(cn);
            }
          else
            {
              print("polylineList eklemesi veya değişikliği yapılmadı");
            }
          break;
        }
      }
      //polylineCoordinatesList.add(polyline);
      setState(() {});
    }
  }

  void loadIcon(){
    sourceFirstLocationIcon= BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    sourceCurrentLocationIcon= BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    destinationLocationIcon= BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }

  @override
  void initState(){

    Firebase.initializeApp();
    //loadIcon();
    acilDurumButonuEkle("TEMiZLE");
    acilDurumButonuEkle("test");
    getCurrentLocation();
    getPolyPoints(sourceLocation,destinationLocation,0,1);
    //loadAiderList();
    //calculateDistance();
    super.initState();
    //Timer.periodic(const Duration(seconds: 5), (timer) {ecList.forEach((element) {function_reviewAssignments(element.caseNumber); }); });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Bitirme Projesi II SiMüLASYON",
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
        ),
        body:currentLocation == null
            ? const Center(child: Text("Loading"),)
            : Stack(
              children: [GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 18,
              ),
              mapType: MapType.normal,
              polylines: Set.from(polylineCoordinatesList),
              circles: Set.from(circleList),
              markers: Set.from(markerList),
              onMapCreated: (mapController){
                _controller.complete(mapController);
              },
              onLongPress: (coordinate){
                counterId++;
                String id = "$counterId.$kod1";
                function_addMarker(coordinate,id);
                selectedMarkerId=null;
              },
              onTap: (coordinate){
                assigmentAider=false;
                selectedMarkerId=null;
                acilSBY_check=false;
                setState(() {});
              },
                ),
                Positioned(
                  top: 10,
                  right: 10,

                  child: CupertinoAlertDialog(
                  title:selectedMarkerId == null ? null :Text(selectedMarkerId!),
                  content:selectedMarkerId == null ?null :const Text("") ,
                  actions: selectedMarkerId == null ? []: [
                    CupertinoDialogAction(child: bildirimYapti==true ? Text("Öncelikleri Yenile"):Text("Acil Sağlık Yardımı Bildirimi Yap"),
                      onPressed: (){
                      if(bildirimYapti==true){
                        acilSBY_check==false;
                        int Index = ecList.indexWhere((element) => element.ID==selectedMarkerId);
                        function_createEmergencyCase(ecList[Index].casePosition, ecList[Index].caseType, ecList[Index].goldenTime, ecList[Index].ID);
                        broadcastAgain(ecList[Index]);
                        function_reviewAssignments(ecList[Index].caseNumber);
                      }
                      else{acilSBY_check=true;setState(() {});}
                      },),
                    CupertinoDialogAction(child: Text("İşareti Sil"),
                    onPressed: (){
                      print(selectedMarkerId!);
                      if(null!=ecList.firstWhereOrNull((element1x) => element1x.ID==selectedMarkerId))
                        {print("girdi${selectedMarkerId!}");
                          ecList.forEach((element1y) {if(element1y.ID==selectedMarkerId)
                          {
                            cancelEC(selectedMarkerId!);
                            emergencyCaseChange(0);
                            print("iptal etti${selectedMarkerId!}");
                          } });

                        }
                      //kullanıcıyı sil: eğer kurtarıcı silersen listedende sil
                      if(selectedMarkerId.toString().contains(kod1)){
                        //test
                        markerList.forEach((element) {if(element.markerId.toString().contains(selectedMarkerId!)){
                          print("Marker var");
                        } });
                        //ana operasyon
                        markerList.removeWhere((item) => item.markerId.toString().contains(selectedMarkerId!));
                        //test
                        markerList.forEach((element) {if(element.markerId.toString().contains(selectedMarkerId!)){
                          print("Hata var. Marker silinmemiş");
                        } });
                      }
                      else
                      {
                        //test
                        aiderList.forEach((element) {if(element.aiderID.toString().contains(selectedMarkerId!)){
                          print("Aider mevcut!!");
                        } });
                        //ana operasyon
                        aiderList.removeWhere((element) => element.aiderID.toString().contains(selectedMarkerId!));
                        //test
                        aiderList.forEach((element) {if(element.aiderID.toString().contains(selectedMarkerId!)){
                          print("Hata var. Silinmemiş");
                        } });
                        //test
                        markerList.forEach((element) {if(element.markerId.toString().contains(selectedMarkerId!)){
                          print("MARKER VAR !!");
                        } });
                        //ana operasyon
                        markerList.removeWhere((item) => item.markerId.toString().contains(selectedMarkerId!));
                        //test
                        markerList.forEach((element) {if(element.markerId.toString().contains(selectedMarkerId!)){
                          print("Hata var. Silinmemiş");
                        } });
                      }
                      selectedMarkerId=null;
                      setState(() {});

                    },),
                    selectedMarkerId!.contains(kod1)  ?
                    CupertinoDialogAction(child: Text("Kurtarıcı Rolü Ata"),
                    onPressed: (){
                      assigmentAider = true;
                      setState(() {});
                     /* //doctor,hemşire veya sertifika sahibi ataması yap.
                      */
                    },)
                        :
                    CupertinoDialogAction(child: selectedAider!=null ? Text("Yardım Edeceğim"):Text("Yardım edilecek vaka yok"),
                      onPressed: (){
                          if(selectedAider==null)
                            {}
                          else{
                            //burası düzeltilecek

                            function_wantSavePerson(selectedMarkerId!, selectedAider!);
                            selectedMarkerId=null;
                          }
                        setState(() {});
                      },),
                  ],
                  ),
                ),

                Positioned(

                    child:CupertinoAlertDialog(
                      title:assigmentAider == true && selectedMarkerId != null ? Text("Kurtarıcı Rolünü Seçiniz") :null,
                      content:assigmentAider == true && selectedMarkerId != null ? const Text("") : null,
                      actions: assigmentAider == true && selectedMarkerId != null ? [
                        CupertinoDialogAction(child: Text("Doktor"),
                          onPressed: (){print("Doktor");function_assignmentAider(1);},),
                        CupertinoDialogAction(child: Text("Hemşire"),
                          onPressed: (){print("Hemşire");function_assignmentAider(2);},),
                        CupertinoDialogAction(child: Text("Sertifika Sahibi"),
                          onPressed: (){print("SS");function_assignmentAider(3);},),
                      ]: [],
                    ),
                ),
                Positioned(

                  child:CupertinoAlertDialog(
                    title:acilSBY_check == true && selectedMarkerId != null ? Text("VAKA TiPi") :null,
                    content:acilSBY_check == true  && selectedMarkerId != null ? const Text("") : null,
                    actions: acilSBY_check == true  && selectedMarkerId != null ? [
                      CupertinoDialogAction(child: Text("NEFES"),
                        onPressed: (){
                        print("Nefes");
                        function_typeEC(1);
                        },),
                      CupertinoDialogAction(child: Text("KANAMA"),
                        onPressed: (){print("Kanama");
                        function_typeEC(2);
                        },),
                      CupertinoDialogAction(child: Text("KALP DURMASI"),
                        onPressed: (){print("Kalp Durması");
                        function_typeEC(3);
                        },),
                    ]: [],
                  ),
                ),

                Positioned(
                  width:MediaQuery.of(context).size.width,
                  height: 50,
                  child:SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      color: Colors.black45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: acilListe,
                      ),
                    ),
                  ),
                ),
                /*Positioned(
                  height: 50,
                  right: 0,
                  child:SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: goldenTimePanel==null ?[]:[Text(goldenTimePanel!.hour.toString()),Text(":"),Text(goldenTimePanel!.minute.toString()),Text(":"),Text(goldenTimePanel!.second.toString()),Text(":"),Text(goldenTimePanel!.millisecond.toString())],
                      ),
                    ),
                  ),
                ),*/
              ],

            ));

  }
  void aiderCheckEnvironment(int sendingInfo,String ecPersonId)
  {
    print("check 0:aide_rCheckEnvironment");
    EmergencyCase? ec = ecList.firstWhereOrNull((element) => element.caseNumber==sendingInfo);
    if(ec!=null)
    {
      List<List<String>> tmp =[];
      if(ec.caseNumber==sendingInfo) {
        print("check 0:aide_rCheckEnvironment:: caseNumber:: $sendingInfo");
        ec.ec_aiderList.forEach((ec_aidList)
        {
          Aider? aiderfrommainlist = aiderList.firstWhereOrNull((element) => element.aiderID==ec_aidList.aiderID);
          if(null != aiderfrommainlist &&aiderfrommainlist!.activeAndCaseNumber !=ec.caseNumber){aiderfrommainlist=null;}
          if(null!=aiderfrommainlist)
          {
            print("check 0:aide_rCheckEnvironment:: aiderID:: ${aiderfrommainlist.aiderID}");
            aiderfrommainlist.emergencyCases.forEach((element) {print(element);});
            aiderfrommainlist.emergencyCases.removeWhere((pp) => pp==ec.caseNumber);
            aiderfrommainlist.emergencyCases.forEach((element) {print(element);});
            print("check 1:___lastCheckEnvironment");
            ecList.forEach((cevreTarama)
            {
              print("check 2:cevreTarama:aide_rCheckEnvironment");
              if (calculateDistance(
                  aiderfrommainlist!.currentPosition!, cevreTarama.casePosition) <
                  0.500) {
                print("aider ID== ${aiderfrommainlist!.aiderID}>>>> caseNumber== ${cevreTarama.caseNumber}");
                List<String> gg=[];
                print("ıd kontrol :${cevreTarama.ID}");
                if(cevreTarama.ID!=" ")
                {

                  print("check gg");
                  gg.add(aiderfrommainlist.aiderID);
                  gg.add(cevreTarama.caseNumber.toString());
                  tmp.add(gg);
                  if(false==aiderfrommainlist.emergencyCases.contains(cevreTarama.caseNumber))
                  {aiderfrommainlist.emergencyCases.add(cevreTarama.caseNumber);print("check aider_case_list");}
                  if(null==cevreTarama.wantSaving.firstWhereOrNull((element) => element.aiderID==aiderfrommainlist!.aiderID))
                  {cevreTarama.wantSaving.add(aiderfrommainlist);print("check ecase_want_list");}
                }
                //ec.ec_aiderList.add(aiderfrommainlist);
                print("son kontrol yapıldı");
              }
            });
            aiderfrommainlist.emergencyCases.forEach((element) {print(element);});
            print("list lenght = "+aiderfrommainlist.emergencyCases.length.toString());
            if(aiderfrommainlist.emergencyCases.length>0)
            {
              aiderfrommainlist.activeAndCaseNumber=0;
              readCancelorCompleteandSetInfo(ecPersonId).then((value)
              {
                if(value==false)
                {
                  function_assignmentAidertoEC(aiderfrommainlist!,true,c_c:value,sonKontrol:true);
                }
                else if(value==true)
                {
                  function_assignmentAidertoEC(aiderfrommainlist!,true,c_c:value,sonKontrol:true);
                }
              });
            }
            else if(aiderfrommainlist.emergencyCases.length==0){
              print("${aiderfrommainlist.aiderID}'nin Çevresinde herhangi bir vaka yok.");
              readCancelorCompleteandSetInfo(ecPersonId).then((value) {
                if(value==false)
                {
                  setInfoAiderActiveCase("users/${aiderfrommainlist!.aiderID}", "activeCase;iptalEdildi;4;100");
                }
                else if(value==true)
                {
                  setInfoAiderActiveCase("users/${aiderfrommainlist!.aiderID}", "activeCase;Tamamlandı;5;100");
                  readInfoIll("acilDurumListesi/$ecPersonId/info").then((value)
                  {
                    print("MARKER EKLEME ÇALIŞTI ------------------------------");
                    function_addRealAiderMarker(ecPersonId,ec.casePosition!,rol:10,info:value);
                  });
                }
                else{print("hhhhhhhhhhhhhhhhata____________var");}
              });
            }
          }
        });
        for (var aktarici in tmp) 
        {
          print("aktarici____");
          print(aktarici[0]+"=>"+aktarici[1]);
          print(aiderList.firstWhere((elementt) => elementt.aiderID.contains(aktarici[0].trim())).aiderID);
          if(false==(ecList.firstWhere((element) => element.caseNumber.toString()==aktarici[1]).ec_aiderList.contains(aiderList.firstWhere((elementt) => elementt.aiderID==aktarici[0]))))
          {
            ecList.firstWhere((element) => element.caseNumber.toString()==aktarici[1]).ec_aiderList.add(aiderList.firstWhere((elementt) => elementt.aiderID==aktarici[0]));
            print(ecList.firstWhere((element) => element.caseNumber.toString()==aktarici[1]).caseNumber.toString()+"'a aktarılan aider "+aiderList.firstWhere((elementt) => elementt.aiderID==aktarici[0]).aiderID);}
          }

      }
    }
  }

  function_typeEC(int a){
    LatLng? aa;
    markerList.forEach((element) {
      if(element.markerId.toString().contains(selectedMarkerId!)){
        aa = element.position;
      }
    });
    if(aa==null){}
    else{
      Duration? addTime;
      switch(a)
      {
        case 1:
          addTime=const Duration(minutes:2,seconds: 30);
          break;
        case 2:
          addTime=const Duration(minutes:1,seconds: 30);
          break;
        case 3:
          addTime=const Duration(minutes:8,seconds: 00);
          break;
      }
      DateTime now = DateTime.now();
      print("Now:$now");
      DateTime dl=now.add(addTime!);
      function_createEmergencyCase(aa!, a,dl,selectedMarkerId!);
      acilSBY_check = false;
      setState(() {// burada bir alarm ver
        selectedMarkerId=null;
      });
    }
  }
  function_assignmentAider(int rol){
    Aider newAider = new Aider();
    newAider.aiderType = rol;

    Marker oldMarkerInfo = markerList.firstWhere((element) => element.markerId.toString().contains(selectedMarkerId!));
    newAider.startPosition= oldMarkerInfo.position;
    newAider.currentPosition=newAider.startPosition;

    final splitData =selectedMarkerId.toString().splitMapJoin('.');
    String a= splitData[0];

    if(rol==1){newAider.aiderID= "$a Yeni Kurtarıcı:Doktor ";}
    else if(rol==2){newAider.aiderID= "$a Yeni Kurtarıcı : Hemşire ";}
    else if(rol==3){newAider.aiderID= "$a Yeni Kurtarıcı : Sertifika Sahibi ";}

    markerList.removeWhere((element) => element.markerId.toString().contains(selectedMarkerId!));

    function_addMarker(newAider.startPosition, newAider.aiderID,rol:newAider.aiderType);

    aiderList.add(newAider);
    selectedMarkerId= newAider.aiderID;
    assigmentAider = false;
    setState(() {});

  }
  function_addMarker(LatLng positionInfo,String id,{int rol = 0}){
    BitmapDescriptor icon1 = BitmapDescriptor.defaultMarker;
    if(rol==0){}
    if(rol==1)
    {
      icon1 = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
    else if(rol==2)
    {
      icon1 = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
    }
    else if(rol==3)
    {
      icon1 = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    else if(rol==7)
    {
      icon1 = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
    if(id.contains(kod1))
      {
        id=id.replaceAll(".", "-");
      }
    setState(() {
      markerList.add(Marker(
        markerId: MarkerId(id),
        position: positionInfo,
        draggable: rol!=7 ?true:false,
        icon: icon1,
        infoWindow: rol!=7 ? InfoWindow():InfoWindow(title: "Henüz Vakaya Ulaşılmadı."),
        onDragEnd: (endPosition){
           funtion_onDrag_Markers(endPosition, id);
        },
        onTap: (){
          if(rol==7){selectedMarkerId==null;}
          else
          {
              selectedMarkerId = id;
              if (selectedMarkerId!.contains(kod1) == false) {
                for (Aider aiderPerson in aiderList) {
                  if (aiderPerson.aiderID == selectedMarkerId) {
                    if (aiderPerson.accept_rejectSaving != 0) {
                      if (aiderPerson.activeAndCaseNumber != 0) {
                        selectedAider = null;
                        setState(() {});
                      } else {
                        selectedAider = aiderPerson.accept_rejectSaving;
                        setState(() {});
                      }
                    } else {
                      selectedAider = null;
                      setState(() {});
                    }

                    break;
                  }
                }
              }
              for (var element in ecList) {
                if (element.ID.contains(selectedMarkerId!)) {
                  bildirimYapti = true;
                  setState(() {});
                  break;
                } else {
                  bildirimYapti = false;
                  setState(() {});
                }
              }
              print(selectedMarkerId);
              setState(() {});
              //function_createEmergencyCase(oneClick, 0);

            }
          },


      ),);
    });
  }
  //when create marker, use in onDrag
  funtion_onDrag_Markers(LatLng endPosition, String id){
    print("end position: $endPosition");
    selectedMarkerId=id;
    for(int a=0;a<markerList.length;a++){
      if(markerList[a].markerId.toString().contains(id)){
        markerList.removeAt(a);
        if(id.contains(kod1)){
          function_addMarker(endPosition, id);
          print("markerlist position:");
          print(markerList.last.position);
        }
        else{

          for(int a=0;a<aiderList.length;a++){

            if(aiderList[a].aiderID.contains(id))
            {
              aiderList[a].startPosition = endPosition;
              aiderList[a].currentPosition=aiderList[a].startPosition;
              //LatLng changePosition = aiderList[a].startPosition;
              function_addMarker(endPosition, id,rol:aiderList[a].aiderType);
            }
          }
        }

      }
    }
  }
  function_findClosedPeople(LatLng dot,int emergencyNumber, {String priority ="1"}){
    for (var emcase in ecList) {
      if(emcase.caseNumber==emergencyNumber)
      {
        print("function_findClosedPeople");
        for (var aiderPerson in aiderList) {
          if(aiderPerson.currentPosition!=null)
          {
            if(priority == "1")
            {
              if (calculateDistance(aiderPerson.currentPosition!, dot) < 0.500) {
                if (emcase.ec_aiderList.contains(aiderPerson)) {
                } else {
                  //check kontrol kime atanması gerekiyor...!!!!!
                  if (aiderPerson.activeAndCaseNumber != 0) {
                    //kisiye bildirim gönderilecek,//send message to aider
                    aiderPerson.emergencyCases.add(emergencyNumber);
                    emcase.wantSaving.add(aiderPerson);
                  } else {
                    //send message to aider
                    aiderPerson.emergencyCases.add(emergencyNumber);
                    aiderPerson.accept_rejectSaving = emcase.caseNumber;
                    emcase.ec_aiderList.add(aiderPerson);
                  }
                }
              }
            }
            else if(priority=="2")
            {
              if (calculateDistance(aiderPerson.currentPosition!, dot) < 1.000) {
                if (emcase.ec_aiderList.contains(aiderPerson)) {
                } else {
                  //check kontrol kime atanması gerekiyor...!!!!!
                  if (aiderPerson.activeAndCaseNumber != 0) {
                    //kisiye bildirim gönderilecek,//send message to aider
                    aiderPerson.emergencyCases.add(emergencyNumber);
                    emcase.wantSaving.add(aiderPerson);
                  } else {
                    //send message to aider
                    aiderPerson.emergencyCases.add(emergencyNumber);
                    aiderPerson.accept_rejectSaving = emcase.caseNumber;
                    emcase.ec_aiderList.add(aiderPerson);
                  }
                }
              }
            }
           
          }
        }
        int a =emcase.ec_aiderList.length;
        if(emcase.ec_aiderList.length==0) {
          //want listesi
          print("wait");
          //sleep(Duration(seconds:5));
          print("number of aider on duty");
          print(emcase.wantSaving.length);
          print("bekleme test");
          if (priority == "1")
          {
            Timer.periodic(const Duration(seconds: 15), (timer) {
              print(timer);
              print(timer.tick);
              if (timer.tick == 1) {
                print("delayed");
                if (emcase.firstAider == null) {
                  print("deleyad  atama");
                  funtion_assigmentAidertoEC_noAiderSituation(
                      emcase.casePosition, emcase.wantSaving,
                      emcase.caseNumber);
                  if (emcase.firstAider == null) {
                    int Index = emcase.caseNumber - 1;
                    function_createEmergencyCase(
                        ecList[Index].casePosition,
                        ecList[Index].caseType,
                        ecList[Index].goldenTime,
                        ecList[Index].ID,
                        m_priority: "2");
                    broadcastAgain(emcase, priority: "2");
                    Circle cl = (Circle(
                      circleId: CircleId((emcase.caseNumber).toString()),
                      center: emcase.casePosition,
                      radius: 1000,
                      fillColor: Colors.redAccent.withOpacity(0.1),
                      strokeColor: Colors.black54,
                      strokeWidth: 2,
                    ));
                    emcase.caseCircleList[0] = cl;
                    function_reviewAssignments(ecList[Index].caseNumber);
                  }
                }
              }
              else {
                timer.cancel();
              }
            });
        }
              //t.cancel();
        }
        print("ulaşabilecek kurtarıcı sayısı $a");
      }
    }
  }
  int findIndex_ECN(int caseNumber)
  {
    int rv = ecList.indexWhere((element) => element.caseNumber==caseNumber);
    return rv;
  }
  void broadcastAgain(EmergencyCase ec,{String priority="1"})
  {
    List<String> vakalar=[];
    aiderList.forEach((element) {if(element!=" "){vakalar.add(element.aiderID);} });
    ecList.forEach((element) {if(element!=" "){vakalar.add(element.ID);}});
    sendECInfo(ec.casePosition.latitude.toString(),ec.casePosition.longitude.toString(), ec.caseType.toString(),priority,vakalar);
  }
  function_reviewAssignments(int emergencyCaseNumber)
  {
    int index = findIndex_ECN(emergencyCaseNumber);

    ecList[index].ec_aiderList.forEach((element)
    {
        print(ecList[index].ec_aiderList.toString());
      /*if(ecList[index].firstAider!=null){ecList[index].firstAider!.currentPosition=const LatLng(0, 0);}
      if(ecList[index].secondAider!=null){ecList[index].secondAider!.currentPosition=const LatLng(0, 0);}*/
      if( ecList[index].ID!=" ") {
        for (var aider in aiderList) {
          if (aider.aiderID == element.aiderID) {
            if (aider.wntHlp == true) {
              function_assignmentAidertoEC(aider, false);
            }
          }
        }
      }
    });

  }
  funtion_assigmentAidertoEC_noAiderSituation(LatLng casePosition, List<Aider> wantSavingListofEC,int cn)
  {
    String closerAider="null";
    int priority=10;
    int oldCaseNumber=0;
    double distance= 0.550;
    print("noAiderSituation :: start loop ");
    for(var Aider_nAS in wantSavingListofEC)
      {
        String IDD= Aider_nAS.aiderID;
        print("noAiderSituation :: in loop :: Aider ID = $IDD ");
        print(calculateDistance(casePosition, Aider_nAS.currentPosition!));
        if(distance>calculateDistance(casePosition, Aider_nAS.currentPosition!))
          {
            print("noAiderSituation :: loop :: 1");
            if(ecList[(Aider_nAS.activeAndCaseNumber)-1].firstAider!.aiderID==Aider_nAS.aiderID&&ecList[(Aider_nAS.activeAndCaseNumber)-1].secondAider!=null)
            {
              //sss*112*
              print("noAiderSituation :: loop :: 2");
              if(calculateDistance(casePosition, Aider_nAS.currentPosition!)>0.050) {
                print("noAiderSituation :: loop :: 3");
                double dd = (
                    calculateDistance(ecList[(Aider_nAS.activeAndCaseNumber) - 1].casePosition,
                    ecList[(Aider_nAS.activeAndCaseNumber) - 1].firstAider!.currentPosition!)
                        -
                    calculateDistance(ecList[(Aider_nAS.activeAndCaseNumber) - 1].casePosition,
                    ecList[(Aider_nAS.activeAndCaseNumber) - 1].secondAider!.currentPosition!));
                if (dd < 0) {
                  print("noAiderSituation :: loop :: 4");
                  dd.abs();
                }
                if (dd < 0.100)
                {   //düzelt
                  print("noAiderSituation :: loop :: 5");
                  if(priority==6)
                    {
                      print("noAiderSituation :: loop :: 6");
                      print("distance $distance" "firstAider distance");
                      print(calculateDistance(casePosition,ecList[(Aider_nAS.activeAndCaseNumber) - 1].firstAider!.currentPosition!));
                      if((calculateDistance(casePosition,ecList[(Aider_nAS.activeAndCaseNumber) - 1].firstAider!
                          .currentPosition!)-distance).abs()<0.100)
                        {
                          print("noAiderSituation :: loop :: 7");
                          //atla
                        }
                      else
                        {
                          print("noAiderSituation :: loop :: 8");
                          //
                          priority = 7;
                          oldCaseNumber=Aider_nAS.activeAndCaseNumber;
                          closerAider = Aider_nAS.aiderID;
                          distance = calculateDistance(
                              casePosition,
                              ecList[(Aider_nAS.activeAndCaseNumber) - 1]
                                  .firstAider!
                                  .currentPosition!);
                          print("first if $distance");
                        }
                    }
                  else
                    {
                      priority = 7;
                      oldCaseNumber=Aider_nAS.activeAndCaseNumber;
                      closerAider = Aider_nAS.aiderID;
                      distance = calculateDistance(
                          casePosition,
                          ecList[(Aider_nAS.activeAndCaseNumber) - 1]
                              .firstAider!
                              .currentPosition!);
                      print("first if $distance");
                    }
                }
                else
                  {
                    print("noAiderSituation :: loop :: 9");
                    //sent second aider
                    if(calculateDistance(casePosition,
                        ecList[(Aider_nAS.activeAndCaseNumber) - 1].secondAider!.currentPosition!)<0.500)
                    {
                      print("noAiderSituation :: loop :: 10");
                      priority=6;
                      oldCaseNumber=Aider_nAS.activeAndCaseNumber;
                      closerAider = ecList[(Aider_nAS.activeAndCaseNumber) - 1].secondAider!.aiderID;
                      distance= calculateDistance(casePosition,
                          ecList[(Aider_nAS.activeAndCaseNumber) - 1].secondAider!.currentPosition!);
                    }
                  }
              }
              else
              {
                print("noAiderSituation :: loop :: 11");
                if(calculateDistance(casePosition,
                    ecList[(Aider_nAS.activeAndCaseNumber) - 1].secondAider!.currentPosition!)<0.500)
                {
                  print("noAiderSituation :: loop :: 12");
                  priority=6;
                  oldCaseNumber=Aider_nAS.activeAndCaseNumber;
                  closerAider = ecList[(Aider_nAS.activeAndCaseNumber) - 1].secondAider!.aiderID;
                  distance= calculateDistance(casePosition,
                      ecList[(Aider_nAS.activeAndCaseNumber) - 1].secondAider!.currentPosition!);
                }
              }
            }
            else if(ecList[(Aider_nAS.activeAndCaseNumber)-1].secondAider!= null && ecList[(Aider_nAS.activeAndCaseNumber)-1].secondAider!.aiderID==Aider_nAS.aiderID)
            {
              print("noAiderSituation :: loop :: 13");
              priority=6;
              oldCaseNumber=Aider_nAS.activeAndCaseNumber;
              closerAider=Aider_nAS.aiderID;
              distance=calculateDistance(casePosition, Aider_nAS.currentPosition!);
              print("second if $distance");
            }
            else{print("nothing happen");}
          }
        else
          {
              if(priority==7)
                {
                  if(ecList[(Aider_nAS.activeAndCaseNumber)-1].secondAider!= null && ecList[(Aider_nAS.activeAndCaseNumber)-1].secondAider!.aiderID==Aider_nAS.aiderID)
                  {//"112* düzenlenecek"
                    if((calculateDistance(casePosition,ecList[(Aider_nAS.activeAndCaseNumber) - 1].secondAider!
                        .currentPosition!)-distance).abs()<0.100)
                     {
                       print("noAiderSituation :: loop :: 13xxx");
                       priority = 6;
                       oldCaseNumber = Aider_nAS.activeAndCaseNumber;
                       closerAider = Aider_nAS.aiderID;
                       distance =
                           calculateDistance(casePosition, Aider_nAS.currentPosition!);
                       print("second if $distance");
                     }
                  }
                }
          }
      }
    print("priorty = $priority closerAider = $closerAider distance = $distance oldCaseNumber = $oldCaseNumber => newCaseNumber = $cn");
    if(priority==10)
    {
      print("aktif görevde bulunan yok !!!!!!!!!!!!!!");
      //broadcast 1 km;
      return;
    }
    function_changeInfoAider(priority, closerAider, cn,ea:true);
    switch(priority)
    {
      case 6:
        for(var aider in aiderList)
        {
          if(aider.aiderID==closerAider)
          {
            aider.activeAndCaseNumber=cn;
            ecList[cn-1].firstAider=aider;
            if(false==ecList[cn-1].ec_aiderList.contains(aider))
            {
              ecList[cn-1].ec_aiderList.add(aider);
            }
            getPolyPoints(aider.currentPosition!,
                ecList[cn - 1].casePosition, cn,
                priority);
          }
        }
        ecList[oldCaseNumber - 1].casePolylineList[1]=const Polyline(polylineId: PolylineId("null"),points:[]);
        print(oldCaseNumber-1);
        ecList[oldCaseNumber - 1].secondAider = null;
         //bb

        break;
      case 7:
        for(var aider in aiderList)
        {
          if(aider.aiderID==closerAider)
          {
            print("switch 7 :: 1");
            aider.activeAndCaseNumber=cn;
            ecList[cn-1].firstAider=aider;
            if(ecList[cn-1].ec_aiderList.contains(aider))
              {
                ecList[cn-1].ec_aiderList.add(aider);
              }
            getPolyPoints(aider.currentPosition!,
                ecList[cn - 1].casePosition, ecList[cn - 1].caseNumber,
                7);
            print("switch 7 :: 2");
          }
        }
        ecList[oldCaseNumber - 1].firstAider = ecList[oldCaseNumber - 1].secondAider;
        print("switch 7 :: 3");
        getPolyPoints(ecList[oldCaseNumber - 1].firstAider!.currentPosition!, ecList[oldCaseNumber - 1].casePosition, oldCaseNumber, 7);
        print("switch 7 :: 4");
        ecList[oldCaseNumber - 1].casePolylineList[1]=const Polyline(polylineId: PolylineId("null"),points:[]);
        print("switch 7 :: 5");

        //***112*** burada kaynağı kullanılan acil durum için tekrar taratma yap ve yönlendir. her 10 saniye de tekrar atama yapan fonsiyonu yaz ve burada çalıştır.
        break;

    }

  }
  function_changeInfoAider(int sendType,String Id,int closedCase,{bool checkSecondTurn=false,bool ea=false,bool? coc,bool sk=false})
  {
    String isim=" ";
    String box="";
    if(sendType!=10) {
       if (closedCase != 0) {
        isim = ecList[closedCase - 1].ID;
      }
      box+= "activeCase;${isim};";
    }
    else
    {
        if(checkSecondTurn==false)
          {
            double distance=1;
            String caseId="";
            aiderList.forEach((element)
            {
              if(element.aiderID==Id)
              {
                element.emergencyCases.forEach((element2)
                {
                  if(distance>calculateDistance(element.currentPosition!,ecList.firstWhere((element3) => element3.caseNumber==element2).casePosition))
                  {
                    distance=calculateDistance(element.currentPosition!,ecList.firstWhere((element3) => element3.caseNumber==element2).casePosition);
                    caseId=ecList.firstWhere((element3) => element3.caseNumber==element2).ID;
                    closedCase=ecList.firstWhere((element3) => element3.caseNumber==element2).caseNumber;
                  }
                });
              }
            });
            isim=caseId;
            box+= "activeCase;${isim};";
            /*String gg="";
            List<int> loec=aiderList.firstWhere((element) => element.aiderID==Id).emergencyCases;
            for (int x=0;x<loec.length;x++)
            {
              String isim2="";
              if(x!=0){gg+="-";}
              if(closedCase!=0)
              {
                isim2 = ecList[closedCase-1].ID;
              }
              gg+=isim;
            }
            box+="activeCase;$gg;";*/
          }
        else if(checkSecondTurn==true)
          {
            double distance=1;
            String caseId="";
            aiderList.forEach((element)
            {
              if(element.aiderID==Id)
                {
                  element.emergencyCases.forEach((element2)
                  {
                     if(distance>calculateDistance(element.currentPosition!,ecList.firstWhere((element3) => element3.caseNumber==element2).casePosition))
                       {
                         distance=calculateDistance(element.currentPosition!,ecList.firstWhere((element3) => element3.caseNumber==element2).casePosition);
                         caseId=ecList.firstWhere((element3) => element3.caseNumber==element2).ID;
                         closedCase=ecList.firstWhere((element3) => element3.caseNumber==element2).caseNumber;
                       }
                  });
                }
            });
            isim=caseId;
            box+= "activeCase;${isim};";
          }
    }
    //activeCase;adk;birinci/ikinci/üçüncü;casetype
    // ecList[closedCase-1].ID;sendType(1,2,6,7:1!!!3,4:2);ecList[closedCase-1].caseType.toString()
    switch(sendType)
    {
      case 1:
        box+="1;${ecList[closedCase-1].caseType.toString()};";
        box+=kodATAMA(elzemAtama: ea,canOrcom: coc,sonKontrol: sk);
        setInfoAiderActiveCase("users/$Id/", box);
        break;
      case 2:
        box+="1;${ecList[closedCase-1].caseType.toString()};";
        {box+=kodATAMA(elzemAtama: ea,canOrcom: coc,sonKontrol: sk);}
        setInfoAiderActiveCase("users/$Id/", box);
        break;
      case 3:
        box+="2;${ecList[closedCase-1].caseType.toString()};";
        {box+=kodATAMA(elzemAtama: ea,canOrcom: coc,sonKontrol: sk);}
        setInfoAiderActiveCase("users/$Id/", box);
        break;
      case 4:
        box+="2;${ecList[closedCase-1].caseType.toString()};";
        {box+=kodATAMA(elzemAtama: ea,canOrcom: coc,sonKontrol: sk);}
        setInfoAiderActiveCase("users/$Id/", box);
        break;
      case 6:
        box+="1;${ecList[closedCase-1].caseType.toString()};";
        {box+=kodATAMA(elzemAtama: ea,canOrcom: coc,sonKontrol: sk);}
        setInfoAiderActiveCase("users/$Id/", box);
        break;
      case 7:
        box+="1;${ecList[closedCase-1].caseType.toString()};";
        {box+=kodATAMA(elzemAtama: ea,canOrcom: coc,sonKontrol: sk);}
        setInfoAiderActiveCase("users/$Id/", box);
        break;
      case 10:
        box+="3;${ecList[closedCase-1].caseType.toString()};";
        {box+=kodATAMA(elzemAtama: ea,canOrcom: coc,sonKontrol: sk);}
        setInfoAiderActiveCase("users/$Id/", box);
        break;
    }
  }
  String kodATAMA({bool elzemAtama=false,bool? canOrcom,bool sonKontrol=false,})
  {
    print("kodAtama 0");
    if(elzemAtama==true)
      {
        print("kodAtama 1");
        return "1;";
      }
    else if(canOrcom!=null&&canOrcom==true&&sonKontrol==true)
      {
        print("kodAtama 3");
        return "3;";
      }
    else if(canOrcom!=null&&canOrcom==false&&sonKontrol==true)
    {
        print("kodAtama 2");
        return "2;";
    }
    print("kodAtama last");
    return "";
  }
  function_assignmentAidertoEC(Aider wanttobeSaver,bool activeorpassive,{bool sonKontrol=false,bool? c_c})
  {
    int closerCase=0;
    int priority=10;
    double distance=1.550;
    print(wanttobeSaver.emergencyCases.length);


    for (var element in wanttobeSaver.emergencyCases)
    {
      if(ecList[element-1].ID!=" "){
      if(wanttobeSaver.activeAndCaseNumber==0||wanttobeSaver.activeAndCaseNumber==ecList[element-1].caseNumber)
      {
        print("priority 0 girdi checkpoint start for loop");
        print(calculateDistance(
            wanttobeSaver.currentPosition!, ecList[element - 1].casePosition));
        print(ecList[element - 1].caseNumber);
        //*112* element sayısı ecList temizlenmediği için çalışıyor fakat bunun düzeltimesi gerekir. element ile index bul
        if (ecList[element - 1].firstAider == null) {
          print("priority 1girdi checkpoint 1");
          if (distance >
                  calculateDistance(wanttobeSaver.currentPosition!,
                      ecList[element - 1].casePosition) ||
              (priority == 3 || priority == 4)) {
            print("priority 1 girdi checkpoint 2");
            closerCase = ecList[element - 1].caseNumber;
            priority = 1;
            distance = calculateDistance(wanttobeSaver.currentPosition!,
                ecList[element - 1].casePosition);
          }
        } else {
          if (ecList[element - 1].firstAider!.aiderID !=
                  wanttobeSaver.aiderID &&
              calculateDistance(wanttobeSaver.currentPosition!,
                      ecList[element - 1].casePosition) <
                  calculateDistance(
                      ecList[element - 1].firstAider!.currentPosition!,
                      ecList[element - 1].casePosition)) {
            print("priority 2 girdi checkpoint 1");
            if (priority >= 2) {
              print("priority 2 girdi checkpoint 2");
              closerCase = ecList[element - 1].caseNumber;
              priority = 2;
              distance = calculateDistance(wanttobeSaver.currentPosition!,
                  ecList[element - 1].casePosition);
            }
          } else if (ecList[element - 1].secondAider == null &&
              (ecList[element - 1].firstAider!.aiderID !=
                  wanttobeSaver.aiderID)) {
            print("priority 3 girdi checkpoint 1");
            if (distance >
                calculateDistance(wanttobeSaver.currentPosition!,
                    ecList[element - 1].casePosition)) {
              print("priority 3 girdi checkpoint 2");
              if (priority >= 3) {
                print("priority 3 girdi checkpoint 3");
                closerCase = ecList[element - 1].caseNumber;
                priority = 3;
                distance = calculateDistance(wanttobeSaver.currentPosition!,
                    ecList[element - 1].casePosition);
              }
            }
          } else if (ecList[element - 1].secondAider != null &&
              ((ecList[element - 1].firstAider!.aiderID !=
                      wanttobeSaver.aiderID) &&
                  (ecList[element - 1].secondAider!.aiderID !=
                      wanttobeSaver.aiderID))) {
            print("priority 4 girdi checkpoint 1");
            if (calculateDistance(wanttobeSaver.currentPosition!,
                    ecList[element - 1].casePosition) <
                calculateDistance(
                    ecList[element - 1].secondAider!.currentPosition!,
                    ecList[element - 1].casePosition)) {
              print("priority 4 girdi checkpoint 2");
              if (priority >= 4) {
                print("priority 4 girdi checkpoint 3");
                closerCase = ecList[element - 1].caseNumber;
                priority = 4;
                distance = calculateDistance(wanttobeSaver.currentPosition!,
                    ecList[element - 1].casePosition);
              }
            }
          }
        }
      }
      else
      {print("başka durum değişikliğği olmaz");}
    }
    }
    print("passive::=> priority: $priority distance: $distance caseNumber: $closerCase");
    bool cpn=false;
    if(priority==10)
    {
      if(wanttobeSaver.activeAndCaseNumber!=0&&(ecList[wanttobeSaver.activeAndCaseNumber-1].firstAider!.aiderID==wanttobeSaver.aiderID||ecList[wanttobeSaver.activeAndCaseNumber-1].secondAider!.aiderID==wanttobeSaver.aiderID))
      {
        cpn=true;
      }
    }
    if(cpn==false) {
      if (priority != 10) {
        function_changeInfoAider(priority, wanttobeSaver.aiderID, closerCase,
            coc: c_c, sk: sonKontrol);
      } else if (priority == 10) {
        function_changeInfoAider(priority, wanttobeSaver.aiderID, closerCase,
            checkSecondTurn: activeorpassive, coc: c_c, sk: sonKontrol);
      }
    }
    atla:
        switch(priority)
        {
          case 1:
                print("priority:passive:c1::cp1");
                for(var aider in aiderList)
                  {
                    if(aider.aiderID==wanttobeSaver.aiderID)
                      {
                        aider.wntHlp=true;
                        aider.activeAndCaseNumber =closerCase;
                      }
                  }
                wanttobeSaver.activeAndCaseNumber = closerCase;
                ecList[closerCase - 1].firstAider = wanttobeSaver;
                getPolyPoints(wanttobeSaver.currentPosition!,
                ecList[closerCase - 1].casePosition, closerCase, priority);
                if(ecList[closerCase - 1].secondAider!=null&&ecList[closerCase - 1].secondAider!.aiderID==wanttobeSaver.aiderID)
                  {ecList[closerCase - 1].secondAider==null;}
            break;
          case 2:
          //bb buada kaldın!!!**** 241122
                print("priority:passive:c2::cp1");
                for(var aider in aiderList)
                {
                  if(aider.aiderID==wanttobeSaver.aiderID)
                  {
                    aider.wntHlp=true;
                    aider.activeAndCaseNumber =closerCase;
                  }
                }
                wanttobeSaver.activeAndCaseNumber = closerCase;
                for (var element in aiderList) {
                  if (ecList[closerCase - 1].firstAider!.aiderID == element.aiderID) {
                    element.activeAndCaseNumber = closerCase;
                    //element.accept_rejectSaving = 0;
                    ecList[closerCase - 1].firstAider=wanttobeSaver;
                    if(ecList[(element.activeAndCaseNumber-1)].secondAider!=null &&wanttobeSaver.aiderID==ecList[(element.activeAndCaseNumber-1)].secondAider!.aiderID)
                      {
                        ecList[(element.activeAndCaseNumber-1)].secondAider!.activeAndCaseNumber=0;
                        ecList[(element.activeAndCaseNumber-1)].secondAider=null;
                        ecList[(element.activeAndCaseNumber-1)].casePolylineList[1]=new Polyline(polylineId: PolylineId("null"));
                      }
                    element.activeAndCaseNumber = 0;
                    function_assignmentAidertoEC(element, true);
                    break;
                  }
                }
                ecList[closerCase - 1].firstAider = wanttobeSaver;
                getPolyPoints(wanttobeSaver.currentPosition!,
                    ecList[closerCase - 1].casePosition, closerCase, priority);
            break;
          case 3:
            print("priority:passive:c3::cp1");
            for(var aider in aiderList)
            {
              if(aider.aiderID==wanttobeSaver.aiderID)
              {
                aider.wntHlp=true;
                aider.activeAndCaseNumber =closerCase;
              }
            }
            wanttobeSaver.activeAndCaseNumber = closerCase;
            ecList[closerCase - 1].secondAider = wanttobeSaver;
            getPolyPoints(wanttobeSaver.currentPosition!,
                ecList[closerCase - 1].casePosition, closerCase, priority);
            break;
          case 4:
              print("priority:passive:c4::cp1");
              for(var aider in aiderList)
              {
                if(aider.aiderID==wanttobeSaver.aiderID)
                {
                  aider.wntHlp=true;
                  aider.activeAndCaseNumber =closerCase;
                }
              }
              wanttobeSaver.activeAndCaseNumber = closerCase;
              for (var element in aiderList) {
                if (ecList[closerCase - 1].secondAider!.aiderID ==
                    element.aiderID) {
                  element.activeAndCaseNumber = 0;
                  element.accept_rejectSaving = 0;
                  print("4.case");
                  function_assignmentAidertoEC(element,true);
                  break;
                }
              }
              ecList[closerCase - 1].secondAider = wanttobeSaver;
              getPolyPoints(wanttobeSaver.currentPosition!,
                  ecList[closerCase - 1].casePosition, closerCase,
                  priority); //bb

            break;
          case 10:
            print("daha yakın kurtarıcılar var"); //bu durum ile herhangi bir yakınlığı bulunmayan kaynak boşa çıkartılır *112*
            //daha hızlı ulaşabileceksen yardım et gönder (vaka konumu ve yardımcıların konumu) buton ekle
            break;
          default:
            print("priority:: Hata var!!!");
            break;
        }
  }
  function_wantSavePerson(String AiderID,int acceptCase){
    //en yakın vakayı bul  //*112* accept Case durumunu duzenle
    print("assignmenyAidertoEC GİRDİ");
    function_assignmentAidertoEC(aiderList.firstWhere((element) => element.aiderID==AiderID),false);
    print("assignmenyAidertoEC cikti");
  }
  function_createEmergencyCase(LatLng marker, int function_caseType,DateTime goldenTime,String person,{bool check1=true,String m_priority="1"}){
    print("perspn:$person");
    bool check=false;
    ecList.forEach((element) {
      if(element.ID==person)
        {
          check=true;
          function_findClosedPeople(element.casePosition, element.caseNumber,priority: m_priority );
          emergencyCaseChange(element.caseNumber);
        }
    });
    if(marker != null && check==false) {
      print(goldenTime);
      EmergencyCase ec = new EmergencyCase();
      ec.ID=person;//***112-----------------------------------------------
      ec.casePosition = marker;
      ec.caseNumber = (counter + 1);
      ec.caseType = function_caseType;
      ec.goldenTime=goldenTime;
      Circle cl = (
          Circle(
            circleId: CircleId((ec.caseNumber).toString()),
            center: marker,
            radius: 500,
            fillColor: Colors.greenAccent.withOpacity(0.3),
            strokeColor: Colors.red,
            strokeWidth: 2,

          ));
      ec.caseCircleList.add(cl);
      if(check1==true)
      {
        sendLocationInfo(ec.caseType, ec.ID,ec.casePosition);
      }
      ecList.add(ec);
      List<String> vakalar =[];
      aiderList.forEach((element) {if(element!=" "){vakalar.add(element.aiderID);} });
      ecList.forEach((element) {if(element!=" "){vakalar.add(element.ID);}});
      sendECInfo(ec.casePosition.latitude.toString(),ec.casePosition.longitude.toString(), ec.caseType.toString(),"1",vakalar);
      counter++;
      print(ec.ID);
      acilDurumButonuEkle(ec.caseNumber.toString());
      print("create ec__________________________________________");
      function_findClosedPeople(marker, ec.caseNumber);
      emergencyCaseChange(ec.caseNumber);

      setState(() {});
    }
  }
  void loadAiderList(){
    BitmapDescriptor iconMarker = BitmapDescriptor.defaultMarker;

    for(int a = 1; a <1001; a++){
      Aider aid = new Aider();
      aid.aiderID="$a.Doctor";
      aid.aiderType=1;
      aid.startPosition= generateLatitude();
      aid.currentPosition=aid.startPosition;
      aiderList.add(aid);
    }
    for(int a = 1; a <1001; a++){
      Aider aid = new Aider();
      aid.aiderID="$a.Nurse";
      aid.aiderType=2;
      aid.startPosition= generateLatitude();
      aid.currentPosition=aid.startPosition;
      aiderList.add(aid);
    }
    for(int a = 1; a <1001; a++){
      Aider aid = new Aider();
      aid.aiderID="$a.HK";
      aid.aiderType=3;
      aid.startPosition= generateLatitude();
      aid.currentPosition=aid.startPosition;
      aiderList.add(aid);
    }

    aiderList.forEach((aid) {
      function_addMarker(aid.startPosition,aid.aiderID,rol:aid.aiderType);
    });

    setState(() {});

  }
  //marker funtions
  markerFunction(LatLng endPosition,Aider aid){
    print(endPosition);
    print(aid.aiderID);
    print(aid.aiderType);
  }
  //start => generate random location
  LatLng generateLatitude(){
    double beforeDot=0;
    double afterDot=0;
    double last=0;
    double latitude;
    double longitude;

    beforeDot=randomNumber(39,41).toDouble();
    //39.724216, 32.517448 sol alt
    // 40.088256, 32.998599 sağ üst
    if(beforeDot==40)
      {
        afterDot=randomNumber(0, 90).toDouble();

      }
    else
    {
      afterDot=randomNumber(723, 1000).toDouble();

    }

    last= randomNumber(100, 1000).toDouble();
    //last operation
    afterDot = afterDot/1000;
    last= last/1000000;
    latitude = beforeDot+afterDot+last;

    //39.724216, 32.517448 sol alt
    // 40.088256, 32.998599 sağ üst
    beforeDot=32;
    afterDot=randomNumber(517, 999).toDouble();
    last= randomNumber(100, 1000).toDouble();
    //last operation
    afterDot = afterDot/1000;
    last= last/1000000;
    longitude = beforeDot+afterDot+last;

    LatLng ll= LatLng(latitude, longitude);
    return ll;
  }
  int randomNumber(int minValue, int maxValue){
    var random = new Random();
    int result = minValue + random.nextInt(maxValue - minValue);
    return result;
  }
  //end grl
  double calculateDistance(LatLng one, LatLng two){
    mp.LatLng source = mp.LatLng(one.latitude, one.longitude);
    mp.LatLng destination = mp.LatLng(two.latitude, two.longitude);

    double distance =mp.SphericalUtil.computeDistanceBetween(source, destination)/1000;
    //print('Distance between Aider and Ill is $distance km.');
    return distance;
  }
  LatLng changeStringToLatlng(String location)
  {
    double? latitude;
    double? longitude;
    String a = location.replaceAll('-', '.');
    List<String> data= a.split(';');
    latitude=double.parse(data[0]);
    longitude=double.parse(data[1]);
    LatLng ready= new LatLng(latitude!, longitude!);
    print(ready);
    return ready;
  }

  List<data> seperatedData(String aa,String first,String second)
  {

    aa=aa.replaceAll('{', '');
    aa=aa.replaceAll('}', '');
    List<String> bb=aa.split(first);
    List<data> last=[];
    bb.forEach((element) {List<String>cc=element.split(second);data dd = new data();dd.key=cc[0].trim();dd.value=cc[1].trim();last.add(dd); });

    return last;

  }
  void createEmergencyCase(String ID) async {

    print("girdi create ec");

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('acilDurumListesi/$ID').get();
    if (snapshot.exists) {
      print("var");
      print(snapshot.value.toString());
      List<data> readytouse=seperatedData(snapshot.value.toString(), ',', ':');
      function_addMarker(
          changeStringToLatlng(readytouse.firstWhere((element) => element.key=="location").value.toString()),
          ID,
          rol:7);
      //datatime ekle veri tabanına
      function_createEmergencyCase(
          changeStringToLatlng(readytouse.firstWhere((element) => element.key=="location").value.toString()),
          int.parse(readytouse.firstWhere((element) => element.key=="ecType").value.toString()),
          new DateTime.now(),
          readytouse.firstWhere((element) => element.key=="ill").value.toString(),check1:false);
      print(snapshot.value.toString());
    } else {
      print('null');
    }
  }
  /*void listenAddedKL(String ecnumber) {
    print("dinliyor KL $ecnumber");
    DatabaseReference setref=FirebaseDatabase.instance.ref();
    DatabaseReference ref = FirebaseDatabase.instance.ref(ecnumber);
    Stream<DatabaseEvent> stream = ref.onChildAdded;
    stream.listen((DatabaseEvent event) {
      Object? s_s = event.snapshot.value;
      //Map<bool,String,bool,String,bool,int> ecObject= jsonDecode(s_s);
      print("Eklenen ANAHTAR: ${event.snapshot.key} :$s_s");
      print("Eklenen DEGER: ${event.snapshot.value} :$s_s");
      //function_assignmentAidertoEC();
      /*print('Event Type: ${event.type}'); // DatabaseEventType.value;
    print('Snapshot: ${event.snapshot}'); // DataSnapshot*/

    });
  }*/
  void listenAddedRKL(String ecnumber) {
    print("dinliyor RKL $ecnumber");
    DatabaseReference setref=FirebaseDatabase.instance.ref();
    DatabaseReference ref = FirebaseDatabase.instance.ref(ecnumber);
    Stream<DatabaseEvent> stream = ref.onChildAdded;
    stream.listen((DatabaseEvent event) {
      String s_s = event.snapshot.key.toString();
      //Map<bool,String,bool,String,bool,int> ecObject= jsonDecode(s_s);
      print("Eklenen ANAHTAR: ${event.snapshot.key} :$s_s");
      markerList.removeWhere((element) => element.markerId.value.toString()==s_s);
      aiderList.removeWhere((element) => element.aiderID==s_s);
      ecList.forEach((element)
      {
        element.ec_aiderList.removeWhere((number) => number.aiderID==s_s);
        if(element.firstAider!=null&&element.firstAider!.aiderID==s_s){element.firstAider=null;element.casePolylineList[0]=const Polyline(polylineId: PolylineId(""),width: 0);setState(() {});function_reviewAssignments(element.caseNumber);}
        else if(element.secondAider!=null&&element.secondAider!.aiderID==s_s){element.secondAider=null;element.casePolylineList[1]=const Polyline(polylineId: PolylineId(""),width: 0);setState(() {});function_reviewAssignments(element.caseNumber);}
      });

      readKlIndex(s_s).then((value)
      {
        final klremove=setref.child("KL/$value");
        klremove.remove();
      } );
    });
  }
  void listenAddedEmergencyCase(String ecnumber) {
    print("dinliyor");
    String ecnumber_final;
    DatabaseReference ref = FirebaseDatabase.instance.ref(ecnumber);
    Stream<DatabaseEvent> stream = ref.onChildAdded;
    stream.listen((DatabaseEvent event) {
      String uyarlama= event.snapshot.key.toString();
      Object? s_s = event.snapshot.child(uyarlama).value;
      //Map<bool,String,bool,String,bool,int> ecObject= jsonDecode(s_s);
      print("Eklenen Deger: ${event.snapshot.key} :$s_s");
      ecnumber_final=event.snapshot.key.toString();
      if(s_s.toString()=="true")
        {
          ecList.forEach((element) {print(element.ID);});
          if(null==ecList.firstWhereOrNull((element) => element.ID==ecnumber_final))
          {
            print("checkPoiint");
            print(ecList.firstWhereOrNull((element) => element.ID==ecnumber_final));
            createEmergencyCase(ecnumber_final);
          }
        }
      else if(s_s.toString()=="false")//itv=iptal edilen/tamamlanan vakalar
        {
          print("girdi add list");
          ecList.forEach((element1y) {
            print("bb");
            if(element1y.ID==ecnumber_final){
              print("aa");
              element1y.ID=" ";
              aiderCheckEnvironment(element1y.caseNumber,ecnumber_final);
              acilListe.remove(acilListe.firstWhere((element2x) => element2x.key.toString().contains(element1y.caseNumber.toString())));
              markerList.removeWhere((item) => item.markerId.toString().contains(event.snapshot.key.toString()));
              //sendInfoRealAidersForCCC(event.snapshot.key.toString(),element1y.caseNumber);
              emergencyCaseChange(0);
            }
          });
        }


      //02012023 degişikliği
      /*print('Event Type: ${event.type}'); // DatabaseEventType.value;
    print('Snapshot: ${event.snapshot}'); // DataSnapshot*/

    });
  }
  void ListenKLdirectory()
  {
   /* setref.child("/KL/1").set(
        {
          '${event.snapshot.key.toString()}':null,
        }
    );
    Stream<DatabaseEvent> stream2=setref.child("/KL/${event.snapshot.key.toString()}").onChildAdded;*/
    DatabaseReference setref=FirebaseDatabase.instance.ref();
    Stream<DatabaseEvent> stream2=setref.child("/KL/").onChildAdded;
    stream2.listen((event) {
      Object? s_s2 = event.snapshot.value;
      print("Eklenen Deger_KL: ${event.snapshot.key} :$s_s2");
      Aider realAider= new Aider();
      realAider.aiderID=event.snapshot.key.toString();
      realAider.aiderType=1;
      realAider.wntHlp=true;
      aiderList.add(realAider);
      setValueInRealAider(event.snapshot.key.toString());
      removerklValue(event.snapshot.key.toString());
    });
  }
  void setValueInRealAider(String id)
  {
    for (var element in aiderList)
    {
      if(element.aiderID==id)
        {
          readAiderType("users/$id/type").then((value) {
            element.aiderType=int.parse(value);
            print("tipi yüklendi");
            readAiderId("users/$id/location").then((value)
            {
              element.currentPosition=yadanfo(value);
              print("konum yüklendi");
              function_addRealAiderMarker(element.aiderID,element.currentPosition!,rol:element.aiderType);//düzeltilecek 112***
              for (var ec in ecList)
              {
                if(ec.ID!=" ") {
                if (calculateDistance(
                        element.currentPosition!, ec.casePosition) <
                    1.500) {
                  element.emergencyCases.add(ec.caseNumber);
                  ec.ec_aiderList.add(element);
                  ec.wantSaving.add(element);
                  print("ilgili listelere yuklendi");
                }
              }
            }
              function_assignmentAidertoEC(element, false);
              print("atama yapıldı");
              //fonksiyona gönder
            });
          });

        }
    }

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
      String uyarlama= event.snapshot.key.toString();
      Object? s_s = event.snapshot.child(uyarlama).value;
      String kimlik=event.snapshot.key.toString();
      String adl_aop= event.snapshot.child(uyarlama).value.toString();
      print("cp1111");
      if(adl_aop=="false")//itv
        {
          print("girdi");
          ecList.forEach((element1y) {
            print("bb");
            if(element1y.ID==kimlik) {
              String a=element1y.ID;
              print(a);
              print(kimlik);
              if (a == kimlik) {
                print("aa");
                element1y.ID = " ";
                aiderCheckEnvironment(element1y.caseNumber,kimlik);
                acilListe.remove(acilListe.firstWhere((element2x) =>
                    element2x.key.toString().contains(
                        element1y.caseNumber.toString())));
                markerList.removeWhere((item) =>
                    item.markerId.toString().contains(kimlik));
                //sendInfoRealAidersForCCC(kimlik, element1y.caseNumber);
                emergencyCaseChange(0);
              }
            }
          });
        }
      else if (adl_aop=="true")
        {
          if(null==ecList.firstWhereOrNull((element) => element.ID==event.snapshot.key.toString()))
          {
            print(ecList.firstWhereOrNull((element) => element.ID==event.snapshot.key.toString()));
            print("checkPoiiiiint");
            createEmergencyCase(event.snapshot.key.toString());
          }
        }
      //Map<bool,String,bool,String,bool,int> ecObject= jsonDecode(s_s);
      //iptal edilme kısmı burada gerçekleşecek
      print("kimlik $kimlik, aop:$adl_aop");
      print("Değiştirilen Deger: ${event.snapshot.key} :$s_s");
    });
  }
  void sendInfoRealAidersForCCC(String ecPersonId,int ecCaseNumber)
  {
    EmergencyCase? ec = ecList.firstWhereOrNull((eCase) => eCase.caseNumber==ecCaseNumber);
    print("ccc:1");
    if(ec!=null&&ec.ec_aiderList.isNotEmpty)
      {
        ec.ec_aiderList.forEach((asAider)
        {
           aiderList.forEach((element) {
             if(element.aiderID==asAider.aiderID)
              {
                /*if(element.emergencyCases.length>0)
                  {
                    /*element.emergencyCases.removeWhere((element) => element==ec.caseNumber);
                    function_assignmentAidertoEC(element, false);*/
                  }*/
                /*else */if(element.emergencyCases.length==0)
                  {
                    readCancelorCompleteandSetInfo(ecPersonId).then((value) {
                      if(value==false)
                        {
                          setInfoAiderActiveCase("users/${element.aiderID}", "activecase;iptalEdildi;4;100");
                        }
                      else if(value==true)
                        {
                          setInfoAiderActiveCase("users/${element.aiderID}", "activecase;Tamamlandı;5;100");
                          readInfoIll("acilDurumListesi/$ecPersonId/info").then((value)
                          {
                            print("MARKER EKLEME ÇALIŞTI ------------------------------");
                            function_addRealAiderMarker(ecPersonId,element.currentPosition!,rol:10,info:value);
                          });
                        }
                      else if(element.emergencyCases.length==0){print("vakada atanan kurtarıcı bulunamadı");}
                      else{print("hhhhhhhhhhhhhhhhata____________var");}
                    });
                  }
              }
           });
        });
      }
    else if(ec!=null&&ec.ec_aiderList.isEmpty){
      print("Vakada atanacak kurtarıcı bulunamadı");
    }
    else{
      print("hata var___________________________VAKA BULUNAMADI________________");
    }
  }
  void close()
  {
    DatabaseReference ref = FirebaseDatabase.instance.ref('ADL');
    ref.onDisconnect();
  }
  function_addRealAiderMarker(String id,LatLng xy,{int rol = 0,String? info}){
    BitmapDescriptor icon1 = BitmapDescriptor.defaultMarker;
    if(rol==0){}
    if(rol==1)
    {
      icon1 = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta);
    }
    else if(rol==2)
    {
      icon1 = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
    else if(rol==3)
    {
      icon1 = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
    else if(rol==7)
    {
      icon1 = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
    else if(rol==10)
    {
      icon1 = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
    for (var element in aiderList)
    {
          print(id);
          setState(() {
            markerList.add(Marker(
              markerId: MarkerId(id),
              position: xy,
              draggable: false,
              icon: icon1,
              infoWindow: info==null ? const InfoWindow(title:""):InfoWindow(title: "$id kişisine ulaşıldı.",snippet: info),
              onTap: (){
                selectedMarkerId = null;
                setState(() {});
              },
            ),);
          });
          break;
    }
  }
}
