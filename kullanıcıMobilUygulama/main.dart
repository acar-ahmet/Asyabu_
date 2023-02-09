import 'package:bitirme_projesi_iki/startPage.dart';

import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: startPage(),//ID!=null ? startPage() : loginSection(),
  ));
}


