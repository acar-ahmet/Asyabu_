import 'package:bitirme_projesi_iki/callAiders.dart';
import 'package:bitirme_projesi_iki/firebaseOperation.dart';
import 'package:bitirme_projesi_iki/messageOperations.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'declareEmergencyCase.dart';
import 'locationOperations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class DECSection_another extends StatefulWidget {
  late String UserID;
  DECSection_another(String userID){
    UserID=userID;
  }

  @override
  _DECSectionState_another createState() => _DECSectionState_another(UserID);
}

class _DECSectionState_another extends State<DECSection_another> {
  int generalindex=1;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }
  String PersonID="deneme";
  LocationData? _locationInfoForDEC;
  bool visibilityDECButton = true;
  bool visibilityDECState = true;

  _DECSectionState_another(String userID){PersonID=userID;}
  @override
  Widget build(BuildContext context) {
    messageOperations mo = messageOperations();
    mo.xx(context,PersonID);
    return Scaffold(
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
                              __changeFormatLocation();
                              sendLocationInfo(11, PersonID, __changeFormatLocation());
                            },
                            child: const Text(
                              "Trafik Kazasında Yaralı Var",
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
                              sendLocationInfo(12, PersonID, __changeFormatLocation());
                            },
                            child: const Text(
                              " Kanamalı Yarası Olan Biri Var",
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
                              sendLocationInfo(13, PersonID, __changeFormatLocation());
                            },
                            child: const Text(
                              "Bilinci Olmayan Biri Var",
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
                              sendLocationInfo(14, PersonID, __changeFormatLocation());
                            },
                            child: const Text(
                              "Nefes Alamayan Biri Var",
                              style: TextStyle(
                                fontSize: 27,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),/*
                          const SizedBox(
                            height: 50,
                          ),
                          const SizedBox(
                            height: 50,
                          ),*/
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
                              "!!!İptal Et!!!",
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


                child: Center(
                  child: Container(
                    width: 275,
                    height: 275,
                    child: IconButton(
                      alignment: Alignment.center,
                      icon: Image.asset("assets/images/button2.png",),
                      onPressed: () {
                        getLctn().then((data){
                          _locationInfoForDEC= data!;
                          //if the case is "!=null", you can send declare...
                        });
                        if(_locationInfoForDEC==null)
                        {
                          /*print("error: Location is null");*/
                        }
                        else
                        {
                          __changedVisibility(false,"DECButton");
                        }

                      },
                      splashColor: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.emoji_people_sharp,size: 29,color: Colors.black54,),label: '',),
          //BottomNavigationBarItem(icon: Icon(Icons.abc),label: 'I saw an emergency case',),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined,size: 29,color: Colors.white,),label: '',),
        ],
        backgroundColor: Colors.black26,
        onTap: (index)
        {
          if(index==0&&generalindex!=0)
          {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => DECSection(PersonID),),
                    (route) => false);
          }
          else if(index==1&&generalindex!=1)
          {
            //
          }
        },
      ),
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
    String tmp = design.replaceAll(',', ';');
    tmp.replaceAll('.', '-');
    tmp ="39-9314;32-8465";
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => callAiders_Page(PersonID,PersonID),),
            (route) => false);return tmp;
  }


}
