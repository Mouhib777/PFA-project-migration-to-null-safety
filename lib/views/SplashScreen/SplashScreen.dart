import 'package:docu_diary/views/Auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashScreenDocuDiary extends StatefulWidget {
  SplashScreenDocuDiary({Key key}) : super(key: key);

  @override
  _SplashScreenDocuDiaryState createState() => _SplashScreenDocuDiaryState();
}

class _SplashScreenDocuDiaryState extends State<SplashScreenDocuDiary> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      title: Text('Docudiary'),
      seconds: 3,
      navigateAfterSeconds: LoginView(),
      loadingText: Text('DocuDiary'),
      gradientBackground: LinearGradient(
          colors: [Colors.black, Colors.greenAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight),
      photoSize: 100.0,
      image: Image.asset('images/logoDocuDiary.png'),
      loaderColor: Colors.blueGrey,
    );
  }
}
