import 'package:bitirme_projesi_iki/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'homepage.dart';

class registerSection extends StatefulWidget {
  @override
  _registerSectionState createState() => _registerSectionState();
}

class _registerSectionState extends State<registerSection> {
  final database=FirebaseDatabase.instance.ref();
  late String name,surname,email, password;

  //----
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final users =database.child('/users');
    return Scaffold(
        appBar: AppBar(
          title: const Text("ASYABU KAYIT"),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,

          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView(
                scrollDirection: Axis.vertical,
                  children: [
                TextFormField(
                  onChanged: (item) {
                    setState(() {
                      name = item;
                    });
                  },
                  validator: (gotMail) {

                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "İSMİNİZİ GİRİNİZ",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  onChanged: (item) {
                    setState(() {
                      surname = item;
                    });
                  },
                  validator: (gotMail) {

                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "SOYİSMİNİZİ GİRİNİZ",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
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
                      return "LÜTFEN EPOSTA ADRESİNİZİ KONTROL EDİNİZ. GEÇERSİZ EPOSTA ADRESİ GİRDİNİZ.";
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
                    labelText: "ŞİFRENİZİ GİRİNİZ",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 19,
                ),
                TextFormField(
                  onChanged: (gotPassword) {
                    setState(() {
                    });
                  },
                  validator: (gotPasswordAgain) {
                    if (password == gotPasswordAgain) {
                      return null;
                    } else {
                      return "GİRDİĞİNİZ ŞİFRELER EŞLEŞMİYOR";
                    }
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "LÜTFEN ŞİFRENİZİ TEKRAR GİRİNİZ",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: () {
                        registerAdd(users);
                      },
                      child: const Text("KAYIT OL"),
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
                      // make user go to login page
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => loginSection()),
                              (Route<dynamic> route) => false);
                    },
                    child: const Text(
                      "BİR HESABIM VAR",
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

//--------------------------------------Add a user with an email and password---------
  void registerAdd(final users) {
    if (_formKey.currentState!.validate()) {

      FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((user) {
            database.child("/users/"+user.user!.uid).set(
                {
                  'name': name,
                  'surname':surname,
                  'email':user.user!.email,
                  'type':0,
                  'location': "00",
                  'activeCase' :"0",
                  'token':"0",
                });
            Fluttertoast.showToast(msg: "KAYIT BAŞARILI");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => loginSection()),
                    (Route<dynamic> route) => false);
      }).catchError((hata) {
        Fluttertoast.showToast(msg: "KAYIT BAŞARISIZ");
      });
    }
  }
}
