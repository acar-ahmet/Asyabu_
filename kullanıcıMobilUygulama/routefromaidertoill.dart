import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:bitirme_projesi_iki/cevirici.dart';
import 'package:bitirme_projesi_iki/firebaseOperation.dart';
import 'package:bitirme_projesi_iki/locationOperations.dart';
import 'package:bitirme_projesi_iki/messageOperations.dart';
import 'package:bitirme_projesi_iki/polyoperations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'declareEmergencyCase.dart';

class MapSample extends StatefulWidget {
  late String UserID;
  MapSample(String userID, {super.key}){
    UserID=userID;
  }
  @override
  State<MapSample> createState() => MapSampleState(UserID);
}

class MapSampleState extends State<MapSample> {
  final TextEditingController _cepController = TextEditingController();
  late final List<bool> _selections; /*=List.generate(3, (_) => false);*/
  late Timer mytimer;
  late Timer followtimer;
  String? adress;
  bool adresscheck =false;
  bool check_pop=false;
  String ill_info="";
  List<Polyline> listPoly=[];
  List<String> listOfEC=[];
  String? UserID;
  String? as_ecn;
  List<Marker> markerList= [];
  LatLng? ll;
  LatLng ecll=const LatLng(0, 0);
  bool followingCheck=true;
  bool waitinglLoadInfo=false;
  bool vazgecVerify = false;
  bool vazgecButonOnpress = false;
  bool vazgecButonText = false;
  Circle myCircle = const Circle(circleId: CircleId("myCircle"));
  Marker myMarker =const Marker(markerId: MarkerId("myLocation"));
  Marker target =const Marker(markerId: MarkerId("illLocation"));
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  MapSampleState(String userID){UserID=userID;}
  @override
  void initState() {
    // TODO: implement initState
    mytimer = Timer.periodic(Duration(seconds: 3), (timer) {checkLoadInfo();setState(() {});});
    adress ="Gazi Apartman??, Daire 9";
    super.initState();
    //learnMyLocationOnce();
    //Firebase.initializeApp();
    learnMyLocationAlways();
    followtimer = Timer.periodic(const Duration(seconds: 3), (timer) {loadECLocations();setState(() {});});
  }
  //aktif dinleme ile durumunun de??i??ip de??i??medi??ini kontrol et.
  loadECLocations()
  {
    readLocationofCases("users/$UserID/activeCase").then((ecn)
    {
      //Fluttertoast.showToast(msg: UserID.toString());
      if(null != as_ecn&&as_ecn!="waitForIll")
      {
        List<String> data1 = ecn.split(";");
        List<String> data2 = as_ecn!.split(";");

        if(data2.length>1 && data1[1]!=data2[1])
        {
          if(data1[1]=="iptalEdildi")
            {
              Fluttertoast.showToast(msg: "Durum ??ptal Edildi");
            }
          else if(data1[1]=="Tamamland??")
            {
              Fluttertoast.showToast(msg: "Durum Tamamland??");
            }
          else
            {
              Fluttertoast.showToast(msg: "Vaka De??i??tirildi.");
              if(data1[4]=="1")
                {
                  Fluttertoast.showToast(msg: "??evresinde Kurtar??c?? Olmayan Vakaya Y??nlendirildin.");
                }
              else if(data1[4]=="2")
                {
                  Fluttertoast.showToast(msg: "Durum iptal edildi. Ba??ka Vakaya Y??nlendirildin.");
                }
              else if(data1[4]=="3")
              {
                Fluttertoast.showToast(msg: "Vaka yerine ula????ld??. Ba??ka Vakaya Y??nlendirildin.");
              }
            }
        }
        else if(data2.length>1&&data1[1]==data2[1]&&data1[2]!=data2[2])
        {
          Fluttertoast.showToast(msg: "??nceli??in De??i??tirildi.");
        }
        else{as_ecn=ecn;}

      }else{}

      as_ecn=ecn;
      if(ecn.contains("activeCase"))
        {
          //activeCase;deneme1;1;1...
          List<String> data = ecn.split(";");
          ecn=data[1];
          //data[1] => birincimi ikinci mi?
          if(ecn=="iptalEdildi")
            {
              define_color(data[2]);
              define_title(data[3]);
            }
          else if(ecn=="Tamamland??")
            {
              define_color(data[2]);
              define_title(data[3]);
            }
          else
          {
            //Fluttertoast.showToast(msg: "list is true ? okuma");
            readInfoofTheCase("ADL/$ecn/$ecn").then((info) {
              if (info == "true") {
                listOfEC.add(ecn);
                define_color(data[2]);
                define_title(data[3]);

                readInfoofTheCase("acilDurumListesi/${data[1]}/location").then((
                    location) {
                  ecll = yadanfo(location);
                });
                getPolyLine(ll!, ecll).then((value) {
                  listPoly.add(value);
                });
              }
              else {

                readInfoofTheCase("ADL/$ecn/$ecn").then((xxxx) {
                  if (xxxx != "true") {
                    define_title("100");
                    define_color("4");
                    vazgecButonText=true;
                    Fluttertoast.showToast(msg: "??a??r?? ??ptal Edilmi??");
                    vazgecButonOnpress = true;
                  }
                });
                //okuma yap ve rengi de??i??tir.
                //durum iptal edildi.
              }
            });
          }
        }
      else{
        Fluttertoast.showToast(msg: "Atama Bekleniyor");
      }
    });
  }
  checkLoadInfo()
  {
    if(ll!=null)
      {
        waitinglLoadInfo=true;
        mytimer.cancel();
      }
  }
  define_ScreenSize()
  {
    double width = MediaQuery.of(context).size.width;
    double heigt = MediaQuery.of(context).size.height;
  }
// ??st Bilgilendirme B??l??m??
  Text _titleOfAiderCode=Text("Yard??m ??steyen Ki??i Konumu Bekleniyor");
  Color _color = Colors.black;
  Color b_color = Colors.lightBlueAccent;
  define_color(String code){
    switch(code)
    {
      case "1":
        vazgecButonOnpress=true;
        b_color=Colors.red;
        _titleOfAiderCode=Text("En Yak??n Kurtar??c?? Sensin");
        break;
      case "2":
        vazgecButonOnpress=true;
        b_color=Colors.orange;
        _titleOfAiderCode=Text("En Yak??n 2. Kurtar??c?? Sensin");
        break;
      case "3":
        vazgecButonOnpress=true;
        b_color=Colors.yellow;
        _titleOfAiderCode=Text("Destek i??in gidebilirsin.");
        break;
      case "4":
        vazgecButonText=true;
        b_color=Colors.lightGreen;
        _titleOfAiderCode=Text("??ptal Edildi");
        break;
      case "5":
        vazgecButonText=true;
        b_color=Colors.lightGreen;
        _titleOfAiderCode=Text("Vakaya ula????ld??");
        break;
    }
    }
    Text _title = Text("Acil ??lk Yard??m Vakas??");
  define_title(String code){
    switch(code)
    {
      case "1":
        _title=const Text("Nefes Alam??yorum",style: TextStyle(fontSize: 13),);
        break;
      case "2":
        _title=const Text("Kanamal?? Yaram Var",style: TextStyle(fontSize: 13),);
        break;
      case "3":
        _title=const Text("??yi Hissetmiyorum",style: TextStyle(fontSize: 13),);
        break;
      case "11":
        _title=const Text("Trafik Kazas??nda Yaralanma",style: TextStyle(fontSize: 13),);
        break;
      case "12":
        _title=const Text("Kanamal?? Yara",style: TextStyle(fontSize: 13),);
        break;
      case "13":
        _title=const Text("Bay??lan Biri Var",style: TextStyle(fontSize: 13),);
        break;
      case "14":
        _title=const Text("Nefes Alam??yan Biri Var",style: TextStyle(fontSize: 13),);
        break;
      case "100":
        _title=const Text("Acil Durum Sonland??r??ld??.",style: TextStyle(fontSize: 13),);
        break;
    }
  }
  Future<Uint8List> getMarker () async
  {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/images/kerimIcon.png") ;
    return byteData.buffer.asUint8List();
  }
  updateMyMarker(LocationData myLocation,Uint8List markerIcon)
  {

    LatLng myLocation_f =LatLng(myLocation!.latitude!, myLocation!.longitude!);
    setState(() {
      myCircle = Circle(
        circleId: const CircleId("myCircle"),
        radius: 3,
        zIndex: 1,
        strokeColor: Colors.deepOrange,
        center: myLocation_f,
        fillColor: Colors.deepOrange.withAlpha(70),
      );
      myMarker = Marker(
        markerId: const MarkerId("myLocation"),
        position: myLocation_f,
        rotation: myLocation!.heading!,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: const Offset(0.5,0.5),
        icon: BitmapDescriptor.fromBytes(markerIcon),

      );
      target=Marker(
          markerId: const MarkerId("illLocation"),
          position: LatLng(ecll!.latitude!, ecll!.longitude!),
          icon:BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose));
    });
  }
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar:AppBar(
        title: _title,
        centerTitle: true,
        foregroundColor: _color,
        backgroundColor: b_color,
        actions: [
          ToggleButtons(
            children: [Icon(Icons.my_location)],
            isSelected: [followingCheck],
            onPressed: (int index){setState(() {followingCheck=!followingCheck;});},
            color:Colors.black,
            selectedColor:Colors.blue ,
            fillColor: Colors.white60,
          ),
          adress == null ? Container(child: null):IconButton(onPressed: _showAdress, icon: Icon(Icons.where_to_vote_sharp)),

        ],
        flexibleSpace: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children:[ /*Align(),*/
            SizedBox(height: 150,),
            _titleOfAiderCode
          ],
        ),


      ),
      body: waitinglLoadInfo==false ? Center(child: Text("HAZIRLANIYOR..."),) :Stack(
        children: [GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _home,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          polylines: Set.from(listPoly),
          markers: {myMarker,target},
          circles: {myCircle},

        ),
      Form(
        key: _formKey,
        child: (check_pop==false) ? Text("") : CupertinoAlertDialog(
          title: Text('Hastaya Ula????ld??'),
          actions: [
            TextButton(onPressed: _gndr, child: Text("G??nder")),
          ],
          content: Card(
            color: Colors.black54.withOpacity(0.5),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _cepController,
                  onChanged: (infof) {
                    ill_info = infof;
                  },
                  decoration: InputDecoration(
                      labelText: "Vaka Kodunu ve Hasta Durumu",
                      filled: true,
                      fillColor: Colors.grey.shade50
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
          Positioned(bottom:50,child: TextButton(onPressed: vazgecButonOnpress==false ? null:_T_iptal, style:ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(Colors.black87.withOpacity(0.5)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
              child: vazgecVerify==false ? (vazgecButonText==false ? Text("Vazge??",style: TextStyle(fontSize: 25),):Text("??IKI??",style: TextStyle(fontSize: 25),)):Text("??ptal",style: TextStyle(fontSize: 25),),

          )
          ),
          Container(
            child: vazgecVerify==true ?CupertinoAlertDialog(
              title: Text('EM??N M??S??N?'),

              actions: [
                TextButton(onPressed: _iptal, child: Text("Evet")),
                TextButton(onPressed: _F_iptal, child: Text("Hay??r")),
              ],
              content: Card(
                color: Colors.black54.withOpacity(0.5),
                child: Column(
                  children: <Widget>[
                    Container(child: vazgecButonText==false ? Text("Yard??m etmekten vazge??ti??ini onayl??yor musun?") : Text("????k???? Yap??lacak Onayl??yor Musun?")),
                  ],
                ),
              ),
            ):null,
          ),
          Container(
            child: adresscheck==true ?CupertinoAlertDialog(
              title: const Text('ADRES B??LG??S??'),
              actions: [
                TextButton(onPressed: (){adresscheck=false;}, child: Text("ANLA??ILDI")),
              ],
              content: Card(
                color: Colors.black54.withOpacity(0.5),
                child: Column(
                  children: <Widget>[
                    Container(child : Text(adress!),),
                  ],
                ),
              ),
            ):null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToMyLocation,
        label: check_pop==false ? const Text('Ula??t??m'):const Text('??ptal'),
        icon: const Icon(Icons.my_location),
      ),

    );

  }

  Future<void> _goToMyLocation() async {
        if(calculateDistance(ll!, ecll!)<0.01)
          {
            if(followtimer.isActive)
              {followtimer.cancel();check_pop = !check_pop;setState(() {

              });}
            else
              {
                followtimer = Timer.periodic(Duration(seconds: 5), (timer) {loadECLocations();check_pop = !check_pop;setState(() {});});
              }
          }
        else
          {loadECLocations();setState(() {});}

  }
  static CameraPosition _home = const CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.9344, 32.4918),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  Future<LocationData> learnMyLocationOnce()
  async {
    return await getLctn().then((value){ll=LatLng(value!.latitude!, value!.longitude!);setState(() {});return value;});

  }
  void learnMyLocationAlways() async
  {
    Uint8List imageData = await getMarker();
    Location location = new Location();
    location.changeSettings(accuracy:LocationAccuracy.navigation,interval: 300,distanceFilter: 3);
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
    location.onLocationChanged.distinct().listen((LocationData currentData) {
      updateMyMarker(currentData!, imageData);
      ll=LatLng(currentData!.latitude!, currentData!.longitude!);changeHome(ll!);setState(() {});
      setLocation(UserID!,fotanya(currentData)+currentData.altitude.toString());

    });
  }
  void _T_iptal()
  {
    setState(() {vazgecVerify=true;});
  }
  void _F_iptal()
  {
    setState(() {vazgecVerify=false;});
  }
  void _iptal()
  {
    updateAcceptCase(UserID!);

  }
  _showAdress()
  {
    adresscheck=true;
  }
  void _gndr(){
    List<String> data=as_ecn.toString().split(';');
    if(ill_info!=null){
      readInfoIll("acilDurumListesi/${data[1]}/info").then((value)
      {
        String yy="";

        if(value.toString()=="null"){yy=ill_info;}else{yy=value.toString()+ill_info;}
        updateInfoIll(data[1], yy,UserID!);
        check_pop = false;
        if(followtimer.isActive==false){Timer.periodic(Duration(seconds: 5), (timer) {loadECLocations();setState(() {});});}
      });

  }
    else{updateInfoIll(data[1], "",UserID!);}

  }
  changeHome(LatLng l_l) async
  {
    if(followingCheck==true)
      {
        final GoogleMapController controller = await _controller.future;
        _home = CameraPosition(
            //bearing: 192.8334901395799,
            target: l_l,
            tilt: 59.440717697143555,
            zoom: 19.151926040649414);
        controller.animateCamera(CameraUpdate.newCameraPosition(_home));
      }


  }
}