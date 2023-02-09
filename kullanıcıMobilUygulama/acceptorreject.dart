import 'dart:io';

import 'package:bitirme_projesi_iki/cevirici.dart';
import 'package:bitirme_projesi_iki/routefromaidertoill.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import 'firebaseOperation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:location/location.dart';

import 'locationOperations.dart';

class acceptorreject extends StatelessWidget {
  late String ID;
  late String ADK;
  late LocationData LL;
  acceptorreject(String id,String adk)
  {
      ID=id;
      ADK=adk;
  }
  void a2 (String A2_userID)
  {
    readKL("/KL/1").then((value) {
      String a = value;
      a=a.replaceAll("[", "");
      a=a.replaceAll("]", "");
      List<String> temp = [];
      List<String> data = a.split(",");
      data.forEach((element) { element=element.trim();if(element!="null"){temp.add(element);}});
      if(temp.contains(A2_userID))
      {/*nothing*/}
      else{
        temp.add("$A2_userID");
        setKL(temp,A2_userID);
      }
    });
  }
  void a1 () async
  {

  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body:Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                width: (MediaQuery.of(context).size.width)-100,
                child: Padding(
                  padding: const EdgeInsets.all(21.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(color: Colors.black26.withOpacity(0.1),child: Text("Acil Sağlık Yardımına İhtiyacı Olan Biri Var!",style: TextStyle(fontSize: 27),)),
                      Container(color: Colors.black26.withOpacity(0.1),child: SizedBox(height: 15,width: (MediaQuery.of(context).size.width)-100,)),
                      Container(alignment: AlignmentDirectional.center,width:(MediaQuery.of(context).size.width)-100,color: Colors.black26.withOpacity(0.1),child: Text("Yardım eder misin?",style: TextStyle(fontSize: 27),)),
                      Container(color: Colors.black26.withOpacity(0.1),child: SizedBox(height: 35,width: (MediaQuery.of(context).size.width)-100,)),
                      Container(
                        color: Colors.black26.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Hayır"),
                            TextButton(onPressed: () {
                              _send();
                              FlutterRingtonePlayer.stop();
                              Future.delayed(const Duration(seconds:2), (){exit(0);});
                            }, child:Icon(Icons.close_sharp,color:Colors.red,size: 50) ,
                            ),
                            Text("EVET"),
                            TextButton(onPressed: () {
                              _send();
                              a2(ID);
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => MapSample(ID)),
                                      (Route<dynamic> route) => false);
                              FlutterRingtonePlayer.stop();
                              //firebase Operation
                              /*Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (_) => ),
                                  (route) => false);*/
                            }, child: Icon(Icons.task_alt,color:Colors.blue,size: 50),
                            ),
                          ],
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            ),

      )
      ,

    );
  }
  _send() async
  {
    try{
    final Directory directory = await getApplicationDocumentsDirectory();
    bool a= File('${directory.path}/caseLocation.txt').existsSync();
    if(a==true)
    {
     await File('${directory.path}/caseLocation.txt').delete();
    }} catch (e){Fluttertoast.showToast(msg: "hata var!"+e.toString());}
  }
}