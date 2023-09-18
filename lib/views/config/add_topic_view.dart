import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:docu_diary/blocs/config/bloc.dart';
import 'package:docu_diary/connectionStatusSingleton.dart';
import 'package:docu_diary/models/models.dart';
import 'package:docu_diary/utils/snackbar.dart';
import 'package:docu_diary/views/config/suggestions.dart';
import 'package:docu_diary/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color getTopicColor(String topicColor) {
  if (topicColor != '') return Color(int.parse('$topicColor'));
  return Colors.black;
}

class AddTopicWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Function moveToPage;
  AddTopicWidget(this.moveToPage);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ConfigBloc(),
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          body:
              SafeArea(child: AddTopicWidgetContent(moveToPage, _scaffoldKey))),
    );
  }
}

class AddTopicWidgetContent extends StatefulWidget {
  final Function moveToPage;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  AddTopicWidgetContent(this.moveToPage, this._scaffoldKey);
  @override
  _AddTopicWidgetContentState createState() =>
      _AddTopicWidgetContentState(moveToPage, _scaffoldKey);
}

class _AddTopicWidgetContentState extends State<AddTopicWidgetContent> {
  final Function moveToPage;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  _AddTopicWidgetContentState(this.moveToPage, this._scaffoldKey);

  StreamSubscription _connectionChangeStream;

  @override
  void initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    new Future.delayed(Duration.zero, () {
      _connectionChangeStream =
          connectionStatus.connectionChange.listen(connectionChanged);
      context.bloc<ConfigBloc>()..add(LoadTopics());
    });
  }

  void connectionChanged(dynamic hasConnection) {
    context.bloc<ConfigBloc>()..add(UpdateConnectionStatus(hasConnection));
    if (hasConnection) {
      synchronize();
    }
  }

  @override
  void dispose() {
    _connectionChangeStream.cancel();
    super.dispose();
  }

  void _showSnackbarConfigFailure() {
    _hideSnackbar();
  }

  void synchronize() => context.bloc<ConfigBloc>()..add(Synchronize());

  void _showSnackbarConnectionStatus(bool connected) {
    _hideSnackbar();
    SnackBarUtils.showSnackbarConnectionStatus(
        _scaffoldKey, connected, _hideSnackbar);
  }

  void _showSnackbarSynchronizeStart() {
    _hideSnackbar();
    SnackBarUtils.showSnackbarSynchronizeStart(_scaffoldKey);
  }

  void _showSnackbarSynchronizeRetry() {
    _hideSnackbar();
    SnackBarUtils.showSnackbarSynchronizeRetry(_scaffoldKey, synchronize);
  }

  void _hideSnackbar() {
    SnackBarUtils.hideSnackbar(_scaffoldKey);
  }

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
        _showSnackbarConfigFailure();
      } else if (state is SynchronizeStart) {
        _showSnackbarSynchronizeStart();
      } else if (state is SynchronizeError) {
        _showSnackbarSynchronizeRetry();
      } else if (state is SynchronizeEnd) {
        _hideSnackbar();
      } else if (state is ConnectionStatus) {
        final connected = state.isConnected;
        _showSnackbarConnectionStatus(connected);
      }
    }, buildWhen: (previous, current) {
      return current is ConfigLoadInProgress ||
          current is ConfigLoadTopicsSuccess;
    }, builder: (context, state) {
      if (state is ConfigLoadInProgress) {
        return Center(
          child: Container(child: LoadingIndicator()),
        );
      } else if (state is ConfigLoadTopicsSuccess) {
        final Class cls = state.cls;
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
                      'Bereiche/Fächer festlegen',
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
                      'Jetzt wählen Sie bis zu zwölf Bereiche/Fächer, die Sie in dieser Klasse beobachten möchten. Geben Sie außerdem jedem Bereich/Fach eine passende Farbe, indem Sie auf das erscheinende Kreissymbol klicken. ÜBRIGENS: Die einzelnen Schüler in jeder Klasse legen Sie später auf Ihrem Dashboard an.',
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
                      AddTopicFormField(cls: cls),
                      SizedBox(height: 20),
                      Expanded(child: TopicList(cls: cls))
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

class AddTopicFormField extends StatefulWidget {
  final Class cls;
  AddTopicFormField({Key key, @required this.cls}) : super(key: key);

  @override
  _AddTopicFormFieldState createState() => _AddTopicFormFieldState(this.cls);
}

class _AddTopicFormFieldState extends State<AddTopicFormField> {
  Class cls;
  _AddTopicFormFieldState(this.cls);

  @override
  didUpdateWidget(AddTopicFormField oldWidget) {
    setState(() {
      cls = widget.cls;
    });
  }

  final GlobalKey<AutoCompleteTextFieldState<String>> textKey = GlobalKey();
  SimpleAutoCompleteTextField textField;

  showDialogNoClass(BuildContext context) {
    // set up the buttons

    Widget continueButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Fortfahren"),
      content: Text(
          "Bevor Sie einen Bereich oder ein Fach anlegen können, erstellen Sie bitte zunächst eine Klasse im vorherigen Schritt."),
      actions: [
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

  showDialogexistTopics(BuildContext context) {
    // set up the buttons

    Widget continueButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Fortfahren"),
      content: Text("Thema existiert in Ihrer Liste"),
      actions: [
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

  _triggerSubmit(BuildContext context, String topicName) {
    if (topicName.isEmpty) {
      return;
    }
    if (cls == null) {
      return showDialogNoClass(context);
    }
    final Topic topic =
        cls.topics.firstWhere((e) => e.name == topicName, orElse: () => null);
    if (topic != null) {
      return showDialogexistTopics(context);
    }
    context.bloc<ConfigBloc>()..add(AddTopic(topicName));
  }

  @override
  Widget build(BuildContext context) {
    textField = SimpleAutoCompleteTextField(
        key: textKey,
        decoration: InputDecoration(
            labelText: 'Fächer, Bereiche, Themen ...',
            labelStyle: TextStyle(color: Color(0xFFaeaeae), fontSize: 15.3)),
        suggestions: suggestions,
        clearOnSubmit: true,
        textSubmitted: (text) {
          _triggerSubmit(context, text);
        });

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
                title: textField,
                trailing: InkWell(
                  highlightColor: Colors.white,
                  child: Icon(
                    Icons.add,
                    color: Color(0xFFff8300),
                    size: 24,
                  ),
                  onTap: () {
                    textField.triggerSubmitted();
                  },
                )),
          ),
        ),
      ),
    );
  }
}

class TopicList extends StatefulWidget {
  final Class cls;
  TopicList({Key key, @required this.cls}) : super(key: key);
  @override
  _ClassListState createState() => _ClassListState(cls);
}

class _ClassListState extends State<TopicList> {
  Class cls;
  _ClassListState(this.cls);

  @override
  didUpdateWidget(TopicList oldWidget) {
    setState(() {
      cls = widget.cls;
    });
  }

  _pickColor(Topic topic) {
    return showDialog(
      context: context,
      builder: (BuildContext context2) {
        return AlertDialog(
          title: Text('Wählen Sie eine passende Farbe'),
          content: SingleChildScrollView(
            child: BlockPicker(
                pickerColor: getTopicColor(topic.color),
                onColorChanged: (Color color) {
                  context.bloc<ConfigBloc>()
                    ..add(UpdateTopicColor(
                        topic, "0x" + color.value.toRadixString(16)));
                  Navigator.of(context).pop();
                }),
          ),
        );
      },
    );
  }

  _updateTopicName(BuildContext context, Topic topic, String topicName) {
    if (topicName.isEmpty || topic.name == topicName) {
      Navigator.of(context).pop();
      return;
    }
    final Topic fetchTopic =
        cls.topics.firstWhere((e) => e.name == topicName, orElse: () => null);
    if (fetchTopic != null) {
      Navigator.of(context).pop();
      return;
    }
    context.bloc<ConfigBloc>()..add(UpdateTopicName(topic, topicName));
    Navigator.of(context).pop();
  }

  showDialogEditTopic(BuildContext context, Topic topic) {
    return showDialog(
      context: context,
      builder: (BuildContext context2) {
        final topicController = TextEditingController(text: topic.name);
        return AlertDialog(
          actions: [
            FlatButton(
                onPressed: () async {
                  _updateTopicName(context, topic, topicController.text);
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
                                      text: 'Unterkategorien festlegen: ',
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: Color(0xFF333951))),
                                  TextSpan(
                                      text: topic.name,
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
                                    'Geben Sie den neuen Themennamen ein',
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
                                                          topicController,
                                                      decoration: InputDecoration(
                                                          labelText:
                                                              'Fächer, Bereiche, Themen ...',
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

  showDialogDeleteTopic(BuildContext context, Topic topic) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Abbrechen"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Fortfahren"),
      onPressed: () {
        context.bloc<ConfigBloc>()..add(DeleteTopic(topic));
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Bereich/Fach entfernen"),
      content: Text(
          "Möchten Sie den ausgewählten Bereich bzw. das ausgewählte Fach und alle damit verbundenen Unterkategorien wirklich entfernen?"),
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

  Widget topicItem(Topic topic) {
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
              InkWell(
                highlightColor: Colors.white,
                onTap: () {
                  _pickColor(topic);
                },
                child: Container(
                    height: 40,
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Icon(
                        Icons.adjust,
                        color: getTopicColor(topic.color),
                      ),
                    ))),
              ),
              Container(
                child: Expanded(
                    child: Center(
                  child: Text(
                    topic.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: getTopicColor(topic.color),
                      fontSize: 13.0,
                    ),
                    maxLines: 2,
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
                    showDialogEditTopic(context, topic);
                  }),
              SizedBox(width: 10),
              Container(
                height: 40,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: InkWell(
                      highlightColor: Colors.white,
                      child: Icon(
                        Icons.clear,
                        color: Colors.black45,
                      ),
                      onTap: () => {
                        showDialogDeleteTopic(context, topic),
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
    if (cls == null) {
      return SizedBox();
    }
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Wrap(
                  children: cls.topics.map((e) => topicItem(e)).toList(),
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
      FlatButton(
          highlightColor: Colors.white,
          onPressed: () {
            moveToPage(1);
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
      FlatButton(
          highlightColor: Colors.white,
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
      FlatButton(
          highlightColor: Colors.white,
          onPressed: () {
            moveToPage(3);
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
