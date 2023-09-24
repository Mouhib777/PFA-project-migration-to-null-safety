import 'package:docu_diary/config/url.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:docu_diary/blocs/token/bloc.dart';

class ActivationCode extends StatefulWidget {
  final difference;
  final token;
  const ActivationCode({Key? key, this.difference, this.token})
      : super(key: key);

  @override
  ActivationCodeState createState() => ActivationCodeState();
}

class ActivationCodeState extends State<ActivationCode> {
  String _baseUrl = BaseUrl.urlAPi;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();

  String? _email, _code;
  bool popupShow = false;
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final prefs = await SharedPreferences.getInstance();
      final emailofConnectUser = prefs.getString('email') ?? '';
      Map<String, dynamic> data = {
        'email': _email!.trim(),
        'validationCode': _code!.trim(),
        'emailOfUser': emailofConnectUser
      };
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/payement/verfication'),
          
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Vielen Dank !'),
                  content: const Text(
                      'Vielen Dank, Ihr Nutzerkonto ist nun erfolgreich freigeschaltet'),
                  actions: <Widget>[
                    ElevatedButton(
                      child: Text('Ok'),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/');
                      },
                    ),
                  ],
                );
              });
        } else {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Registrierungsfehler'),
                  content: const Text(
                      'Der von Ihnen eingegebene Aktivierungscode war leider nicht korrekt. Versuchen Sie es noch einmal und kontaktieren Sie uns gerne, wenn das Problem weiter besteht.'),
                  actions: <Widget>[
                    ElevatedButton(
                      child: Text('Ok'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
        }
      } catch (e) {}
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TokenBloc>(
          create: (BuildContext context) => TokenBloc(),
        ),
      ],
      child: BlocBuilder<TokenBloc, TokenState>(builder: (context, state) {
        return Container(
          child: Container(
              width: 600,
              height: 600,
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerRight,
                    width: 600,
                    child: InkWell(
                      child: Icon(Icons.close, color: Color(0xFFf45d27)),
                      onTap: () {
                        if (widget.difference > 0) {
                          Navigator.of(context)
                              .pushNamed('/dashboard', arguments: widget.token);
                          setState(() {
                            popupShow = false;
                          });
                        } else {
                          Navigator.of(context).pop();

                          // context.bloc<TokenBloc>()..add(UserLogout());
                        }
                      },
                    ),
                  ),
                  Container(
                    width: 550,
                    child: Column(
                      children: <Widget>[
                        // Text(
                        //     'Manage Topics: ${fromChange['name']}'),
                        RichText(
                          text: TextSpan(
                            /*defining default style is optional */
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Verfügbarer Testzeitraum: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Color(0xFF333951))),
                            ],
                          ),
                        ),
                        SizedBox(
                          child: Container(
                            height: 5,
                          ),
                        ),
                        //open broswer once
                        RichText(
                          text: TextSpan(
                            /*defining default style is optional */
                            children: <TextSpan>[
                              TextSpan(
                                  text: widget.difference.toString() + ' Tage',
                                  style: TextStyle(
                                      fontSize: 30, color: Color(0xFFf45d27))),
                            ],
                          ),
                        ),
                        SizedBox(
                          child: Container(
                            height: 25,
                          ),
                        ),
                        Container(
                            child: Center(
                                child: Text(
                                    'Wenn Ihnen unser Produkt gefällt, können Sie bequem über unsere Webseite eine Schuljahreslizenz bestellen. Sie erhalten daraufhin einen Aktivierungscode, den Sie hier freischalten und damit DocuDiary für das gesamte Schuljahr uneingeschränkt nutzen können. Wir werden unser Produkt zudem weiter für Sie verbessern und erweitern und freuen uns auf Ihr Feedback!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF333951))))),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 550,
                          alignment: Alignment.center,
                          child: Row /*or Column*/ (
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  height: 220,
                                  width: 220,
                                  child: new InkWell(
                                      onTap: () async {
                                        const url =
                                            'https://docudiary.de/membership-page/#plans';
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Card(
                                          margin: EdgeInsets.all(18),
                                          elevation: 7.0,
                                          child: Column /*or Column*/ (
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                    child: Image.asset(
                                                        'assets/images/membership.png',
                                                        width: 40,
                                                        height: 71)),
                                                Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Center(
                                                          child: Container(
                                                        child: Text(
                                                            "Aktivierungscode ",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Color(
                                                                    0xFF333951))),
                                                      )),
                                                      Center(
                                                          child: Container(
                                                        child: Text(
                                                            " bestellen",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Color(
                                                                    0xFF333951))),
                                                      )),
                                                    ]),
                                                Container(
                                                    width: 200,
                                                    child: Center(
                                                        child: Text(
                                                      "",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Color(
                                                              0xFF333951)),
                                                    ))),
                                              ])))),
                              Container(
                                  height: 220,
                                  width: 220,
                                  child: new InkWell(
                                      onTap: () async {
                                        setState(() {
                                          popupShow = true;
                                        });
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                  content:
                                                      SingleChildScrollView(
                                                child: Form(
                                                  key: _formKey,
                                                  child: Container(
                                                    child: Container(
                                                        width: 600,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              width: 600,
                                                              child:
                                                                  InkResponse(
                                                                onTap: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  setState(() {
                                                                    popupShow =
                                                                        false;
                                                                  });
                                                                  // context.bloc<
                                                                  //     TokenBloc>()
                                                                  //   ..add(
                                                                  //       UserLogout());
                                                                },
                                                                child: Icon(
                                                                    Icons.close,
                                                                    color: Color(
                                                                        0xFFf45d27)),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 550,
                                                              child: Column(
                                                                children: <
                                                                    Widget>[
                                                                  // Text(
                                                                  //     'Manage Topics: ${fromChange['name']}'),
                                                                  Container(
                                                                      child: Center(
                                                                          child: Text(
                                                                              'Bitte geben Sie Ihren Aktivierungscode ein, um unsere vollständigen Funktionen für das gesamte Schuljahr nutzen zu können',
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(fontSize: 16, color: Color(0xFF333951))))),
                                                                  SizedBox(
                                                                    child:
                                                                        Container(
                                                                      height: 5,
                                                                    ),
                                                                  ),
                                                                  // RichText(
                                                                  //   text: TextSpan(
                                                                  //     /*defining default style is optional */
                                                                  //     children: <
                                                                  //         TextSpan>[
                                                                  //       TextSpan(
                                                                  //           text:
                                                                  //               '8 Tage',
                                                                  //           style: TextStyle(
                                                                  //               fontSize:
                                                                  //                   30,
                                                                  //               color:
                                                                  //                   Color(0xFFf45d27))),
                                                                  //     ],
                                                                  //   ),
                                                                  // ),
                                                                  SizedBox(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          25,
                                                                    ),
                                                                  ),

                                                                  SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  Container(
                                                                    width: 550,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child:
                                                                        Container(
                                                                      child:
                                                                          Container(
                                                                        child:
                                                                            SingleChildScrollView(
                                                                          child:
                                                                              Padding(
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                80,
                                                                                2,
                                                                                80,
                                                                                2),
                                                                            child:
                                                                                Column(
                                                                              children: <Widget>[
                                                                                Container(
                                                                                  decoration: new BoxDecoration(boxShadow: [
                                                                                    new BoxShadow(
                                                                                      color: Colors.grey.withOpacity(.2),
                                                                                      blurRadius: 14,
                                                                                    ),
                                                                                  ]),
                                                                                  child: Card(
                                                                                    elevation: 0,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(1.0),
                                                                                    ),
                                                                                    child: Container(
                                                                                      height: MediaQuery.of(context).size.height * 0.1,
                                                                                      decoration: BoxDecoration(
                                                                                        border: Border(
                                                                                            left: BorderSide(
                                                                                          //                   <--- left side
                                                                                          color: Colors.black,
                                                                                          width: 7.0,
                                                                                        )),
                                                                                      ),
                                                                                      child: Center(
                                                                                        child: TextFormField(
                                                                                          decoration: (InputDecoration(
                                                                                            border: InputBorder.none,
                                                                                            contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                                                                                            hintText: 'E-Mail des Bestellers',
                                                                                          )),
                                                                                          validator: (input) => !input!.contains('@') ? 'Bitte geben Sie eine gültige E-Mail an' : null,
                                                                                          onSaved: (input) => _email = input,
                                                                                          //obscureText: true,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  decoration: new BoxDecoration(boxShadow: [
                                                                                    new BoxShadow(
                                                                                      color: Colors.grey.withOpacity(.2),
                                                                                      blurRadius: 14,
                                                                                    ),
                                                                                  ]),
                                                                                  child: Card(
                                                                                    elevation: 0,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(1.0),
                                                                                    ),
                                                                                    child:

                                                                                        /*Name*/
                                                                                        Container(
                                                                                      height: MediaQuery.of(context).size.height * 0.1,
                                                                                      decoration: BoxDecoration(
                                                                                        border: Border(
                                                                                            left: BorderSide(
                                                                                          //                   <--- left side
                                                                                          color: Colors.black,
                                                                                          width: 7.0,
                                                                                        )),
                                                                                      ),
                                                                                      child: Center(
                                                                                        child: TextFormField(
                                                                                          decoration: (InputDecoration(
                                                                                            border: InputBorder.none,
                                                                                            contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                                                                                            hintText: 'Aktivierungscode',
                                                                                          )),
                                                                                          validator: (input) => input!.length < 3 ? 'Name muss mindestens 3 Zeichen lang sein' : null,
                                                                                          onSaved: (input) => _code = input,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    /*Name*/
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),

                                                                  Container(
                                                                    // color: Colors.yellow,
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.1,
                                                                    child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .spaceAround,
                                                                        children: <
                                                                            Widget>[
                                                                          Container(
                                                                              // color: Colors.blue,

                                                                              child: InkWell(
                                                                                  child: ElevatedButton(
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                        showDialog(
                                                                                            barrierDismissible: false,
                                                                                            context: context,
                                                                                            builder: (BuildContext context) {
                                                                                              return AlertDialog(
                                                                                                content: SingleChildScrollView(
                                                                                                  child: ActivationCode(),
                                                                                                ),
                                                                                              );
                                                                                            });
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
                                                                                            child: InkWell(
                                                                                              child: Text(
                                                                                                "Zurück",
                                                                                                style: TextStyle(color: Color(0xFFff8300), fontSize: 20.0),
                                                                                              ),
                                                                                              onTap: () {
                                                                                                Navigator.of(context).pop();
                                                                                                setState(() {
                                                                                                  popupShow = false;
                                                                                                });
                                                                                                // context.bloc<TokenBloc>()..add(UserLogout());
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )))),
                                                                          Container(
                                                                            // color: Colors.blue,

                                                                            child: ElevatedButton(
                                                                                onPressed: () async {
                                                                                  _submit();
                                                                                },
                                                                                child: Row /*or Column*/ (
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: <Widget>[
                                                                                    Text(
                                                                                      "Weiter",
                                                                                      style: TextStyle(color: Color(0xFFff8300), fontSize: 20.0),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      child: Container(
                                                                                        width: 10,
                                                                                      ),
                                                                                    ),
                                                                                    Container(height: 20, child: Image.asset('assets/images/login2.png')),
                                                                                  ],
                                                                                )),
                                                                          ),
                                                                        ]),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                ),
                                              ));
                                            });
                                      },
                                      child: Card(
                                          margin: EdgeInsets.all(18),
                                          elevation: 7.0,
                                          child: Column /*or Column*/ (
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                    child: Image.asset(
                                                        'assets/images/password.png',
                                                        width: 40,
                                                        height: 71)),
                                                Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Center(
                                                          child: Container(
                                                        child: Text(
                                                            "Aktivierungscode",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Color(
                                                                    0xFF333951))),
                                                      )),
                                                      Center(
                                                          child: Container(
                                                        child: Text(" eingeben",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Color(
                                                                    0xFF333951))),
                                                      )),
                                                    ]),
                                              ])))),
                            ],
                          ),
                        ),

                        Container(
                          // color: Colors.yellow,

                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                (widget.difference > 0)
                                    ? Container(
                                        // color: Colors.blue,  child: InkWell(
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              Navigator.of(context)
                                                  .pushNamed('/');
                                            },
                                            child: Row /*or Column*/ (
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "Mit Testversion fortfahren",
                                                  style: TextStyle(
                                                      // color: Color(
                                                      //     0xFFf45d27),
                                                      fontSize: 20.0),
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
                                            )),
                                      )
                                    : Container()
                              ]),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        );
      }),
    );
  }
}
