import 'package:auto_size_text/auto_size_text.dart';
import 'package:docu_diary/blocs/login/bloc.dart';
import 'package:docu_diary/blocs/token/bloc.dart';
import 'package:docu_diary/blocs/user/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'Activation_code_login.dart';

class LoginView extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: MultiBlocProvider(
          providers: [
            BlocProvider<LoginBloc>(
              create: (BuildContext context) => LoginBloc(),
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
                  child: LoginForm())),
        ));
  }
}

class LoginForm extends StatelessWidget {
  final difference;

  const LoginForm({Key key, this.difference}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
        listenWhen: (previousState, state) {
          return state.status.isValidated;
        },
        listener: (context, state) async {
          if (state.status.isSubmissionSuccess) {
            Scaffold.of(context).hideCurrentSnackBar();
            context.bloc<TokenBloc>()..add(TokenAdded(state.userData.token));
            context.bloc<UserBloc>()..add(UserAdded(state.userData.user));
            final token = state.userData.token;
            final date2 = DateTime.now();
            int difference = DateTime.parse(state.userData.user.expirationDate)
                .difference(date2)
                .inHours;
            difference = (difference / 24).floor();

            if (difference <= 7 && difference > 0) {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: SingleChildScrollView(
                        child: ActivationCode(
                            difference: difference, token: token),
                      ),
                    );
                  });
              await Future.delayed(const Duration(seconds: 1));
            } else {
              if (difference > 7) {
                await Future.delayed(const Duration(seconds: 1));
                Navigator.of(context)
                    .pushNamed('/dashboard', arguments: state.userData.token);
              } else {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: SingleChildScrollView(
                          child: ActivationCode(difference: 0),
                        ),
                      );
                    });
              }
            }
          } else if (state.status.isSubmissionFailure) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Ungültige E-Mail oder Passwort')),
              );
          } else if (state.status.isSubmissionInProgress) {
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
                      Logo(),
                      FormHeader(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(120, 2, 120, 2),
                        child: Column(
                          children: <Widget>[
                            EmailInput(),
                            PasswordInput(),
                            SubmitButton(),
                          ],
                        ),
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
      margin: const EdgeInsets.only(top: 30),
      height: MediaQuery.of(context).size.height * 0.2,
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
      width: (MediaQuery.of(context).size.width) * 0.45,
      height: MediaQuery.of(context).size.height * 0.2,
      child: Center(
        child: AutoSizeText(
          'Melden Sie sich jetzt an und beginnen Sie mit Ihren persönlichen Schülerbeobachtungen!',
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            color: Colors.black54,
            fontStyle: FontStyle.normal,
            letterSpacing: 0.5,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) => previous.email != current.email,
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.2),
                blurRadius: 14,
              ),
            ]),
            child: Card(
              elevation: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                    color: Colors.black,
                    width: 7.0,
                  )),
                ),
                child: Center(
                  child: TextFormField(
                    onEditingComplete: state.status.isValidated
                        ? () => context.bloc<LoginBloc>().add(FormSubmitted())
                        : null,
                    initialValue: state.email.value,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                      labelText: 'E-Mail',
                      labelStyle:
                          TextStyle(color: Color(0xFFaeaeae), fontSize: 15.3),
                      errorText: state.email.invalid
                          ? 'Bitte geben Sie eine gültige E-Mail an'
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      context.bloc<LoginBloc>().add(EmailChanged(email: value));
                    },
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) => previous.password != current.password,
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.2),
                blurRadius: 14,
              ),
            ]),
            child: Card(
              elevation: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(
                    color: Colors.black,
                    width: 7.0,
                  )),
                ),
                child: Center(
                    child: TextFormField(
                  onEditingComplete: state.status.isValidated
                      ? () => context.bloc<LoginBloc>().add(FormSubmitted())
                      : null,
                  initialValue: state.password.value,
                  decoration: InputDecoration(
                    suffix: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/forgetPassword');
                      },
                      child: Text(
                        'Vergessen ?',
                        style:
                            TextStyle(color: Color(0xFFaeaeae), fontSize: 15.3),
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                    labelText: 'Passwort',
                    labelStyle:
                        TextStyle(color: Color(0xFFaeaeae), fontSize: 15.3),
                    errorText:
                        state.password.invalid ? 'Falsches Passwort' : null,
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    context
                        .bloc<LoginBloc>()
                        .add(PasswordChanged(password: value));
                  },
                )),
              ),
            ),
          );
        });
  }
}

class SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          return Container(
              margin: EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        child: FlatButton(
                            onPressed: state.status.isValidated
                                ? () => context
                                    .bloc<LoginBloc>()
                                    .add(FormSubmitted())
                                : null,
                            padding: EdgeInsets.all(10.0),
                            child: Row /*or Column*/ (
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "LOGIN",
                                  style: TextStyle(
                                      color: Color(0xFFff8300), fontSize: 22.0),
                                ),
                                SizedBox(
                                  child: Container(
                                    width: 40,
                                  ),
                                ),
                                Container(
                                    child:
                                        Image.asset('assets/images/Login.png')),
                              ],
                            )),
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
      height: MediaQuery.of(context).size.height * 0.2,
      width: MediaQuery.of(context).size.width * 3.5,
      child: Container(
          child: Center(
        child: GestureDetector(
          child: RichText(
            text: TextSpan(
                text: 'Noch nicht angemeldet? Registrieren Sie sich',
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
                ]),
          ),
          onTap: () {
            Navigator.of(context).pushNamed('/Register');
          },
        ),
      )),
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
