import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:docu_diary/blocs/dashboard/bloc.dart';
import 'package:docu_diary/connectionStatusSingleton.dart';
import 'package:docu_diary/models/models.dart';
import 'package:docu_diary/utils/snackbar.dart';
import 'package:docu_diary/views/dashboard/smiley_widget.dart';
import 'package:docu_diary/views/dashboard/topic_dialog.dart';
import 'package:docu_diary/widgets/dashboard_no_students.dart';
import 'package:docu_diary/widgets/loading_indicator.dart';
import 'package:docu_diary/widgets/wrapped_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:docu_diary/views/Drawer/drawer.dart';
import 'package:docu_diary/widgets/dashboard_no_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:docu_diary/views/dashboard/spontaneous_observation.dart';
import 'package:docu_diary/config/url.dart';

String getObservationCountText(int count) {
  if (count == 1) return count.toString() + ' Notiz';
  return count.toString() + ' Notizen';
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool hasConnection = true;

  void updateHasConnection(bool isConnected) {
    setState(() {
      hasConnection = isConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: BlocProvider(
            create: (BuildContext context) => DashboardBloc(),
            child: Row(children: <Widget>[
              AppDrawer(
                  currentPage: 'home',
                  hasConnection: hasConnection,
                  scaffoldKey: _scaffoldKey),
              Expanded(
                  child: SafeArea(
                child: Row(children: [
                  DashboardContent(
                      scaffoldKey: _scaffoldKey,
                      updateHasConnection: updateHasConnection)
                ]),
              ))
            ])));
  }
}

class DashboardContent extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function updateHasConnection;
  DashboardContent(
      {@required this.scaffoldKey, @required this.updateHasConnection});
  @override
  _DashboardContentState createState() => _DashboardContentState(
      scaffoldKey: scaffoldKey, updateHasConnection: updateHasConnection);
}

class _DashboardContentState extends State<DashboardContent> {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function updateHasConnection;
  _DashboardContentState(
      {@required this.scaffoldKey, @required this.updateHasConnection});

  StreamSubscription _connectionChangeStream;

  @override
  void initState() {
    super.initState();
    context.bloc<DashboardBloc>()..add(LoadYears());

    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    new Future.delayed(Duration.zero, () {
      updateHasConnection(connectionStatus.hasConnection);
      _connectionChangeStream =
          connectionStatus.connectionChange.listen(connectionChanged);
    });
  }

  void connectionChanged(dynamic hasConnection) {
    context.bloc<DashboardBloc>()..add(UpdateConnectionStatus(hasConnection));
    updateHasConnection(hasConnection);
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

  void synchronize() => context.bloc<DashboardBloc>()..add(Synchronize());

  void _showSnackbarConnectionStatus(bool connected) {
    _hideSnackbar();
    SnackBarUtils.showSnackbarConnectionStatus(
        scaffoldKey, connected, _hideSnackbar);
  }

  void _showSnackbarSynchronizeStart() {
    _hideSnackbar();
    SnackBarUtils.showSnackbarSynchronizeStart(scaffoldKey);
  }

  void _showSnackbarSynchronizeRetry() {
    _hideSnackbar();
    SnackBarUtils.showSnackbarSynchronizeRetry(scaffoldKey, synchronize);
  }

  void _hideSnackbar() {
    SnackBarUtils.hideSnackbar(scaffoldKey);
  }

  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
        listenWhen: (previous, current) {
      return current is DashboardFailure ||
          current is ConnectionStatus ||
          current is SynchronizeStart ||
          current is SynchronizeError ||
          current is SynchronizeEnd;
    }, listener: (context, state) {
      if (state is DashboardFailure) {
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
      return current is DashboardLoadInProgress ||
          current is DashboardHasNoConfig ||
          current is DashboardLoadClassSuccess;
    }, builder: (context, state) {
      if (state is DashboardLoadInProgress) {
        return Expanded(
          child: Container(child: LoadingIndicator()),
        );
      } else if (state is DashboardHasNoConfig) {
        return Container(
            alignment: Alignment.topLeft,
            child: Row(children: [
              Container(
                alignment: Alignment.topLeft,
                width: MediaQuery.of(context).size.width * 0.60,
                padding: EdgeInsets.fromLTRB(25, 25, 35, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SchoolYear(),
                    Expanded(child: DashboardNoConfig())
                  ],
                ),
              ),
            ]));
      } else if (state is DashboardLoadClassSuccess) {
        final List<Class> classes = state.classes;
        final Class selectedClass = classes.length > 0 ? classes.first : null;
        return Row(children: [
          Container(
            alignment: Alignment.topLeft,
            width: MediaQuery.of(context).size.width * 0.60,
            padding: EdgeInsets.fromLTRB(25, 25, 35, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        SchoolYear(),
                        DropDownClasses(),
                      ],
                    ),
                    Search(selectedClass: selectedClass),
                  ],
                ),
                SizedBox(height: 25),
                ObservationWidget()
              ],
            ),
          ),
          Filters(selectedClass: selectedClass)
        ]);
      } else {
        return Container();
      }
    });
  }
}

class SchoolYear extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
        buildWhen: (previousState, state) {
      return state is DashboardLoadClassSuccess ||
          state is DashboardHasNoConfig;
    }, builder: (context, state) {
      if (state is DashboardLoadClassSuccess || state is DashboardHasNoConfig) {
        List<PaidYears> years = [];
        if (state is DashboardLoadClassSuccess) {
          years = state.years;
        } else if (state is DashboardHasNoConfig) {
          years = state.years;
        }

        if (years.length < 1) {
          return Container();
        }
        final PaidYears selectedC = years.first;
        return Container(
            child: Row(children: <Widget>[
          Text(
            'Schuljahr ',
            style: TextStyle(color: Color(0xFF87333951), fontSize: 19.3),
          ),
          DropdownButton<PaidYears>(
            value: selectedC,
            underline: Container(),
            icon: Icon(Icons.keyboard_arrow_down),
            iconSize: 40.0,
            iconEnabledColor: Color(0xFFff7f00),
            onChanged: (PaidYears newValue) {
              context.bloc<DashboardBloc>()..add(UpdateYear(newValue));
            },
            items: years.map<DropdownMenuItem<PaidYears>>((PaidYears value) {
              return DropdownMenuItem<PaidYears>(
                value: value,
                child: Text(value.sId,
                    style: TextStyle(fontSize: 19, color: Color(0xFF87333951))),
              );
            }).toList(),
          ),
        ]));
      } else {
        return Container();
      }
    });
  }
}

class DropDownClasses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
        buildWhen: (previousState, state) {
      return state is DashboardLoadClassSuccess;
    }, builder: (context, state) {
      if (state is DashboardLoadClassSuccess) {
        final List<Class> classes = state.classes;
        if (classes.length < 1) {
          return Container();
        }
        final Class selectedClass = classes.first;
        return Container(
          child: DropdownButton<Class>(
            value: selectedClass,
            underline: Container(),
            icon: Icon(Icons.keyboard_arrow_down),
            iconSize: 50.0,
            iconEnabledColor: Color(0xFFff7f00),
            onChanged: (Class newValue) {
              if (newValue.id != selectedClass.id) {
                context.bloc<DashboardBloc>()
                  ..add(
                      UpdateClass(oldClass: selectedClass, newClass: newValue));
                // context.bloc<DashboardBloc>()..add(LoadStudentsClass(newValue));
              }
            },
            items: classes.map<DropdownMenuItem<Class>>((Class value) {
              return DropdownMenuItem<Class>(
                value: value,
                child: Text(value.className,
                    style: TextStyle(fontSize: 34.7, color: Color(0xFF333951))),
              );
            }).toList(),
          ),
        );
      } else {
        return Container();
      }
    });
  }
}

class Search extends StatefulWidget {
  final Class selectedClass;
  Search({Key key, @required this.selectedClass}) : super(key: key);

  @override
  _SearchState createState() => _SearchState(selectedClass);
}

class _SearchState extends State<Search> {
  Class selectedClass;
  final textController = TextEditingController();
  _SearchState(this.selectedClass);

  void initState() {
    super.initState();
    textController.addListener(_filterStudents);
  }

  _filterStudents() {
    context.bloc<DashboardBloc>()
      ..add(FilterStudents(cls: selectedClass, text: textController.text));
  }

  @override
  didUpdateWidget(Search oldWidget) {
    setState(() {
      selectedClass = widget.selectedClass;
      if (oldWidget.selectedClass?.id != widget.selectedClass?.id) {
        textController.text = '';
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.24,
        height: MediaQuery.of(context).size.height * 0.05,
        child: TextField(
          controller: textController,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: Color(0xFFf7f7ff),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(40),
                ),
                borderSide: BorderSide.none,
              ),
              hintText: 'Suche ...',
              labelStyle: TextStyle(
                color: Color(0xFFa5a5a5),
                fontSize: 18,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xFFff7800),
              )),
        ),
      ),
    );
  }
}

class Filters extends StatefulWidget {
  final Class selectedClass;
  Filters({Key key, @required this.selectedClass}) : super(key: key);

  @override
  _FiltersState createState() => _FiltersState(selectedClass);
}

class _FiltersState extends State<Filters> {
  Class selectedClass;

  _FiltersState(this.selectedClass);

  @override
  didUpdateWidget(Filters oldWidget) {
    setState(() {
      selectedClass = widget.selectedClass;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedClass == null) {
      return Container();
    }
    Topic selectedTopic;
    if (selectedClass.selectedTopicId != null) {
      selectedTopic = selectedClass.topics.firstWhere((t) =>
          t.id == selectedClass.selectedTopicId ||
          t.name == selectedClass.selectedTopicId);
    }

    return Container(
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width * 0.30,
        alignment: Alignment.topLeft,
        color: Color(0xFFf7f7ff),
        child: Column(children: [
          SizedBox(height: 20),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                            text: 'Bereich/Fach: ',
                            style: TextStyle(
                                color: Color(0xFF333951), fontSize: 18.7),
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    '${selectedTopic != null ? selectedTopic.name : ''}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              )
                            ]),
                      ),
                    ],
                  ),
                )),
            Expanded(
              flex: 1,
              child: Center(
                child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.settings,
                      color: Color(0xFFff8400),
                    ),
                  ),
                  onTap: () async {
                    final List data = await showDialog(
                        context: context,
                        builder: (BuildContext context) => TopicDialog());
                    if (data == null) return;
                    if (data[0] != null) {
                      context.bloc<DashboardBloc>()
                        ..add(UpdateTopicsClass(data[0]));
                    }
                    if (data[1] == '/') {
                      context.bloc<DashboardBloc>()..add(LoadLocalClasses());
                    } else {
                      Navigator.pushNamed(context, '/sort_topics');
                    }
                  },
                ),
              ),
            ),
          ]),
          SizedBox(height: 20),
          Topics(selectedClass: selectedClass),
          SizedBox(height: 20),
          Controls(classId: selectedClass.id, selectedTopic: selectedTopic)
        ]));
  }
}

class Topics extends StatefulWidget {
  final Class selectedClass;
  Topics({Key key, @required this.selectedClass}) : super(key: key);

  @override
  _TopicsState createState() => _TopicsState(selectedClass);
}

class _TopicsState extends State<Topics> {
  Class selectedClass;
  _TopicsState(this.selectedClass);
  List<Topic> topics;
  List<bool> isSelected = [];
  Topic selectedTopic;

  @override
  void initState() {
    super.initState();
    topics = selectedClass.topics.where((e) => e.selected).toList();
    isSelected = List<bool>.generate(topics.length, (i) => false);
  }

  @override
  didUpdateWidget(Topics oldWidget) {
    if (oldWidget.selectedClass.id != widget.selectedClass.id) {
      setState(() {
        selectedClass = widget.selectedClass;
        topics = selectedClass.topics.where((e) => e.selected).toList();
        isSelected = List<bool>.generate(topics.length, (i) => false);
      });
    } else {
      setState(() {
        selectedClass = widget.selectedClass;
        topics = selectedClass.topics.where((e) => e.selected).toList();
        if (isSelected.length != topics.length) {
          isSelected = List<bool>.generate(topics.length, (i) => false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> topicsWidget = topics.map((topic) {
      return Center(
        child: Container(
            height: 85,
            width: 50,
            decoration: BoxDecoration(
              color: Color(int.parse('${topic.color}')),
              borderRadius: BorderRadius.all(Radius.elliptical(50, 50)),
            ),
            child: Center(
                child: Text(
              topic.name.substring(0, 2).toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFFffffff)),
            ))),
      );
    }).toList();
    return Center(
      child: Container(
        child: WrapToggleToggleButtons(
            iconList: topicsWidget,
            isSelected: isSelected,
            onPressed: (int index) {
              if (selectedClass.students.length > 0) {
                setState(() {
                  for (int buttonIndex = 0;
                      buttonIndex < isSelected.length;
                      buttonIndex++) {
                    if (buttonIndex == index) {
                      isSelected[buttonIndex] = !isSelected[buttonIndex];
                      if (isSelected[buttonIndex]) {
                        selectedTopic = topics.elementAt(buttonIndex);
                      } else {
                        selectedTopic = null;
                      }
                    } else {
                      isSelected[buttonIndex] = false;
                    }
                  }
                });

                context.bloc<DashboardBloc>()
                  ..add(LoadControls(
                      classId: selectedClass?.id,
                      topicId: selectedTopic?.id ?? selectedTopic?.name,
                      selected: selectedTopic != null));
              }
            }),
      ),
    );
  }
}

class Controls extends StatefulWidget {
  final Topic selectedTopic;
  final String classId;
  Controls({Key key, @required this.classId, @required this.selectedTopic})
      : super(key: key);

  @override
  _ControlsState createState() => _ControlsState(classId, selectedTopic);
}

class _ControlsState extends State<Controls> {
  String classId;
  Topic selectedTopic;
  _ControlsState(this.classId, this.selectedTopic);
  List<Control> controls;
  List<bool> isSelected = [];

  @override
  void initState() {
    super.initState();

    controls = selectedTopic != null ? selectedTopic.controls : [];
    isSelected = List<bool>.generate(controls.length, (i) => false);
    if (controls.length == 1) {
      isSelected[0] = true;
      context.bloc<DashboardBloc>()
        ..add(
          LoadObservation(
              classId: classId,
              topicId: selectedTopic?.id ?? selectedTopic?.name,
              controlId: controls.first.id ?? controls.first.controlName,
              selected: isSelected[0]),
        );
    }
  }

  @override
  didUpdateWidget(Controls oldWidget) {
    if (oldWidget.classId != widget.classId) {
      setState(() {
        classId = widget.classId;
        selectedTopic = widget.selectedTopic;
        controls = selectedTopic != null ? selectedTopic.controls : [];
        isSelected = List<bool>.generate(controls.length, (i) => false);
        if (controls.length == 1) {
          isSelected[0] = true;
          context.bloc<DashboardBloc>()
            ..add(
              LoadObservation(
                  classId: classId,
                  topicId: selectedTopic?.id ?? selectedTopic?.name,
                  controlId: controls.first.id ?? controls.first.controlName,
                  selected: isSelected[0]),
            );
        }
      });
    } else {
      setState(() {
        classId = widget.classId;
        selectedTopic = widget.selectedTopic;
        controls = selectedTopic != null ? selectedTopic.controls : [];
        if (isSelected.length != controls.length ||
            oldWidget.selectedTopic?.id != widget.selectedTopic?.id) {
          isSelected = List<bool>.generate(controls.length, (i) => false);
          if (controls.length == 1) {
            isSelected[0] = true;
            context.bloc<DashboardBloc>()
              ..add(
                LoadObservation(
                    classId: classId,
                    topicId: selectedTopic?.id ?? selectedTopic?.name,
                    controlId: controls.first.id ?? controls.first.controlName,
                    selected: isSelected[0]),
              );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedTopic == null) {
      return Container();
    }

    return Flexible(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Column(children: <Widget>[
              RichText(
                text: TextSpan(
                    text: 'Unterkategorien: ',
                    style: TextStyle(color: Color(0xFF333951), fontSize: 15),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            '${selectedTopic != null ? selectedTopic.name : ''}',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      )
                    ]),
              ),
            ]),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Container(
                      alignment: Alignment.center,
                      child: ToggleButtons(
                        borderColor: Colors.transparent,
                        fillColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        selectedBorderColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        children: controls.map((control) {
                          var index = controls.indexOf(control);
                          return RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                                height: 60,
                                width: 300,
                                margin: EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                  border: isSelected[index]
                                      ? Border.all(
                                          color: Color(int.parse(
                                              '${selectedTopic.color}')),
                                          width: 4.0)
                                      : null,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Container(),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Text(
                                            control.controlName,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 4,
                                            child: control.hasActiveObservation
                                                ? Image.asset(
                                                    'assets/images/papel_copy.png',
                                                    color: Colors.black,
                                                    width: 40,
                                                    height: 40,
                                                  )
                                                : Text(''))
                                      ],
                                    ),
                                  ),
                                )),
                          );
                        }).toList(),
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                                buttonIndex < isSelected.length;
                                buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelected[buttonIndex] =
                                    !isSelected[buttonIndex];
                                context.bloc<DashboardBloc>()
                                  ..add(
                                    LoadObservation(
                                        classId: classId,
                                        topicId: selectedTopic?.id ??
                                            selectedTopic?.name,
                                        controlId: controls
                                                .elementAt(buttonIndex)
                                                .id ??
                                            controls
                                                .elementAt(buttonIndex)
                                                .controlName,
                                        selected: isSelected[buttonIndex]),
                                  );
                              } else {
                                isSelected[buttonIndex] = false;
                              }
                            }
                          });
                        },
                        isSelected: isSelected,
                      )),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ObservationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
        buildWhen: (previous, current) {
      return current is DashboardLoadClassSuccess;
    }, builder: (context, state) {
      if (state is DashboardLoadClassSuccess) {
        List<Class> classes = state.classes;
        if (classes.length < 1) {
          return Container();
        }
        final Class selectedClass = classes.first;
        final List<Student> students = selectedClass.students;

        if (students.length == 0) {
          return Expanded(
            child: Container(child: DashboardNoStudents()),
          );
        }
        return Expanded(
          child: Container(
              child: Column(
            children: [
              ObservationActions(selectedClass),
              SizedBox(height: 20),
              Students(),
            ],
          )),
        );
      } else {
        return Container();
      }
    });
  }
}

class ObservationActions extends StatefulWidget {
  final Class selectedClass;
  ObservationActions(this.selectedClass);

  @override
  _ObservationActionsState createState() =>
      _ObservationActionsState(selectedClass);
}

class _ObservationActionsState extends State<ObservationActions> {
  Class selectedClass;
  _ObservationActionsState(this.selectedClass);

  @override
  didUpdateWidget(ObservationActions oldWidget) {
    setState(() {
      selectedClass = widget.selectedClass;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedClass.hasActiveObservation) {
      final Observation observation = selectedClass.observation;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              child: Row(
            children: [
              SizedBox(width: 20),
              Container(
                // color: Colors.red,
                width: MediaQuery.of(context).size.width * 0.25,
                child: Text(observation.title,
                    style: TextStyle(color: Color(0xFFff6c00), fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: true),
              ),
              SizedBox(width: 20),
              InkWell(
                onTap: () async {
                  final String name = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DialogObservation(observation.title);
                      });
                  if (name != null && name.isNotEmpty) {
                    observation.title = name;
                    context.bloc<DashboardBloc>()
                      ..add(EditObservationName(
                        cls: selectedClass,
                        observation: observation,
                      ));
                  }
                },
                child: Image.asset('assets/images/tools_and_utensils_2.png',
                    width: 30),
              )
            ],
          )),
          Row(children: [
            Container(
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onPressed: () {
                  context.bloc<DashboardBloc>()
                    ..add(CompleteObservation(
                      cls: selectedClass,
                    ));
                },
                color: Color(0xFFff6c00),
                textColor: Colors.white,
                child: Row(
                  children: [
                    Text("Abschließen",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFffffff),
                        )),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.01,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.05,
              child: InkWell(
                child: RaisedButton(
                  onPressed: () {
                    context.bloc<DashboardBloc>()
                      ..add(DeleteObservation(
                        cls: selectedClass,
                      ));
                  },
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(Icons.close, color: Color(0xFF333951)),
                ),
              ),
            ),
          ])
        ],
      );
    } else {
      final btnIsActive = selectedClass.selectedTopicId != null &&
          selectedClass.selectedControlId != null;
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: Container(
              // color : Colors.yellow,
              height: 50.0,
              child: RaisedButton(
                onPressed: () async {
                  if (btnIsActive) {
                    final String name = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DialogObservation('');
                        });
                    if (name != null && name.isNotEmpty) {
                      context.bloc<DashboardBloc>()
                        ..add(CreateStructureObservation(
                          classId: selectedClass.id,
                          topicId: selectedClass.selectedTopicId,
                          controlId: selectedClass.selectedControlId,
                          name: name,
                        ));
                    }
                  }
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                padding: EdgeInsets.all(0.0),
                textColor: Colors.white,
                child: Ink(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: btnIsActive
                            ? [
                                Color(0xFFff8400),
                                Color(0xFFff6c00),
                              ]
                            : [
                                Color(0xFFe6e6e6),
                                Color(0xFFe6e6e6),
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Container(
                      constraints:
                          BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/papel_copy.png'),
                          SizedBox(width: 10),
                          Text("Strukturierte Beobachtungen",
                              style: TextStyle(fontSize: 18)),
                        ],
                      )),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}

class DialogObservation extends StatefulWidget {
  final String name;
  DialogObservation(this.name);

  @override
  _DialogObservationState createState() => _DialogObservationState(name);
}

class _DialogObservationState extends State<DialogObservation> {
  final String name;
  _DialogObservationState(this.name);
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = name;
    textController.selection = TextSelection.fromPosition(
        TextPosition(offset: textController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Bitte geben Sie einen Namen für Ihre Beobachtung ein"),
      content: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1.0),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
            border: Border(
                left: BorderSide(
              color: Colors.black,
              width: 5.0,
            )),
          ),
          child: Center(
            child: TextField(
              onEditingComplete: () {
                {
                  Navigator.pop(context, textController.text);
                }
              },
              controller: textController,
              autofocus: true,
              enableSuggestions: false,
              decoration: (InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                hintText: 'Name der Beobachtung',
                labelStyle: TextStyle(color: Color(0xFFaeaeae), fontSize: 15.3),
              )),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            "Speichern",
            style: TextStyle(fontSize: 15, color: Colors.orange),
          ),
          onPressed: () {
            Navigator.pop(context, textController.text);
          },
        ),
      ],
    );
  }
}

class StarIcon extends StatefulWidget {
  final Class cls;
  final String observationId;
  final String studentId;
  final bool isFavorite;

  StarIcon(
      {Key key,
      @required this.cls,
      @required this.observationId,
      @required this.studentId,
      @required this.isFavorite})
      : super(key: key);
  @override
  _StarIconState createState() =>
      _StarIconState(cls, observationId, studentId, isFavorite);
}

class _StarIconState extends State<StarIcon> {
  Class cls;
  String observationId;
  String studentId;
  bool isFavorite;
  List<bool> isSelected = [];
  _StarIconState(this.cls, this.observationId, this.studentId, this.isFavorite);

  @override
  void initState() {
    super.initState();
    isSelected = [isFavorite];
  }

  @override
  didUpdateWidget(StarIcon oldWidget) {
    setState(() {
      cls = widget.cls;
      observationId = widget.observationId;
      studentId = widget.studentId;
      isFavorite = widget.isFavorite;
      isSelected = [isFavorite];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      borderColor: Colors.transparent,
      fillColor: Colors.transparent,
      focusColor: Colors.transparent,
      selectedBorderColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      children: <Widget>[
        Icon(Icons.star,
            size: 40, color: isSelected[0] ? Color(0xFFff6c00) : Colors.grey)
      ],
      onPressed: (int index) {
        setState(() {
          isSelected[index] = !isSelected[index];
          isFavorite = isSelected[index];
          context.bloc<DashboardBloc>()
            ..add(UpdateFavorite(
                classId: cls.id,
                observationId: observationId,
                studentId: studentId,
                isFavorite: isFavorite));
        });
      },
      isSelected: isSelected,
    );
  }
}

class Students extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  static final _baseUrl = BaseUrl.urlAPi;

  PersistentBottomSheetController _showSpontaneousObservation(
      BuildContext context, Class cls, dynamic student, bool isGlobal) {
    return showBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return SpontaneousObservation(
            selectedClass: cls, student: student, isGlobal: isGlobal);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
        buildWhen: (previous, current) {
      return current is DashboardLoadClassSuccess;
    }, builder: (context, state) {
      if (state is DashboardLoadClassSuccess) {
        List<Class> classes = state.classes;
        final Class selectedClass = classes.first;
        if (selectedClass.hasActiveObservation) {
          final List<ObservationRating> ratings =
              selectedClass.observation.ratings;

          return Theme(
            data: ThemeData(highlightColor: Colors.grey[900]),
            child: Expanded(
              child: Container(
                  child: Stack(children: <Widget>[
                Scrollbar(
                  isAlwaysShown: true,
                  controller: _scrollController,
                  child: ListView.separated(
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemCount: ratings.length,
                    itemBuilder: (context, index) {
                      ObservationRating student = ratings.elementAt(index);
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 0.0,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Center(
                            child: Row(children: [
                              Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Container(
                                        child: StarIcon(
                                            cls: selectedClass,
                                            observationId:
                                                selectedClass.observation.id,
                                            studentId: student.studentId,
                                            isFavorite: student.isFavorite)),
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      final PersistentBottomSheetController
                                          bottomSheetController =
                                          _showSpontaneousObservation(context,
                                              selectedClass, student, false);
                                      await bottomSheetController.closed;
                                      context.bloc<DashboardBloc>()
                                        ..add(LoadStudentsClass(selectedClass));
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(left: 15),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: student.picture != null &&
                                                  student.picture != ""
                                              ? CachedNetworkImage(
                                                  placeholder: (context, url) =>
                                                      Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                  imageUrl: '$_baseUrl' +
                                                      'public/${student.picture}',
                                                  width: 50,
                                                  height: 50,
                                                )
                                              : Image.asset(
                                                  'assets/images/_e-reading.png',
                                                  width: 50,
                                                  height: 50,
                                                )),
                                    ),
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: InkWell(
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        final PersistentBottomSheetController
                                            bottomSheetController =
                                            _showSpontaneousObservation(context,
                                                selectedClass, student, false);
                                        await bottomSheetController.closed;
                                        context.bloc<DashboardBloc>()
                                          ..add(
                                              LoadStudentsClass(selectedClass));
                                      },
                                      child: Container(
                                        child: Text('${student.name}',
                                            style: TextStyle(fontSize: 15)),
                                      ))),
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: SmileyWidget(
                                        classId: selectedClass.id,
                                        studentId: student.studentId,
                                        observationId:
                                            selectedClass.observation.id,
                                        rating: student.rating,
                                        isShowAllSmileys: true),
                                  )),
                              Container(
                                  child: InkWell(
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  final PersistentBottomSheetController
                                      bottomSheetController =
                                      _showSpontaneousObservation(context,
                                          selectedClass, student, false);
                                  await bottomSheetController.closed;
                                  context.bloc<DashboardBloc>()
                                    ..add(LoadStudentsClass(selectedClass));
                                },
                                child: ClipRRect(
                                  child: Image.asset(
                                    'assets/images/1.png',
                                    width: 36,
                                    height: 36,
                                  ),
                                ),
                              ))
                            ]),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Padding(
                          padding: EdgeInsets.symmetric(vertical: 3));
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                      child: MaterialButton(
                    onPressed: () async {
                      final PersistentBottomSheetController
                          bottomSheetController = _showSpontaneousObservation(
                              context, selectedClass, null, true);
                      await bottomSheetController.closed;
                      context.bloc<DashboardBloc>()
                        ..add(LoadStudentsClass(selectedClass));
                    },
                    color: Color(0xFF333951),
                    textColor: Colors.white,
                    child: Image.asset(
                      'assets/images/_e.png',
                      width: 30,
                    ),
                    padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
                  )),
                )
              ])),
            ),
          );
        }
        final List<Student> students = selectedClass.students;

        return Expanded(
          child: Container(
              child: Stack(children: <Widget>[
            Container(
                child: Scrollbar(
              isAlwaysShown: true,
              controller: _scrollController,
              child: ListView.separated(
                shrinkWrap: true,
                controller: _scrollController,
                itemCount: students.length,
                itemBuilder: (context, index) {
                  Student student = students.elementAt(index);

                  return InkWell(
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        final PersistentBottomSheetController
                            bottomSheetController = _showSpontaneousObservation(
                                context, selectedClass, student, false);
                        await bottomSheetController.closed;
                        context.bloc<DashboardBloc>()
                          ..add(LoadStudentsClass(selectedClass));
                      },
                      child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(.04),
                            blurRadius: 3,
                          ),
                        ]),
                        child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 0,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                child: Row(children: [
                                  Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.060,
                                          margin: EdgeInsets.only(left: 15),
                                          child: student.picture != null &&
                                                  student.picture != ""
                                              ? CachedNetworkImage(
                                                  placeholder: (context, url) =>
                                                      Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                  imageUrl: '$_baseUrl' +
                                                      'public/${student.picture}',
                                                  width: 50,
                                                  height: 50,
                                                )
                                              : Image.asset(
                                                  'assets/images/_e-reading.png',
                                                  width: 50,
                                                  height: 50,
                                                ),
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/addPupil',
                                            arguments: <String, String>{
                                              'id': student.id,
                                              'firstName': student.firstName,
                                              'lastName': student.lastName,
                                              'birthdayDate':
                                                  student.birthdayDate,
                                              'className': student.className,
                                              'CurrentPage': 'home',
                                            },
                                          );
                                        },
                                      )),
                                  SizedBox(width: 20),
                                  Expanded(
                                      flex: 2,
                                      child: Container(
                                        child: Text('${student.name}',
                                            style: TextStyle(fontSize: 15)),
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Text(
                                            getObservationCountText(
                                                student.observation),
                                            style: TextStyle(
                                                color: Color(0xFFd0d1d4),
                                                fontSize: 15)),
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: SmileyWidget(
                                            classId: selectedClass.id,
                                            studentId: student.id,
                                            observationId: '',
                                            rating: student.rating,
                                            isShowAllSmileys: false),
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                          child: InkWell(
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          final PersistentBottomSheetController
                                              bottomSheetController =
                                              _showSpontaneousObservation(
                                                  context,
                                                  selectedClass,
                                                  student,
                                                  false);
                                          await bottomSheetController.closed;

                                          context.bloc<DashboardBloc>()
                                            ..add(LoadStudentsClass(
                                                selectedClass));
                                        },
                                        child: ClipRRect(
                                          child: Image.asset(
                                            'assets/images/1.png',
                                            width: 36,
                                            height: 36,
                                          ),
                                        ),
                                      )))
                                ]),
                              ),
                            )),
                      ));
                },
                separatorBuilder: (context, index) {
                  return Padding(padding: EdgeInsets.symmetric(vertical: 5));
                },
              ),
            )),
            Positioned(
              bottom: 0,
              right: -10,
              child: Container(
                  child: MaterialButton(
                onPressed: () async {
                  final PersistentBottomSheetController bottomSheetController =
                      _showSpontaneousObservation(
                          context, selectedClass, null, true);
                  await bottomSheetController.closed;
                  context.bloc<DashboardBloc>()
                    ..add(LoadStudentsClass(selectedClass));
                },
                color: Color(0xFF333951),
                textColor: Colors.white,
                child: Image.asset(
                  'assets/images/_e.png',
                  width: 30,
                ),
                padding: EdgeInsets.all(16),
                shape: CircleBorder(),
              )),
            )
          ])),
        );
      } else {
        return Container();
      }
    });
  }
}
