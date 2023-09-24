// import 'package:docu_diary/widgets/loading_indicator.dart';
// import 'package:flutter/material.dart';


 //! na7y les comments w ikhdem b script edheyya k test7a9 snackbar       
//            //!  ===> example of snackbar <====
//            //? final snackBar = SnackBar(
//            //?             content: Text('This is a Snackbar'),
//            //?             duration: Duration(seconds: 3),
//            //?           );

           // ?          ScaffoldMessenger.of(context).showSnackBar(snackBar);

// class SnackBarUtils {
//   static const String ONLINE_MESSAGE =
//       'Erneute Internetverbindung: Ihr Gerät ist wieder mit dem Internet verbunden.';

//   static const String DEFAULT_OFFLINE_MESSAGE =
//       'Fehlende Internetverbindung: Ihre Beobachtungen werden offline gespeichert und bei erneuter Internetverbindung automatisch synchronisiert.';

//   static const String SYNC_MESSAGE =
//       'Synchronisierung: Ihre Offline-Daten werden nun mit dem Server synchronisiert...';

//   static const String SYNC_RETRY_MESSAGE =
//       'Synchronisierungsfehler: Bitte versuchen Sie die Synchronisierung zu einem späteren Zeitpunkt noch einmal.';

//   static const String PUPILS_REPORT_OFFLINE_MESSAGE =
//       'Sie befinden sich derzeit im Offline-Modus. Der Schülerreport ist nur mit aktiver Internetverbindung abrufbar.';

//   static const String NOTE_HISTORY_OFFLINE_MESSAGE =
//       'Sie befinden sich derzeit im Offline-Modus. Die Beobachtungshistorie ist nur mit aktiver Internetverbindung abrufbar.';

//   static const String ADD_PUPILS_OFFLINE_MESSAGE =
//       'Sie befinden sich derzeit im Offline-Modus. Schüler können nur mit aktiver Internetverbindung angelegt werden.';

//   static const String NEW_YEAR_OFFLINE_MESSAGE =
//       'Sie befinden sich derzeit im Offline-Modus. Ein neues Schuljahr kann nur mit aktiver Internetverbindung angelegt werden.';

//   static void hideSnackbar(GlobalKey<ScaffoldState> _scaffoldKey) {
//     // _scaffoldKey.currentState.removeCurrentSnackBar();
//   }

//   static void showSnackbarConfigFailure(GlobalKey<ScaffoldState> _scaffoldKey, String message) {
//     _scaffoldKey.currentState.showSnackBar(
//       SnackBar(backgroundColor: Colors.red, content: Text(message)),
//     );
//   }

//   static void showSnackbarClassConfigFailure(
//       GlobalKey<ScaffoldState> _scaffoldKey) {
//     // _scaffoldKey.currentState.showSnackBar(
//       SnackBar(
//           backgroundColor: Colors.amber,
//           content: Text('Please add class befor')),
//     );
//   }

//   static void _showDefaultSnackbar(
//       GlobalKey<ScaffoldState> _scaffoldKey, String text, Color color) {
//     _scaffoldKey.currentState.showSnackBar(
//       SnackBar(
//         backgroundColor: color,
//         content: Text(text),
//       ),
//     );
//   }

//   static void showSnackbarConnectionStatus(
//       GlobalKey<ScaffoldState> _scaffoldKey,
//       bool connected,
//       Function onPressed) {
//     final String text = connected ? ONLINE_MESSAGE : DEFAULT_OFFLINE_MESSAGE;
//     final Color color = connected ? Colors.lime : Colors.yellow[700];
//     _showDefaultSnackbar(_scaffoldKey, text, color);
//   }

//   static void showSnackbarSynchronizeStart(
//       GlobalKey<ScaffoldState> _scaffoldKey) {
//     _scaffoldKey.currentState.showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.lime,
//         content: Container(
//           height: 30,
//           child: Row(children: [
//             Expanded(child: Text(SYNC_MESSAGE)),
//             Container(child: LoadingIndicator())
//           ]),
//         ),
//         duration: Duration(seconds: 5),
//       ),
//     );
//   }

//   static void showSnackbarSynchronizeRetry(
//       GlobalKey<ScaffoldState> _scaffoldKey, Function onPressed) {
//     _scaffoldKey.currentState.showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.red[400],
//         content: Container(
//           height: 30,
//           child: Text(SYNC_RETRY_MESSAGE),
//         ),
//         duration: Duration(minutes: 1),
//         action: SnackBarAction(
//           label: 'Wiederholen',
//           textColor: Colors.white,
//           onPressed: onPressed,
//         ),
//       ),
//     );
//   }

//   static void showSnackbarPupilsReportConnectionStatus(
//       GlobalKey<ScaffoldState> _scaffoldKey,
//       bool connected,
//       Function onPressed) {
//     final String text =
//         connected ? ONLINE_MESSAGE : PUPILS_REPORT_OFFLINE_MESSAGE;
//     final Color color = connected ? Colors.lime : Colors.yellow[700];
//     _showDefaultSnackbar(_scaffoldKey, text, color);
//   }

//   static void showSnackbarNoteHistoryConnectionStatus(
//       GlobalKey<ScaffoldState> _scaffoldKey,
//       bool connected,
//       Function onPressed) {
//     final String text =
//         connected ? ONLINE_MESSAGE : NOTE_HISTORY_OFFLINE_MESSAGE;
//     final Color color = connected ? Colors.lime : Colors.yellow[700];
//     _showDefaultSnackbar(_scaffoldKey, text, color);
//   }

//   static void showSnackbarAddPupilsConnectionStatus(
//       GlobalKey<ScaffoldState> _scaffoldKey,
//       bool connected,
//       Function onPressed) {
//     final String text = connected ? ONLINE_MESSAGE : ADD_PUPILS_OFFLINE_MESSAGE;
//     final Color color = connected ? Colors.lime : Colors.yellow[700];
//     _showDefaultSnackbar(_scaffoldKey, text, color);
//   }

//   static void showSnackbarNewYearConnectionStatus(
//       GlobalKey<ScaffoldState> _scaffoldKey,
//       bool connected,
//       Function onPressed) {
//     final String text = connected ? ONLINE_MESSAGE : NEW_YEAR_OFFLINE_MESSAGE;
//     final Color color = connected ? Colors.lime : Colors.yellow[700];
//     _showDefaultSnackbar(_scaffoldKey, text, color);
//   }
// }
