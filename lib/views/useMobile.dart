import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UseMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        highlightColor: Colors.grey[900],
        primaryColor: Color(0xFFFB415B),
        fontFamily: 'Cera-Medium',
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: (MediaQuery.of(context).size.height) * 0.05,
              ),
              TopImage(),
              Spacer(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: Text(
                    'Diese Anwendung kann nicht mit dem Smartphone verwendet werden. Bitte wechseln sie zu einem Tablet oder einem Computer um sich mit einem Konto zu registrieren.',
                    style: (TextStyle(
                        color: Color(0xFF333951),
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Spacer(),
              BottomImage(),
              SizedBox(
                height: (MediaQuery.of(context).size.height) * 0.05,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Container(
            height: (MediaQuery.of(context).size.height) * 0.2,
            width: (MediaQuery.of(context).size.width) * 0.4,
            child: Image.asset(
              'assets/images/high_school_student.png',
            ),
          ),
        ),
      ],
    );
  }
}

class TopImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Container(
            height: (MediaQuery.of(context).size.height) * 0.2,
            width: (MediaQuery.of(context).size.width) * 0.5,
            child: Image.asset(
              'assets/images/Logo.png',
            ),
          ),
        ),
      ],
    );
  }
}
