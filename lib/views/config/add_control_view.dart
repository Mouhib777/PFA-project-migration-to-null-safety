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

class AddControlWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Function moveToPage;
  AddControlWidget(this.moveToPage);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ConfigBloc(),
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          body: SafeArea(
              child: AddControlWidgetContent(moveToPage, _scaffoldKey))),
    );
  }
}

class AddControlWidgetContent extends StatefulWidget {
  final Function moveToPage;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  AddControlWidgetContent(this.moveToPage, this._scaffoldKey);
  @override
  _AddControlWidgetContentState createState() =>
      _AddControlWidgetContentState(moveToPage, _scaffoldKey);
}

class _AddControlWidgetContentState extends State<AddControlWidgetContent> {
  final Function moveToPage;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  _AddControlWidgetContentState(this.moveToPage, this._scaffoldKey);

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
                      'Unterkategorien',
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
                      'Ordnen Sie Ihren Bereichen/Fächern nun mindestens eine Unterkategorie hinzu. Dies können z.B. Lehrplanthemen sein. Wenn Sie ohne Unterkategorien arbeiten möchten, geben Sie bitte nochmal das Fach/den Bereich an.',
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
                      SizedBox(height: 20),
                      Expanded(child: TopicList(cls: cls))
                    ],
                  ),
                ),
                Container(height: 100, child: Actions(cls, moveToPage)),
              ])),
        );
      } else {
        return Container();
      }
    });
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

  TextEditingController _textController = TextEditingController(text: '');

  @override
  didUpdateWidget(TopicList oldWidget) {
    setState(() {
      cls = widget.cls;
    });
  }

  Widget controlsList(Topic topic, int topicIdx, Function removeControl) {
    return Wrap(
        children: topic.controls.map((Control control) {
      return Container(
          width: 300,
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            elevation: 2.0,
            child: Column(children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      child: Center(
                    child: Text(
                      control.controlName,
                      textAlign: TextAlign.center,
                    ),
                  )),
                  Container(
                    height: 45,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 15.0),
                        child: InkWell(
                          highlightColor: Colors.white,
                          child: Icon(
                            Icons.clear,
                            color: Color(0xFFf45d27),
                          ),
                          onTap: () {
                            removeControl(topic, topicIdx, control);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ]),
          ));
    }).toList());
  }

  _triggerSubmit(BuildContext context, Topic topic) {
    if (_textController.text.isNotEmpty && topic.controls.length < 10) {
      final controlExist = topic.controls
          .indexWhere((e) => e.controlName == _textController.text);
      if (controlExist < 0) {
        topic.controls.add(new Control(controlName: _textController.text));
      }
    }
    context.bloc<ConfigBloc>()..add(UpdateControls(topic));
    _textController.text = '';
    Navigator.of(context).pop();
  }

  showControlDialog(BuildContext context, Topic topic, int topicIdx) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context1) {
          return StatefulBuilder(builder: (context1, setState) {
            removeControl(Topic topic, int topicIdx, Control ctl) {
              topic.controls.remove(ctl);
              setState(() {
                cls.topics[topicIdx] = topic;
              });
            }

            _triggerAddControl(Topic topic, int topicIdx) {
              if (_textController.text.isNotEmpty &&
                  topic.controls.length < 10) {
                final controlExist = topic.controls
                    .indexWhere((e) => e.controlName == _textController.text);
                if (controlExist < 0) {
                  topic.controls
                      .add(new Control(controlName: _textController.text));
                  _textController.text = '';
                  setState(() {
                    cls.topics[topicIdx] = topic;
                  });
                } else {
                  _textController.text = '';
                }
              }
            }

            return AlertDialog(
              actions: [
                FlatButton(
                    onPressed: () {
                      _triggerSubmit(context, topic);
                    },
                    child: Container(
                      width: 200,
                      height: 30,
                      child: Center(
                        child: Text(
                          "Schließen",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: Color(0xFFf45d27), fontSize: 20.0),
                        ),
                      ),
                    ))
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
                                _triggerSubmit(context, topic);
                              },
                              child:
                                  Icon(Icons.close, color: Color(0xFFf45d27)),
                            ),
                          ),
                          Container(
                            width: 600,
                            child: Column(
                              children: <Widget>[
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'Unterkategorien:',
                                          style: TextStyle(
                                              fontSize: 30,
                                              color: Color(0xFF333951))),
                                      TextSpan(
                                          text: ' ${topic.name}',
                                          style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: Color(int.parse(
                                                  '${topic.color}')))),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 25),
                                Center(
                                    child: Text(
                                        'Ordnen Sie Ihren Bereichen/Fächern nun mindestens eine Unterkategorie hinzu. Dies können z.B. Lehrplanthemen sein. Wenn Sie ohne Unterkategorien arbeiten möchten, geben Sie bitte nochmal das Fach/den Bereich an.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF333951)))),
                                SizedBox(height: 20),
                                Container(
                                  width: MediaQuery.of(context1).size.width / 3,
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(.2),
                                      blurRadius: 14,
                                    ),
                                  ]),
                                  child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(1.0),
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
                                          trailing: InkWell(
                                            highlightColor: Colors.white,
                                            child: Icon(
                                              Icons.add,
                                              color: Color(0xFFff8300),
                                              size: 24,
                                            ),
                                            onTap: () {
                                              _triggerAddControl(
                                                  topic, topicIdx);
                                            },
                                          ),
                                          title: TextField(
                                            enabled: topic.controls.length < 10,
                                            autofocus: true,
                                            controller: _textController,
                                            decoration: InputDecoration(
                                                labelText: 'Unterkategorie',
                                                labelStyle: TextStyle(
                                                    color: Color(0xFFaeaeae),
                                                    fontSize: 15.3)),
                                            onSubmitted: (text) {
                                              _triggerAddControl(
                                                  topic, topicIdx);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30),
                                controlsList(topic, topicIdx, removeControl),
                              ],
                            ),
                          ),
                        ],
                      ))),
            );
          });
        });
  }

  Widget buildGrid(BuildContext context, int index) {
    final Topic topic = cls.topics[index];
    return Container(
        child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      key: ValueKey(index),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.24,
          height: 80,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 30,
                            child: AutoSizeText(
                              '${topic.name}',
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(int.parse('${topic.color}')),
                              ),
                            ),
                          )),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: AutoSizeText(
                              '${topic.controls.length} Unterkategorie',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF333951),
                              ),
                            ),
                          )),
                    ]),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  child: Center(
                    child: FlatButton(
                      child: Text(
                        'Bearbeiten',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xFFff8300),
                        ),
                      ),
                      onPressed: () {
                        showControlDialog(context, topic, index);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (cls == null) {
      return SizedBox();
    }
    return GridView.builder(
        itemCount: cls.topics.length,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 3,
          childAspectRatio: 2.9,
          mainAxisSpacing: 3,
        ),
        itemBuilder: (BuildContext context, int index) {
          return buildGrid(context, index);
        });
  }
}

class Actions extends StatelessWidget {
  final Class cls;
  final Function moveToPage;
  Actions(this.cls, this.moveToPage);

  nextPage(BuildContext context) {
    if (cls == null) {
      return moveToPage(5);
      ;
    }
    final Topic topic =
        cls.topics.firstWhere((e) => e.controls.length < 1, orElse: () => null);
    if (topic == null) {
      return moveToPage(5);
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hinweis'),
            content: const Text(
                'Bitte fügen Sie mindestens eine Unterkategorie pro Fach/Bereich hinzu'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _skip(BuildContext context) async {
    if (cls == null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
      return;
    }
    final Topic topic =
        cls.topics.firstWhere((e) => e.controls.length < 1, orElse: () => null);
    if (topic == null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('activeMenu', '/dashboard');
      Navigator.pushReplacementNamed(context, '/dashboard');
      return;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hinweis'),
            content: const Text(
                'Bitte fügen Sie mindestens eine Unterkategorie pro Fach/Bereich hinzu'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      FlatButton(
          highlightColor: Colors.white,
          onPressed: () {
            moveToPage(3);
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
            nextPage(context);
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
