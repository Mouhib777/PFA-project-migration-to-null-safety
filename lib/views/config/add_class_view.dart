import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:docu_diary/blocs/config/bloc.dart';
import 'package:docu_diary/connectionStatusSingleton.dart';
import 'package:docu_diary/models/models.dart';
import 'package:docu_diary/utils/snackbar.dart';
import 'package:docu_diary/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddClassWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Function moveToPage;
  AddClassWidget(this.moveToPage);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ConfigBloc(),
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          body:
              SafeArea(child: AddClassWidgetContent(moveToPage, _scaffoldKey))),
    );
  }
}

class AddClassWidgetContent extends StatefulWidget {
  final Function? moveToPage;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  AddClassWidgetContent(this.moveToPage, this._scaffoldKey);
  @override
  _AddClassWidgetContentState createState() =>
      _AddClassWidgetContentState(moveToPage, _scaffoldKey);
}

class _AddClassWidgetContentState extends State<AddClassWidgetContent> {
  // final Function? moveToPage;
  // final GlobalKey<ScaffoldState>? _scaffoldKey;
  //  _AddClassWidgetContentState(this.moveToPage, this._scaffoldKey);

  StreamSubscription? _connectionChangeStream;
  
  _AddClassWidgetContentState(Function? moveToPage, GlobalKey<ScaffoldState> scaffoldKey);
  
  Function get moveToPage => (){};

  @override
  void initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    new Future.delayed(Duration.zero, () {
      _connectionChangeStream =
          connectionStatus.connectionChange.listen(connectionChanged);
      // context.bloc<ConfigBloc>()..add(LoadClasses());
    });
  }

  void connectionChanged(dynamic hasConnection) {
    // context.bloc<ConfigBloc>()..add(UpdateConnectionStatus(hasConnection));
    if (hasConnection) {
      // synchronize();
    }
  }

  @override
  void dispose() {
    _connectionChangeStream!.cancel();
    super.dispose();
  }
//! voir lib/utils/snackbar
  // void _showSnackbarConfigFailure() {
  //   _hideSnackbar();
  // }

  // void synchronize() => context.bloc<ConfigBloc>()..add(Synchronize());

  // void _showSnackbarConnectionStatus(bool connected) {
  //   _hideSnackbar();
  //   SnackBarUtils.showSnackbarConnectionStatus(
  //       _scaffoldKey, connected, _hideSnackbar);
  // }

  // void _showSnackbarSynchronizeStart() {
  //   _hideSnackbar();
  //   SnackBarUtils.showSnackbarSynchronizeStart(_scaffoldKey);
  // }

  // void _showSnackbarSynchronizeRetry() {
  //   _hideSnackbar();
  //   SnackBarUtils.showSnackbarSynchronizeRetry(_scaffoldKey, synchronize);
  // }

  // void _hideSnackbar() {
  //   SnackBarUtils.hideSnackbar(_scaffoldKey);
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return BlocConsumer<ConfigBloc, ConfigState>(
        listenWhen: (previous, current) {
      return current is ConfigFailure ||
          current is ConnectionStatus ||
          current is SynchronizeStart ||
          current is SynchronizeError ||
          current is SynchronizeEnd;
    }, listener: (context, state) {
      if (state is ConfigFailure) {
        // _showSnackbarConfigFailure();
      } else if (state is SynchronizeStart) {
        // _showSnackbarSynchronizeStart();
      } else if (state is SynchronizeError) {
        // _showSnackbarSynchronizeRetry();
      } else if (state is SynchronizeEnd) {
        // _hideSnackbar();
      } else if (state is ConnectionStatus) {
        final connected = state.isConnected;
        // _showSnackbarConnectionStatus(connected);
      }
    }, buildWhen: (previous, current) {
      return current is ConfigLoadInProgress ||
          current is ConfigLoadClassSuccess;
    }, builder: (context, state) {
      if (state is ConfigLoadInProgress) {
        return Center(
          child: Container(child: LoadingIndicator()),
        );
      } else if (state is ConfigLoadClassSuccess) {
        final List<Class> classes = state.classes;
        return SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              height: height,
              width: width,
              child: Column(children: [
                SizedBox(height: 30),
                Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Image.asset('assets/images/Logo.png', height: 40),
                    AutoSizeText(
                      'Klassen hinzufügen',
                      maxLines: 1,
                      style:
                          TextStyle(color: Color(0xFFf45d27), fontSize: 20.0),
                    ),
                  ],
                )),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  height: 100,
                  child: Center(
                    child: Image.asset('assets/images/_e-university.png'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Center(
                    child: AutoSizeText(
                      'Hier können Sie neue Klassen anlegen, die Sie in diesem Schuljahr beobachten möchten. Schreiben Sie die Namen Ihrer Klassen auf. ÜBRIGENS: Die einzelnen Schüler in jeder Klasse legen Sie später auf Ihrem Dashboard an.',
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: TextStyle(fontSize: 20, color: Color(0xFF333951)),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      AddClassFormField(),
                      SizedBox(height: 20),
                      Expanded(child: ClassList(classes: classes))
                    ],
                  ),
                ),
                Container(height: 100, child: Actions(moveToPage)),
              ])),
        );
      } else {
        return Container();
      }
    });
  }
}

class AddClassFormField extends StatefulWidget {
  @override
  _AddClassFormFieldState createState() => _AddClassFormFieldState();
}

class _AddClassFormFieldState extends State<AddClassFormField> {
  final _textClassController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textClassController.dispose();
    super.dispose();
  }

  _triggerSubmit(BuildContext context) {
    if (_textClassController.text.isEmpty) {
      return;
    }
    // context.bloc<ConfigBloc>()..add(AddClass(_textClassController.text));
    _textClassController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Center(
      child: Container(
        height: height * 0.12,
        width: width * 0.4,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.07),
            blurRadius: 15,
          ),
        ]),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(
                color: Colors.black,
                width: 5.0,
              )),
            ),
            child: ListTile(
                title: TextField(
                    onSubmitted: (String value) {
                      _triggerSubmit(context);
                    },
                    controller: _textClassController,
                    decoration: InputDecoration(
                      labelText: 'Klasse',
                      labelStyle:
                          TextStyle(color: Color(0xFFaeaeae), fontSize: 14.7),
                      border: InputBorder.none,
                    )),
                trailing: InkWell(
                  child: Icon(
                    Icons.add,
                    color: Color(0xFFff8300),
                    size: 24,
                  ),
                  onTap: () {
                    _triggerSubmit(context);
                  },
                )),
          ),
        ),
      ),
    );
  }
}

class ClassList extends StatefulWidget {
  final List<Class> classes;
  ClassList({Key? key, required this.classes}) : super(key: key);
  @override
  _ClassListState createState() => _ClassListState(classes);
}

class _ClassListState extends State<ClassList> {
  List<Class> classes;
  _ClassListState(this.classes);

  @override
  didUpdateWidget(ClassList oldWidget) {
    setState(() {
      classes = widget.classes;
    });
  }

  showAlertDialog(BuildContext context, Class cls) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text("Abbrechen"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text("Fortfahren"),
      onPressed: () {
        // context.bloc<ConfigBloc>()..add(DeleteClass(cls));
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Klasse entfernen"),
      content: Text(
          "Möchten Sie die ausgewählte Klasse und alle damit verbundenen Schüler wirklich entfernen?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _updateClassName(BuildContext context, Class cls, String className) {
    if (className.isEmpty || cls.className == className) {
      Navigator.of(context).pop();
      return;
    }
    final Class? fetchClass =
        classes.firstWhere((e) => e.className == className, orElse: () => Class());
    if (fetchClass != null) {
      Navigator.of(context).pop();
      return;
    }
    // context.bloc<ConfigBloc>()..add(UpdateClassName(cls, className));
    Navigator.of(context).pop();
  }

  showDialogEditClass(BuildContext context, Class cls) {
    return showDialog(
      context: context,
      builder: (BuildContext context2) {
        final classController = TextEditingController(text: cls.className);
        return AlertDialog(
          actions: [
            ElevatedButton(
                onPressed: () async {
                  _updateClassName(context, cls, classController.text);
                },
                child: Container(
                    child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "Aktualisieren",
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Color(0xFFf45d27), fontSize: 20.0),
                  ),
                )))
          ],
          content: SingleChildScrollView(
              child: Container(
                  width: 800,
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerRight,
                        width: 770,
                        child: InkResponse(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.close, color: Color(0xFFf45d27)),
                        ),
                      ),
                      Container(
                        width: 550,
                        child: Column(
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Klassennamen festlegen: ',
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: Color(0xFF333951))),
                                  TextSpan(
                                      text: cls.className,
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Center(
                                child: Text(
                                    'Geben Sie den neuen Klassennamen ein',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF333951)))),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                                width: 450,
                                alignment: Alignment.centerRight,
                                child: Row(children: <Widget>[
                                  Container(
                                    width: 450,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Center(
                                          child: Container(
                                            decoration:
                                                BoxDecoration(boxShadow: [
                                              BoxShadow(
                                                color:
                                                    Colors.grey.withOpacity(.2),
                                                blurRadius: 14,
                                              ),
                                            ]),
                                            child: Card(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1.0),
                                              ),
                                              child: Container(
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                      left: BorderSide(
                                                    color: Colors.black,
                                                    width: 5.0,
                                                  )),
                                                ),
                                                child: Center(
                                                  child: ListTile(
                                                    selected: true,
                                                    title: TextField(
                                                      autofocus: true,
                                                      controller:
                                                          classController,
                                                      decoration: InputDecoration(
                                                          labelText: 'Klasse',
                                                          labelStyle: TextStyle(
                                                              color: Color(
                                                                  0xFFaeaeae),
                                                              fontSize: 15.3)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ])),
                          ],
                        ),
                      ),
                    ],
                  ))),
        );
      },
    );
  }

  Widget classItem(Class cls) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(.07),
          blurRadius: 15,
        ),
      ]),
      width: MediaQuery.of(context).size.width / 4.2,
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
        elevation: 0.0,
        child: Column(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Expanded(
                    child: Center(
                  child: Text(
                    cls.className!,
                  ),
                )),
              ),
              InkWell(
                  highlightColor: Colors.white,
                  child: Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Icon(
                        Icons.edit,
                        color: Colors.black45,
                      )),
                  onTap: () {
                    showDialogEditClass(context, cls);
                  }),
              SizedBox(width: 10),
              Container(
                height: 40,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: InkWell(
                      child: Icon(
                        Icons.clear,
                        color: Colors.black45,
                      ),
                      onTap: () => {
                        showAlertDialog(context, cls),
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Wrap(
                  children: classes.map((e) => classItem(e)).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Actions extends StatelessWidget {
  final Function moveToPage;
  Actions(this.moveToPage);

  void _skip(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('activeMenu', '/dashboard');
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      ElevatedButton(
          // highlightColor: Colors.white,
          onPressed: () {
            _skip(context);
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
                width: 10,
              ),
              Container(
                child: Text(
                  "Zurück",
                  style: TextStyle(color: Color(0xFFff8300), fontSize: 20.0),
                ),
              ),
            ],
          )),
      ElevatedButton(
          // highlightColor: Colors.white,
          onPressed: () {
            _skip(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(
                  "Überspringen",
                  style: TextStyle(fontSize: 20, color: Color(0xFF707070)),
                ),
              ),
            ],
          )),
      ElevatedButton(
          // highlightColor: Colors.white,
          onPressed: () {
            moveToPage(2);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Weiter",
                style: TextStyle(color: Color(0xFFff8300), fontSize: 20.0),
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                  height: 20, child: Image.asset('assets/images/login2.png')),
            ],
          ))
    ]);
  }
}
