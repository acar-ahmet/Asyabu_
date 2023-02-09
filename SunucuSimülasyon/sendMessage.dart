import 'package:api_fcm/api_fcm.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../firebaseOperations.dart';



void sendECInfo(String latitude, String longitude, String caseType,String priority,List<String> id)
{
  latitude=latitude.replaceAll(".", "-");
  latitude+=";"+longitude.replaceAll(".", "-");
  latitude+=":"+caseType;
  latitude+=":"+priority;
  print(latitude);
  List<String> tokenlist=[];
  getTokens(id).then((value)
  {
    if(value==null)
      {
        //nothing
      }
    else
      {
        tokenlist=value;
        sendMessageWithAPI(latitude, tokenlist);
      }
  });


}
void sendMessageWithAPI(String info,List<String> tl)
{
  {
    // get your token server from firebase dashboard
    var api = ApiFcm(tokenServer: 'Your Key');

    tl.forEach((element)
    {
      if(element.toString()!="null")
        {
          api.postMessage(
            listtokens: [element],
            notification: MessageModel(title:'Acil Yardım Vakası',body: info),
          );
        }
    });

    /*
    api.postTopics(
      topics: 'test',
      notification: MessageModel(body: 'Notification test topics'),
    );*/
  }
}