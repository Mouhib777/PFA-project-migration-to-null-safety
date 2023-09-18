import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigStartView extends StatelessWidget {
  final Function moveToPage;
  ConfigStartView(this.moveToPage);

  void _skip(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('activeMenu', '');
    Navigator.of(context).popAndPushNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 28,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width / 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 8,
                child: Container(
                    height: MediaQuery.of(context).size.height / 6,
                    child: Image.asset('assets/images/Logo.png')),
              )
            ],
          ),
          Container(
            child: Center(
              child: Container(
                  width: MediaQuery.of(context).size.width / 14,
                  child: Image.asset('assets/images/settings_1.png')),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 15,
          ),
          Container(
            child: Text(
              'Schnelle Konfiguration',
              style: TextStyle(fontSize: 32),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 20,
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Text(
                "Herzlich Willkommen! Bevor Sie auf Ihr Dashboard gelangen, können Sie nun schrittweise Ihre persönlichen Einstellungen festlegen! Diese können Sie jederzeit ändern.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      child: Image.asset('assets/images/setUp.png'),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 60,
                          child: FlatButton(
                            highlightColor: Colors.white,
                            onPressed: () {
                              _skip(context);
                            },
                            child: Row /*or Column*/ (
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Überspringen',
                                  style: TextStyle(
                                      fontSize: 20, color: Color(0xFF333951)),
                                ),
                                SizedBox(
                                  child: Container(
                                    width: 10,
                                  ),
                                ),
                                Container(
                                    height: 20,
                                    child: Image.asset(
                                        'assets/images/login2.png')),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: 60,
                          child: FlatButton(
                            highlightColor: Colors.white,
                            onPressed: () async {
                              moveToPage(1);
                            },
                            child: Row /*or Column*/ (
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "START",
                                  style: TextStyle(
                                      color: Color(0xFFf45d27), fontSize: 20.0),
                                ),
                                SizedBox(
                                  child: Container(
                                    width: 10,
                                  ),
                                ),
                                Container(
                                    height: 20,
                                    child: Image.asset(
                                        'assets/images/login2.png')),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
