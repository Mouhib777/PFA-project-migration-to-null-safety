import 'package:bloc/bloc.dart';
import 'package:docu_diary/router/route_generator.dart';
import 'package:docu_diary/blocs/simple_bloc_observer.dart';
import 'package:docu_diary/blocs/token/bloc.dart';
import 'package:docu_diary/connectionStatusSingleton.dart';
import 'package:docu_diary/views/Auth/login_view.dart';
import 'package:docu_diary/views/useMobile.dart';
import 'package:docu_diary/views/dashboard/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ConnectionStatusSingleton connectionStatus =
      ConnectionStatusSingleton.getInstance();
  connectionStatus.initialize();
  // We can set a Bloc's observer to an instance of `SimpleBlocObserver`.
  // This will allow us to handle all transitions and errors in SimpleBlocObserver.
  Bloc.observer = SimpleBlocObserver();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.grey[300]);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('de'),
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFFB415B),
        fontFamily: 'Cera-Medium',
        highlightColor: Colors.black,
      ),
      home: BlocProvider(
        create: (BuildContext context) => TokenBloc()..add(LoadToken()),
        child: NextPage(),
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

class NextPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocBuilder<TokenBloc, TokenState>(builder: (context, state) {
      if (state is TokenLoadInProgress) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is TokenLoadSuccess && state.token != null) {
        return Dashboard();
      } else {
        return MediaQuery.of(context).size.width > 767
            ? LoginView()
            : UseMobile();
      }
    });
  }
}
