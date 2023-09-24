import 'package:docu_diary/config/url.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:docu_diary/blocs/token/bloc.dart';
import 'package:docu_diary/db/dao/token.dart';
import 'package:docu_diary/models/token.dart';
import 'package:docu_diary/db/dao/dao.dart';
import 'package:docu_diary/repositories/repositories.dart';
import 'package:docu_diary/views/config/config.dart';

class AddNewYear extends StatefulWidget {
  @override
  AddNewYearState createState() => AddNewYearState();
}

class AddNewYearState extends State<AddNewYear> {
  static final _baseUrl = BaseUrl.urlAPi;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TokenDao _tokenDao = TokenDao();
  YearDao _yearDao = YearDao();
  String _currentYear = '';
  final ClassRepository _classRepository = ClassRepository();

  final ClassDao _classDao = ClassDao();

  final _formKey = GlobalKey<FormState>();

  String? _email, _code;
  bool popupShow = false;
  final _payementRepository = PayementRepository();
  SelectedYearsDao _selectedyearDao = SelectedYearsDao();

  void _loadNewYear() async {
    Token? token = await _tokenDao.getToken();

    final years = await _payementRepository.getYears(token: token!.accessToken);

    await _selectedyearDao.insert(years.first);

    years.first.updatedAt = new DateTime.now().millisecondsSinceEpoch;

    await _yearDao.update(years.first);
    _yearDao.insertMany(years);

    years.first.updatedAt = new DateTime.now().millisecondsSinceEpoch;
    await _yearDao.update(years.first);
    await _selectedyearDao.delete();
    _selectedyearDao
        .update(years.firstWhere((element) => element.name == _currentYear));

    final classes =
        await _classRepository.loadOfflineClasses(token: token.accessToken);
    if (classes.length > 0) {
      await _classDao.insertMany(classes);
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ConfigView(),
        transitionDuration: Duration(seconds: 0),
      ),
    );
  }

  void _submit() async {
    Token? token = await _tokenDao.getToken();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Map<String, dynamic> data = {
        'email': _email!.trim(),
        'validationCode': _code!.trim()
      };
      try {
        final response = await http.post(
          Uri.parse(
          '$_baseUrl/payement/buy/newyear'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': "Bearer " + token!.accessToken!,
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
                      onPressed: () async {
                        _loadNewYear();
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
    _fetchData();
  }

  _fetchData() async {
    try {
      // final prefs = await SharedPreferences.getInstance();
      Token? token = await _tokenDao.getToken();

      final response = await http.get(
        Uri.parse(
        '$_baseUrl/payement/getNewYears'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + token!.accessToken!,
        },
      );
      if (response.statusCode != 200) {
        throw new Exception('error user login');
      } else {
        setState(() {
          final json = jsonDecode(response.body);
          _currentYear = json != null ? json : '2021/2021';
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
          width: 600,
          height: 650,
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.centerRight,
                width: 600,
                child: InkWell(
                  child: Icon(Icons.close, color: Color(0xFFf45d27)),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Container(
                width: 550,
                child: Column(
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Neues Schuljahr anlegen: ',
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
                              text: _currentYear,
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
                                'Sie können in diesem Schritt mit nur wenigen Klicks Ihr neues Schuljahr anlegen. Hierfür benötigen Sie lediglich einen neuen Aktivierungscode, der wieder für das gesamte neue Schuljahr gültig ist. Mit dem Freischalten des neuen Schuljahrs werden alle Ihre Daten in Bezug auf Klassen, Themen/Fächer, Unterkategorien und Schüler übernommen - mit Ausnahme Ihrer getätigten Beobachtungen, die sicher im bisherigen Schuljahr gespeichert bleiben.\n \n Sie können im nächsten Schritt dann in Ruhe entscheiden, wie Sie Ihre Klassen umbenennen und ob Sie weitere Änderungen an Themen oder Schülern vornehmen möchten. Wir wünschen Ihnen viel Spaß mit DocuDiary auch für Ihr neues Schuljahr!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF333951))))),
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
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.1,
                                                child: Image.asset(
                                                    'assets/images/membership.png',
                                                    width: 40,
                                                    height: 71)),
                                            SizedBox(height: 10),
                                            Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Center(
                                                      child: Container(
                                                    child: Text(
                                                        "Aktivierungscode ",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: Color(
                                                                0xFF333951))),
                                                  )),
                                                  Center(
                                                      child: Container(
                                                    child: Text(" bestellen",
                                                        style: TextStyle(
                                                            fontSize: 13,
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
                                                      color: Color(0xFF333951)),
                                                ))),
                                          ])))),
                          Container(
                              height: 220,
                              width: 220,
                              child: new InkWell(
                                onTap: () async {
                                  setState(() {
                                    // popupShow = true;
                                  });
                                  showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                            content: SingleChildScrollView(
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
                                                        child: InkResponse(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            setState(() {
                                                              //  popupShow =
                                                              //      false;
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
                                                          children: <Widget>[
                                                            // Text(
                                                            //     'Manage Topics: ${fromChange['name']}'),
                                                            Container(
                                                                child: Center(
                                                                    child: Text(
                                                                        'Bitte geben Sie Ihren Aktivierungscode ein, um unsere vollständigen Funktionen für das gesamte Schuljahr nutzen zu können',
                                                                        textAlign:
                                                                            TextAlign
                                                                                .center,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Color(0xFF333951))))),
                                                            SizedBox(
                                                              child: Container(
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
                                                              child: Container(
                                                                height: 25,
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
                                                              child: Container(
                                                                child:
                                                                    Container(
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets
                                                                          .fromLTRB(
                                                                              80,
                                                                              2,
                                                                              80,
                                                                              2),
                                                                      child:
                                                                          Column(
                                                                        children: <
                                                                            Widget>[
                                                                          Container(
                                                                            decoration:
                                                                                new BoxDecoration(boxShadow: [
                                                                              new BoxShadow(
                                                                                color: Colors.grey.withOpacity(.2),
                                                                                blurRadius: 14,
                                                                              ),
                                                                            ]),
                                                                            child:
                                                                                Card(
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
                                                                            decoration:
                                                                                new BoxDecoration(boxShadow: [
                                                                              new BoxShadow(
                                                                                color: Colors.grey.withOpacity(.2),
                                                                                blurRadius: 14,
                                                                              ),
                                                                            ]),
                                                                            child:
                                                                                Card(
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
                                                              height: MediaQuery.of(
                                                                          context)
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
                                                                                            child: AddNewYear(),
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
                                                                                            //     popupShow = false;
                                                                                          });
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
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: <Widget>[
                                                                              Container(
                                                                                child: InkWell(
                                                                                  child: Text(
                                                                                    "Weiter",
                                                                                    style: TextStyle(color: Color(0xFFff8300), fontSize: 20.0),
                                                                                  ),
                                                                                  onTap: () {
                                                                                    _submit();
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                child: Container(
                                                                                  width: 18,
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
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1,
                                              child: Image.asset(
                                                  'assets/images/password.png',
                                                  width: 40,
                                                  height: 71)),
                                          Column(children: <Widget>[
                                            Center(
                                                child: Container(
                                              child: Text("  Aktivierungscode ",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Color(0xFF333951))),
                                            )),
                                            Center(
                                                child: Container(
                                              child: Text(
                                                  "eingeben und neues  ",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Color(0xFF333951))),
                                            )),
                                            Center(
                                                child: Container(
                                              child: Text(" Schuljahr starten ",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Color(0xFF333951))),
                                            )),
                                          ]),
                                        ])),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
