import 'dart:async';
import 'dart:io';
import 'package:bitirme_projesi_iki/callAiders.dart';
import 'package:bitirme_projesi_iki/declareAnotherEmergencyCase.dart';
import 'package:bitirme_projesi_iki/firebaseOperation.dart';
import 'package:bitirme_projesi_iki/messageOperations.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'acceptorreject.dart';
import 'locationOperations.dart';


class DECSection extends StatefulWidget {
  late String UserID;
  DECSection(String userID){
    UserID=userID;
  }

  @override
  _DECSectionState createState() => _DECSectionState(UserID);
}

class _DECSectionState extends State<DECSection> {
  Timer t=Timer(const Duration(seconds:20), () { });
  String? textLocation;
  int generalindex=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    }
  String PersonID="deneme";
  LocationData? _locationInfoForDEC;
  bool visibilityDECButton = true;
  bool visibilityDECState = true;

  _DECSectionState(String userID){PersonID=userID;}
  @override
  Widget build(BuildContext context) {
    bool rap_bool=true;
    messageOperations mo = messageOperations();
    mo.xx(context,PersonID);
    mo.checkPassive=false;
    _read();
    return Scaffold(
      appBar:  textLocation!=null ? AppBar(
        actions: [Container(child: textLocation!=null ? IconButton(onPressed: (){
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (_) => acceptorreject(PersonID, "tmp[1]")),
                  (route) => false);
        }, icon: const Icon(Icons.volunteer_activism_rounded)) : null),],
      ):null,
      extendBody: true,
      body: Container(
          decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
              child: Visibility(
                    visible: visibilityDECButton,
                replacement:
                  Center(
                    child: Container(
                      height: 500,
                      width: 300,
                      child: ListView(//Stack is alternative for position options
                        scrollDirection: Axis.vertical,
                        children:<Widget>
                        [
                          const SizedBox(
                            height: 50,
                          ),
                          Container(
                            width: 250,
                            color: Colors.red,
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                              // make user declare/send info of location
                              //birden fazla kisi tanık olarak gönderirse onu birleştir!!!!!!!!
                              __changedVisibility(true,"DECButton");
                              mo.checkPassive=true;
                              sendLocationInfo(01, PersonID, __changeFormatLocation());
                              },
                              child: const Text(
                              "NEFES ALAMIYORUM",
                              style: TextStyle(
                                fontSize: 27,
                              ),
                            ),
                          ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Container(
                            width: 300,
                            color: Colors.red,
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                // make user declare/send info of location
                                //birden fazla kisi tanık olarak gönderirse onu birleştir!!!!!!!!
                                __changedVisibility(true,"DECButton");
                                mo.checkPassive=true;
                                sendLocationInfo(02, PersonID,__changeFormatLocation());
                              },
                              child: const Text(
                                "KANAMALI YARAM VAR",
                                style: TextStyle(
                                  fontSize: 27,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Container(
                            width: 400,
                            color: Colors.red,
                            alignment: Alignment.center,
                            child: GestureDetector(

                              onTap: () {
                                // make user declare/send info of location
                                //birden fazla kisi tanık olarak gönderirse onu birleştir!!!!!!!!
                                __changedVisibility(true,"DECButton");
                                mo.checkPassive=true;
                                sendLocationInfo(03, PersonID, __changeFormatLocation());
                              },
                              child: const Text(
                                "KENDİMİ İYİ HİSSETMİYORUM",
                                style: TextStyle(
                                  fontSize: 27,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Container(
                            width: 150,
                            color: Colors.redAccent,
                            alignment: Alignment.center,
                            child: GestureDetector(

                              onTap: () {
                                // make user declare/send info of location
                                //birden fazla kisi tanık olarak gönderirse onu birleştir!!!!!!!!
                                __changedVisibility(true,"DECButton");
                                //_locationInfoForDEC assignment a null
                              },
                              child: const Text(
                                "!!!İPTAL ET!!!",
                                style: TextStyle(
                                  fontSize: 27,

                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                    child:
                        Center(
                          child: Container(
                            width: 275,
                            height: 275,
                            child: IconButton(
                                alignment: Alignment.center,
                                icon: Image.asset("assets/images/button.png",),
                                onPressed: () {
                                  getLctn().then((data){
                                    _locationInfoForDEC= data!;
                                    //if the case is "!=null", you can send declare...
                                    });
                                  if(_locationInfoForDEC==null)
                                    {
                                    }
                                  else
                                    {
                                      __changedVisibility(false,"DECButton");
                                    }

                                  },
                                splashColor: Colors.black,

                            ),
                          ),
                        ),

              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.emoji_people_sharp,size: 29,color: Colors.white,),label: '',),
          //BottomNavigationBarItem(icon: Icon(Icons.abc),label: 'I saw an emergency case',),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined,size: 29,color: Colors.black54,),label: '',),

        ],
        backgroundColor: Colors.black26,
        onTap: (index)
        {
         if(index==0&&generalindex==1)
         {
           //
         }
         else if(index==1&&generalindex!=1)
         {
           mo.checkPassive=true;
           Navigator.pushAndRemoveUntil(context,
               MaterialPageRoute(builder: (_) => DECSection_another(PersonID),),
                   (route) => false);
         }
        },
      ),

      /*BottomAppBar(
        color: Colors.blue,
        child: IconButton(
          onPressed:null,
          icon: Icon(Icons.settings_ethernet),
        ),
      ),*/

    );
  }
  void __changedVisibility(bool visibility, String field) {
    setState(() {
      if (field == "DECButton") {
        visibilityDECButton = visibility;
      }
    });
  }
  String __changeFormatLocation()
  {

    String  design =  _locationInfoForDEC!.latitude.toString();
    design+= ";"+_locationInfoForDEC!.longitude.toString();
    design+= ";"+_locationInfoForDEC!.altitude.toString();
    design= design.replaceAll(',', ';');
    design=design.replaceAll('.', '-');
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => callAiders_Page(PersonID,PersonID),),
            (route) => false);
    return design;
  }
  _read() async
  {
    final Directory directory = await getApplicationDocumentsDirectory();
    bool a= File('${directory.path}/caseLocation.txt').existsSync();
    if(a==true)
    {
      final File file = File('${directory.path}/caseLocation.txt');
      textLocation = await file.readAsString();
      t.cancel();
    }
  }

}
