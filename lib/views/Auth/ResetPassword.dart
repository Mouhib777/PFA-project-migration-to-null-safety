import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:docu_diary/blocs/resetPassword/resetPassword_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:formz/formz.dart';

import 'login_view.dart';

class ResetPasswordView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocProvider(
          create: (context) => ResetPasswordBloc(),
          child: SingleChildScrollView(
              child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: ResetPasswordForm())),
        ));
  }
}

class ResetPasswordForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ResetPasswordBloc, ResetPasswordState>(
        listener: (context, state) {
          if (state.status.isInProgressOrSuccess) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Bestätigung'),
                    content:
                        const Text('Ihr Passwort wurde erfolgreich geändert!'),
                    actions: <Widget>[
                      ElevatedButton(
                        child: Text('Ok'),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/login');
                        },
                      ),
                    ],
                  );
                });
          }
          if (state.status.isFailure) {
            //! voir lib/utils/snackbar
            // Scaffold.of(context)
            //   ..hideCurrentSnackBar()
            //   ..showSnackBar(
            //     SnackBar(
            //         backgroundColor: Colors.red,
            //         content: Text('Der von Ihnen angegebene Code ist falsch.')),
            //   );
          }

          if (state.status.isInProgressOrSuccess) {
             //! voir lib/utils/snackbar
            // Scaffold.of(context)
            //   ..hideCurrentSnackBar()
            //   ..showSnackBar(
            //     SnackBar(content: Text('Submitting...')),
            //   );
          }
        },
        child: Form(
            child: Row(
          children: <Widget>[Logo(), FormResetBloc(), LogoStudent()],
        )));
  }
}

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            // color: Colors.red,
            width: MediaQuery.of(context).size.width * 0.25,
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
    );
  }
}

class FormResetBloc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        // color: Colors.blue,
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          children: <Widget>[
            SizedBox(
              child:
                  Container(height: MediaQuery.of(context).size.height * 0.1),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Center(
                child: Image.asset(
                  'assets/images/group_20.png',
                ),
              ),
            ),
            SizedBox(
              child:
                  Container(height: MediaQuery.of(context).size.height * 0.05),
            ),
            Container(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Text(
                'Passwort zurücksetzen.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Color(0xFF333951)),
              ),
            )),
            SizedBox(
              child:
                  Container(height: MediaQuery.of(context).size.height * 0.05),
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
                              CodeForm(),
                              PasswordForm(),
                              ConfirmPasswordForm()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SizedBox(
                child:
                    Container(height: MediaQuery.of(context).size.height / 12),
              ),
            ),

            SubmitForm(),
            SizedBox(
              child: Container(height: MediaQuery.of(context).size.height / 18),
            ),
//----------------------------------------
          ],
        ));
  }
}

class CodeForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
        buildWhen: (previous, current) => previous.code != current.code,
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.12,
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
                    decoration: (InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                      hintText: 'Code eingeben',
                      errorText: state.code.isNotValid
                          ? 'Bitte trage einen korrekten Code ein'
                          : null,
                    )),
                    onChanged: (value) {
                      // context
                      //     .bloc<ResetPasswordBloc>()
                      //     .add(CodeChanged(code: value));
                    },
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class PasswordForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
        buildWhen: (previous, current) => previous.password != current.password,
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.12,
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
                    decoration: (InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                      hintText: 'Passwort',
                      errorText: state.password.isNotValid
                          ? 'Das Passwort muss mindestens 6 Zeichen lang sein'
                          : null,
                    )),
                    obscureText: true,
                    onChanged: (value) {
                      // context
                      //     .bloc<ResetPasswordBloc>()
                      //     .add(PasswordChanged(password: value));
                    },
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class ConfirmPasswordForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
        buildWhen: (previous, current) =>
            previous.confirmPassword != current.confirmPassword,
        builder: (context, state) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.12,
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
                    decoration: (InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                      hintText: 'Bestätigung Ihres Passworts',
                      errorText: (state.confirmPassword.value !=
                                  state.password.value) ||
                              state.confirmPassword.isNotValid
                          ? 'Bestätigung stimmt nicht mit dem Passwort überein'
                          : null,
                    )),
                    obscureText: true,
                    onChanged: (value) {
                      // context
                      //     .bloc<ResetPasswordBloc>()
                      //     .add(ConfirmPasswordChanged(confirmPassword: value));
                    },
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class SubmitForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          return Container(
            child: Row(
                //           height:MediaQuery.of(context).size.height / 18) ,
                children: <Widget>[
                  Container(
                      // color: Colors.blue,

                      child: InkWell(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginView()));
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
                                        style: TextStyle(
                                            color: Color(0xFFff8300),
                                            fontSize: 20.0),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginView()));
                                      },
                                    ),
                                  ),
                                ],
                              )))),
                  Expanded(
                    child: SizedBox(),
                  ),
                  Container(
                    child: ElevatedButton(
                      onPressed:(){

                      },
                      //  state.status.isValidated
                      //     ? () => context
                      //         .bloc<ResetPasswordBloc>()
                      //         .add(FormSubmitted())
                      //     : null,
                      // padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Bestätigen",
                        style:
                            TextStyle(color: Color(0xFFff8300), fontSize: 20.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Container(
                        width: MediaQuery.of(context).size.width / 25),
                  ),
                ]),
          );
        });
  }
}

class LogoStudent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        // color: Colors.red,
        width: MediaQuery.of(context).size.width * 0.25,
        child: Container(
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
                    'assets/images/high_school_student.png',
                  ),
                ),
              ])
            ],
          ),
        ));
  }
}
