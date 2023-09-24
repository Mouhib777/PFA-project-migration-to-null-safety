import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigDoneView extends StatelessWidget {
  final Function moveToPage;
  ConfigDoneView(this.moveToPage);

  void _skip(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('activeMenu', '/dashboard');
    Navigator.pushReplacementNamed(context, '/dashboard');
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
                  child: Image.asset('assets/images/interface_1.png')),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 15,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 20,
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Text(
                "Sie haben es geschafft !",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF333951),
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 20,
          ),
          Center(
              child: Row(
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width / 4,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    _skip(context);
                  },
                  child: Row /*or Column*/ (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Auf zu Ihrem Dashboard und Ihren Schülerbeobachtungen!',
                        style:
                            TextStyle(fontSize: 17, color: Color(0xFFff8300)),
                      ),
                      SizedBox(
                        child: Container(
                          width: 10,
                        ),
                      ),
                      Container(
                          height: 20,
                          child: Image.asset('assets/images/login2.png')),
                    ],
                  ),
                ),
              ),
            ],
          )),
          Expanded(
            child: Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: ElevatedButton(
                            onPressed: () {
                              moveToPage(4);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: 20,
                                  child: Image.asset(
                                    'assets/images/back_button.png',
                                  ),
                                ),
                                SizedBox(
                                  child: Container(
                                    width: 10,
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    "Zurück",
                                    style: TextStyle(
                                        color: Color(0xFFff8300),
                                        fontSize: 20.0),
                                  ),
                                ),
                              ],
                            ))),
                    Container(
                      child: InkWell(
                        child: Image.asset('assets/images/Calque 2636.png'),
                        onTap: () {
                          moveToPage(4);
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
