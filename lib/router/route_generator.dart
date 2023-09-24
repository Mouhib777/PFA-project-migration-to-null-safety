import 'package:docu_diary/views/config/config.dart';
import 'package:docu_diary/views/AddPupils/AddPupils.dart';
import 'package:docu_diary/views/Auth/ConfirmEmail.dart';
import 'package:docu_diary/views/Auth/Register.dart';
import 'package:docu_diary/views/Auth/forget_password.dart';
import 'package:docu_diary/views/Auth/login_view.dart';
import 'package:docu_diary/views/Auth/ResetPassword.dart';
import 'package:docu_diary/views/Observations/Observation_history.dart';
import 'package:docu_diary/views/Settings/Settings.dart';
import 'package:docu_diary/views/dashboard/home.dart';
import 'package:docu_diary/views/pupilsReport/pupilsReport.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginView());

      case '/forgetPassword':
        return MaterialPageRoute(builder: (_) => ForgetPasswordView());

      case '/confirmEmail':
        return MaterialPageRoute(builder: (_) => ConfirmEmailView());

      case '/Register':
        return MaterialPageRoute(builder: (_) => RegisterView());

      case '/forgetPassword':
        return MaterialPageRoute(builder: (_) => RegisterView());

      case '/config':
        return MaterialPageRoute(builder: (_) => ConfigView());

      case '/addClasses':
        return MaterialPageRoute(builder: (_) => ConfigView(initialPage: 1));

      case '/sort_topics':
        return MaterialPageRoute(builder: (_) => ConfigView(initialPage: 3));

      case '/addPupil':
        if (args is Map) {
          return MaterialPageRoute(
              builder: (_) => AddPupilsView(
                    argument: args,
                  ));
        } else
          return MaterialPageRoute(builder: (_) => AddPupilsView());
        break;

      case '/dashboard':
        return MaterialPageRoute(builder: (_) => Dashboard());

      case '/profile':
        return MaterialPageRoute(builder: (_) => SettingsView());

      case '/ResetPasswordView':
        return MaterialPageRoute(builder: (_) => ResetPasswordView());
      case '/observations':
        return MaterialPageRoute(builder: (_) => Observations());
      case '/report':
        return MaterialPageRoute(builder: (_) => PupilsReport());
      // default:
      //   return _errorRoute();
    }
  }
}
