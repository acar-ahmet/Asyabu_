
import 'package:flutter/material.dart';
import 'liveLocationTracking/order_tracking.dart';

void main(){
  runApp(startPage());
}
class startPage extends StatelessWidget {
  const startPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      title: 'mainPage',
      home: orderTracking(),
    );

  }
}
