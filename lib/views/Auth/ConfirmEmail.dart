import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:docu_diary/config/url.dart';

class ConfirmEmailView extends StatefulWidget {
  static final String id = 'Confirm_Email';

  @override
  _ConfirmEmailViewState createState() => _ConfirmEmailViewState();
}

class _ConfirmEmailViewState extends State<ConfirmEmailView> {
  static final _baseUrl = BaseUrl.urlAPi;

  final _formKey = GlobalKey<FormState>();
  String _codeConfirmation;

  void _submit() async {
    final prefs = await SharedPreferences.getInstance();

    final confirmationCode = prefs.getString('confirmationCode') ?? 0;

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if (_codeConfirmation == confirmationCode) {
        final prefs = await SharedPreferences.getInstance();

        final email = prefs.getString('email') ?? '';
        final password = prefs.getString('password') ?? '';

        Map<String, dynamic> data = {
          'email': email.trim(),
          'password': password.trim(),
        };

        try {
          await http.post(
            '$_baseUrl/auth/validate-compte',
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data),
          );
        } catch (e) {}

        Navigator.of(context).pushNamed('/config');
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: const Text('code confirmation Error'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }
    }
  }

  void _sendCode() async {
    final prefs = await SharedPreferences.getInstance();

    final email = prefs.getString('email') ?? '';

    Map<String, dynamic> data = {
      'email': email.trim(),
    };

    try {
      await http.post(
        '$_baseUrl/auth/send-confirmation',
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Form(
                    key: _formKey,
                    child: Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width / 3.3,
                              height: MediaQuery.of(context).size.height / 3,
                              // color: Colors.red,
                              child: Center(
                                  child: Container(
                                width: MediaQuery.of(context).size.width / 8.5,
                                child: Image.asset(
                                  'assets/images/Logo.png',
                                ),
                              )),
                            )
                          ],
                        ),
                        Expanded(
                            child: Column(
                          children: <Widget>[
                            SizedBox(
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 5),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 6.5,
                              child: Center(
                                child: Image.asset(
                                  'assets/images/group_20.png',
                                ),
                              ),
                            ),
                            SizedBox(
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 12),
                            ),
                            Container(
                                child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Text(
                                'Sie haben Ihren Zugangscode per Email erhalten. Bitte geben Sie nun diesen Code ein, um Ihre Registrierung abzuschließen.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20, color: Color(0xFF333951)),
                              ),
                            )),
                            SizedBox(
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 25),
                            ),
                            Container(
                              child: Container(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(20, 2, 20, 2),
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                decoration: new BoxDecoration(
                                                    boxShadow: [
                                                      new BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(.2),
                                                        blurRadius: 14,
                                                      ),
                                                    ]),
                                                child: Card(
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1.0),
                                                  ),
                                                  child: Container(
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                          left: BorderSide(
                                                        //                   <--- left side
                                                        color: Colors.black,
                                                        width: 5.0,
                                                      )),
                                                    ),
                                                    child: Center(
                                                      child: TextFormField(
                                                        decoration:
                                                            (InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .fromLTRB(
                                                                      15.0,
                                                                      10.0,
                                                                      20.0,
                                                                      10.0),
                                                          labelText:
                                                              'Bestätigungscode',
                                                        )),
                                                        onSaved: (input) =>
                                                            _codeConfirmation =
                                                                input,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Container(
                                height: MediaQuery.of(context).size.height / 10,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Container(
                                          child: FlatButton(
                                            onPressed: _sendCode,
                                            padding: EdgeInsets.all(10.0),
                                            child: Text(
                                              "Code nochmal senden",
                                              style: TextStyle(
                                                  color: Color(0xFFff8300),
                                                  fontSize: 14.7),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )),

                            Expanded(
                              child: SizedBox(
                                child: Container(
                                    height: MediaQuery.of(context).size.height /
                                        12),
                              ),
                            ),

                            Row(
                                //           height:MediaQuery.of(context).size.height / 18) ,
                                children: <Widget>[
                                  SizedBox(
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                40),
                                  ),
                                  Expanded(
                                    child: SizedBox(),
                                  ),
                                  Container(
                                    child: FlatButton(
//                                          onPressed: _submit,
                                      padding: EdgeInsets.all(10.0),
                                      child: Text(
                                        "Weiter",
                                        style: TextStyle(
                                            color: Color(0xFFff8300),
                                            fontSize: 20.0),
                                      ),
                                      onPressed: () {
                                        _submit();
                                        // Navigator.of(context).pushNamed('/login');
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(),
                                  ),
                                ]),
                            SizedBox(
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 18),
                            ),
//----------------------------------------
                          ],
                        )),
                        Container(
                          width: MediaQuery.of(context).size.width / 3.5,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(children: <Widget>[
                                Expanded(
                                  child: SizedBox(),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: Image.asset(
                                    'assets/images/ConfirmEmail.png',
                                  ),
                                ),
                              ])
                            ],
                          ),
                        ),
                      ],
                    )))));
  }
}
