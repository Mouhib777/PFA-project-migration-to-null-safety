import 'package:cached_network_image/cached_network_image.dart';
import 'package:docu_diary/blocs/token/bloc.dart';
import 'package:docu_diary/blocs/user/bloc.dart';
import 'package:docu_diary/utils/snackbar.dart';
import 'package:docu_diary/views/dashboard/addNewYear.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:docu_diary/config/url.dart';
import 'package:flutter/cupertino.dart';
import 'package:docu_diary/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:docu_diary/models/models.dart';
import 'package:docu_diary/db/dao/token.dart';
import 'Dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

const List<String> pages = [
  '/profile',
  '/dashboard',
  '/report',
  '/observations',
  '/config'
];

class AppDrawer extends StatefulWidget {
  final String currentPage;
  final bool hasConnection;
  final GlobalKey<ScaffoldState> scaffoldKey;
  AppDrawer(
      {Key key, this.currentPage, this.scaffoldKey, this.hasConnection = true})
      : super(key: key);
  @override
  _AppDrawerState createState() => _AppDrawerState(
      currentPage: currentPage,
      hasConnection: hasConnection,
      scaffoldKey: scaffoldKey);
}

class _AppDrawerState extends State<AppDrawer> {
  String currentPage;
  bool hasConnection;
  GlobalKey<ScaffoldState> scaffoldKey;
  _AppDrawerState({this.currentPage, this.hasConnection, this.scaffoldKey});
  final _baseUrl = BaseUrl.urlAPi;
  Uint8List _bytesImage;
  SharedPreferences prefs;
  TokenDao _tokenDao = TokenDao();
  void initState() {
    super.initState();
    getProfilePicture();
    initializeMenu();
  }

  getProfilePicture() async {
    prefs = await SharedPreferences.getInstance();
    final String activeMenu = prefs.getString('activeMenu') ?? '';
    if (activeMenu.isEmpty) {
      prefs.setString('activeMenu', pages[1]);
    }
    Token token = await _tokenDao.getToken();
    try {
      final response = await http.get(
        '$_baseUrl/teacher/getpicture',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + token.accessToken
        },
      );
      if (response.statusCode == 200) {
        _bytesImage = base64.decode(response.body.split(', ').last);
        setState(() {
          _bytesImage = _bytesImage;
        });
      } else {}
    } catch (e) {}
  }

  initializeMenu() async {
    prefs = await SharedPreferences.getInstance();
    final String activeMenu = prefs.getString('activeMenu') ?? '';
    if (activeMenu.isEmpty) {
      prefs.setString('activeMenu', pages[1]);
    }
  }

  void _hideSnackbar() {
    SnackBarUtils.hideSnackbar(scaffoldKey);
  }

  void _showSnackbarAddPupils() {
    _hideSnackbar();
    SnackBarUtils.showSnackbarAddPupilsConnectionStatus(
        scaffoldKey, hasConnection, _hideSnackbar);
  }

  void _showSnackbarNewYear() {
    _hideSnackbar();
    SnackBarUtils.showSnackbarNewYearConnectionStatus(
        scaffoldKey, hasConnection, _hideSnackbar);
  }

  void _showSnackbarPupilsReport() {
    _hideSnackbar();
    SnackBarUtils.showSnackbarPupilsReportConnectionStatus(
        scaffoldKey, hasConnection, _hideSnackbar);
  }

  void _showSnackbarNoteHistory() {
    _hideSnackbar();
    SnackBarUtils.showSnackbarNoteHistoryConnectionStatus(
        scaffoldKey, hasConnection, _hideSnackbar);
  }

  _navigateToPage(String page) {
    if (!hasConnection) {
      if (page == pages[2]) {
        _showSnackbarPupilsReport();
        return;
      }
      if (page == pages[3]) {
        _showSnackbarNoteHistory();
        return;
      }
    }
    final String activeMenu = prefs.getString('activeMenu') ?? '';
    if (activeMenu != page) {
      prefs.setString('activeMenu', page);
      Navigator.pushReplacementNamed(context, page);
    }
  }

  @override
  didUpdateWidget(AppDrawer oldWidget) {
    if (oldWidget.currentPage != widget.currentPage ||
        oldWidget.hasConnection != widget.hasConnection) {
      setState(() {
        currentPage = widget.currentPage;
        hasConnection = widget.hasConnection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (BuildContext context) => UserBloc()..add(LoadUser()),
        ),
        BlocProvider<TokenBloc>(
          create: (BuildContext context) => TokenBloc(),
        ),
      ],
      child:
          BlocBuilder<UserBloc, UserState>(buildWhen: (previousState, state) {
        // return true/false to determine whether or not
        // to rebuild the widget with state
        return state is UserLoadSuccess;
      }, builder: (context, state) {
        User user;
        if (state is UserLoadSuccess) {
          user = state.user;
        }
        return Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.10,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Color(0xFF333951),
                borderRadius: BorderRadius.only(topRight: Radius.circular(60)),
              ),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            child: InkWell(
                          highlightColor: Colors.white,
                          onTap: () {
                            _navigateToPage(pages[1]);
                          },
                          child: Image.asset(
                            'assets/images/vector_smart_object_copy.png',
                            width: 30,
                          ),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: RichText(
                          text: TextSpan(
                              text: 'Docu',
                              style: TextStyle(
                                  color: Color(0xFFffffff), fontSize: 12),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Diary',
                                  style: TextStyle(
                                      color: Color(0xFFffffff),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                )
                              ]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  InkWell(
                      child: Container(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: _bytesImage != null
                                    ? Image.memory(
                                        _bytesImage,
                                        width: 50,
                                      )
                                    : Image.asset(
                                        'assets/images/profile.png',
                                        width: 50,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        _navigateToPage(pages[0]);
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  InkWell(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              height: 60,
                              width: 90,
                              child: PopupMenuButton<int>(
                                icon: Icon(
                                  Icons.add,
                                  color: Color(0xFFff7000),
                                ),
                                onSelected: (int value) {
                                  if (value == 1) {
                                    if (!hasConnection && !kIsWeb) {
                                      _showSnackbarAddPupils();
                                      return;
                                    }
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/addPupil',
                                      arguments: <String, String>{
                                        'CurrentPage': currentPage,
                                      },
                                    );
                                  } else if (value == 2) {
                                    Navigator.pushReplacementNamed(
                                        context, '/addClasses');
                                  } else {
                                    if (!hasConnection && !kIsWeb) {
                                      _showSnackbarNewYear();
                                      return;
                                    }
                                    showDialog(
                                        // barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: SingleChildScrollView(
                                              child: AddNewYear(),
                                            ),
                                          );
                                        });
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 1,
                                    child: Text(
                                      "Schüler hinzufügen",
                                      style:
                                          TextStyle(color: Color(0xFFff8400)),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    child: Text(
                                      "Klasse hinzufügen",
                                      style:
                                          TextStyle(color: Color(0xFFff8400)),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 3,
                                    child: Text(
                                      "neues Schuljahr anlegen",
                                      style:
                                          TextStyle(color: Color(0xFFff8400)),
                                    ),
                                  ),
                                ],
                                offset: Offset(100, 10),
                              ))
                        ]),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  InkWell(
                    child: Container(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Image.asset(
                              'assets/images/home.png',
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      _navigateToPage(pages[1]);
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  InkWell(
                    child: Container(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Image.asset(
                              'assets/images/folder.png',
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      _navigateToPage(pages[2]);
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  InkWell(
                    child: Container(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Image.asset(
                              'assets/images/message.png',
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      _navigateToPage(pages[3]);
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  InkWell(
                      child: Container(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Image.asset(
                                'assets/images/setting.png',
                                height: 20,
                                width: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        _navigateToPage(pages[4]);
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  InkWell(
                    child: Container(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logout.png',
                            height: 20,
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      context.bloc<TokenBloc>()..add(UserLogout());
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
