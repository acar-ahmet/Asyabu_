import 'dart:io';

import 'package:bitirme_projesi_iki/declareEmergencyCase.dart';
import 'package:bitirme_projesi_iki/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import 'cevirici.dart';
import 'homepage.dart';

class loginSection extends StatefulWidget {
  @override
  _loginSectionState createState() => _loginSectionState();
}

class _loginSectionState extends State<loginSection> {
  late String email, password;

  //----
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("ASYABU GİRİŞ"),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(children: [
                TextFormField(
                  onChanged: (gotMail) {
                    setState(() {
                      email = gotMail;
                    });
                  },
                  validator: (gotMail) {
                    if (gotMail!.contains("@")) {
                      return null;
                    } else {
                      return "LÜTFEN EPOSTA ADRESİNİZİ KONTROL EDİNİZ. GEÇERSİZ EPOSTA ADRESİ GİRDİNİZ!";
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Enter Your Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  onChanged: (gotPassword) {
                    setState(() {
                      password = gotPassword;
                    });
                  },
                  validator: (gotPassword) {
                    if (gotPassword!.length >= 6) {
                      return null;
                    } else {
                      return "LÜTFEN EN AZ 6 KARAKTER GİRİNİZ";
                    }
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Enter Your Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 19,
                ),
                Container(
                    width: double.infinity,
                    height: 51,
                    child: ElevatedButton(
                      onPressed: () {
                        LOGINACTION();
                      },
                      child: const Text("GİRİŞ"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.indigo,
                        textStyle: const TextStyle(
                          color: Colors.white70,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                const SizedBox(
                  height: 11,
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // make user go to register page
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => registerSection()),
                              (Route<dynamic> route) => false);
                    },
                    child: const Text(
                      "BİR HESABIM YOK",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ));
  }

//Check the user with an email and password and if informations are true, make user go to homepage---------
  void LOGINACTION({String email_F="",String password_F=""}) {
    if(email_F==""&&password_F=="")
    {
      if (_formKey.currentState!.validate()) {
        // If there aren't any validator warning enter this section
        FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password)
            .then((user) {
          //if login is successful, enter this section
          _write("$email,$password");
          Fluttertoast.showToast(msg: "Login is successful");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => DECSection(user.user!.uid)),
                  (Route<dynamic> route) => false);
        }).catchError((hata) {
          //if login is UNsuccessful, enter this section
          Fluttertoast.showToast(msg: "Login is unsuccessful");
        });
      }
    }
    else
    {
      if (_formKey.currentState!.validate()) {
        // If there aren't any validator warning enter this section
        FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email_F, password: password_F)
            .then((user) {
          //if login is successful, enter this section

          Fluttertoast.showToast(msg: "Login is successful");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => homepage(user.user!.uid)),
              (Route<dynamic> route) => false);
        }).catchError((hata) {
          //if login is UNsuccessful, enter this section
          Fluttertoast.showToast(msg: "Login is unsuccessful");
        });
      }
    }
  }
  _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.txt');
    await file.writeAsString(text);
  }
}