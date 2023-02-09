import 'firebaseOperation.dart';
import 'declareEmergencyCase.dart';
import 'package:flutter/material.dart';

class callAiders_Page extends StatelessWidget{
  late String acilDurumKodu;
  late String PersonID;
  callAiders_Page(String s,String userID){
    acilDurumKodu=s;
    PersonID=userID;
    String ss='acilDurumListesi/$s/cancel';
    readData(ss);
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
          child: Column(
            children: [
              IconButton(
                style:ButtonStyle(shape: MaterialStateProperty.all(const CircleBorder(),),),
                iconSize:175,
                icon :Image(image: AssetImage('assets/images/zil.gif'),), onPressed: () {  },),
              Text(PersonID.substring(0,4)),
              TextButton(onPressed: () {
              cancelEC(acilDurumKodu);//firebase Operation
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => DECSection(PersonID)),
                      (route) => false);
              }, child: Image.asset("assets/images/button3.png",),
              ),
            ],
          ),
        ),
      )
      ,

    );
  }
}