import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:docu_diary/blocs/register/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:docu_diary/blocs/token/bloc.dart';
import 'package:docu_diary/blocs/user/bloc.dart';
import 'Activation_code.dart';

class RegisterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: MultiBlocProvider(
          providers: [
            BlocProvider<RegisterBloc>(
              create: (BuildContext context) => RegisterBloc(),
            ),
            BlocProvider<UserBloc>(
              create: (BuildContext context) => UserBloc(),
            ),
            BlocProvider<TokenBloc>(
              create: (BuildContext context) => TokenBloc(),
            ),
          ],
          child: SingleChildScrollView(
              child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: RegisterForm())),
        ));
  }
}

class RegisterForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.status.isSubmissionSuccess) {
            Scaffold.of(context).hideCurrentSnackBar();
            context.bloc<TokenBloc>()..add(TokenAdded(state.userData.token));
            context.bloc<UserBloc>()..add(UserAdded(state.userData.user));
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Container(
                      child: ActivationCode(),
                    ),
                  );
                });
          }
          if (state.status.isSubmissionFailure) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                        'Diese E-Mail wird bereits von einem Nutzer verwendet')),
              );
          }

          if (state.status.isSubmissionInProgress) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Submitting...')),
              );
          }
        },
        child: Form(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: (MediaQuery.of(context).size.width) * 0.6,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      Logo(),
                      FormHeader(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      Container(
                        child: Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: SingleChildScrollView(
                                child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(120, 2, 120, 2),
                                    child: Column(
                                      children: <Widget>[
                                        NameInput(),
                                        EmailInput(),
                                        PasswordInput(),
                                        ConfirmPasswordInput(),
                                        SubmitButton(),
                                      ],
                                    )))),
                      ),
                      FormFooter()
                    ],
                  ),
                ),
              ),
              SideImage(),
            ],
          ),
        ));
  }
}

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      child: Center(
          child: Image.asset(
        'assets/images/Logo.png',
      )),
    );
  }
}

class FormHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              'Registrieren Sie sich hier!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontStyle: FontStyle.normal,
                letterSpacing: 0.5,
                fontSize: 20,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class NameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
        buildWhen: (previous, current) => previous.name != current.name,
        builder: (context, state) {
          return Container(
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
                    onEditingComplete: state.status.isValidated
                        ? () =>
                            context.bloc<RegisterBloc>().add(FormSubmitted())
                        : null,
                    decoration: (InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                      hintText: 'Name',
                      errorText: state.name.invalid
                          ? 'Name muss mindestens 3 Zeichen lang sein'
                          : null,
                    )),
                    onChanged: (value) {
                      context
                          .bloc<RegisterBloc>()
                          .add(NameChanged(name: value));
                    },
                  ),
                ),
              ),
              /*Name*/
            ),
          );
        });
  }
}

class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
        buildWhen: (previous, current) => previous.email != current.email,
        builder: (context, state) {
          return Container(
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
                      onEditingComplete: state.status.isValidated
                          ? () =>
                              context.bloc<RegisterBloc>().add(FormSubmitted())
                          : null,
                      decoration: (InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                        hintText: 'Email',
                        errorText: state.email.invalid
                            ? 'Bitte geben Sie eine gültige E-Mail an'
                            : null,
                      )),
                      onChanged: (value) {
                        context
                            .bloc<RegisterBloc>()
                            .add(EmailChanged(email: value));
                      },
                      onSaved: (input) => {}),
                ),
              ),
              /*Name*/
            ),
          );
        });
  }
}

class PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
        buildWhen: (previous, current) => previous.password != current.password,
        builder: (context, state) {
          return Container(
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
                      onEditingComplete: state.status.isValidated
                          ? () =>
                              context.bloc<RegisterBloc>().add(FormSubmitted())
                          : null,
                      decoration: (InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                        hintText: 'Passwort',
                        errorText: state.password.invalid
                            ? 'Passwort muss mindestens 6 Zeichen lang sein'
                            : null,
                      )),
                      obscureText: true,
                      onChanged: (value) {
                        context
                            .bloc<RegisterBloc>()
                            .add(PasswordChanged(password: value));
                      },
                      onSaved: (input) => {}),
                ),
              ),
              /*Name*/
            ),
          );
        });
  }
}

class ConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
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
                      onEditingComplete: state.status.isValidated
                          ? () =>
                              context.bloc<RegisterBloc>().add(FormSubmitted())
                          : null,
                      decoration: (InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                        hintText: 'Bestätigung Ihres Passworts',
                        errorText: (state.confirmPassword.value !=
                                    state.password.value) ||
                                state.confirmPassword.invalid
                            ? 'Confirm Password invalid'
                            : null,
                      )),
                      obscureText: true,
                      onChanged: (value) {
                        context.bloc<RegisterBloc>().add(
                            ConfirmPasswordChanged(confirmPassword: value));
                      },
                      onSaved: (input) => {}),
                ),
              ),
              /*Name*/
            ),
          );
        });
  }
}

class SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.1,
              // color: Colors.red,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        child: InkWell(
                          child: FlatButton(
                              onPressed: state.status.isValidated
                                  ? () => context
                                      .bloc<RegisterBloc>()
                                      .add(FormSubmitted())
                                  : null,
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Registrierung",
                                    style: TextStyle(
                                        color: Color(0xFFff8300),
                                        fontSize: 20.0),
                                  ),
                                  SizedBox(
                                    child: Container(
                                      width: 40,
                                    ),
                                  ),
                                  Container(
                                      child: Image.asset(
                                          'assets/images/Login.png')),
                                ],
                              )),
                        ),
                      ),
                    ],
                  )
                ],
              ));
        });
  }
}

class FormFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width * 3.5,
      child: Center(
          child: Container(
              child: GestureDetector(
        child: RichText(
            text: TextSpan(
                text: 'Sie haben bereits einen Account? Klicken Sie',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0.5,
                  fontSize: 20,
                ),
                children: <TextSpan>[
              TextSpan(
                text: ' hier!',
                style: TextStyle(
                    color: Color(0xFFff8300),
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.5,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )
            ])),
        onTap: () {
          Navigator.of(context).pushNamed('/login');
        },
      ))),
    );
  }
}

class SideImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: (MediaQuery.of(context).size.height),
      width: (MediaQuery.of(context).size.width) * 0.35,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            child: Image.asset(
              'assets/images/side.png',
            ),
          ),
        ],
      ),
    );
  }
}
