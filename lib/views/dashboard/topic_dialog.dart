import 'package:docu_diary/blocs/dashboard/bloc.dart';
import 'package:docu_diary/models/models.dart';
import 'package:docu_diary/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Color hexToColor(String code) {
  return Color(int.parse(code));
}

Color getTopicColor(Topic topic) {
  return topic.selected ? hexToColor(topic.color) : Colors.grey.withAlpha(80);
}

class TopicDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => DashboardBloc(),
        child: DialogContent());
  }
}

class DialogContent extends StatefulWidget {
  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {
  Class cls;

  updateClass(Class newClass) {
    setState(() {
      cls = newClass;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
        buildWhen: (previous, current) {
      return current is DashboardLoadInProgress ||
          current is DashboardLoadClassSuccess;
    }, builder: (context, state) {
      if (state is DashboardLoadInProgress) {
        context.bloc<DashboardBloc>()..add(LoadLocalClasses());
        return Dialog(
            elevation: 0.0,
            backgroundColor: Colors.white,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.8,
                child: LoadingIndicator()));
      } else {
        return Dialog(
            elevation: 0.0,
            backgroundColor: Colors.white,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Stack(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(10),
                      child: Column(children: [
                        SizedBox(
                          height: 50.0,
                        ),
                        Center(
                          child: Text(
                            "Bereiche/Fächer pro Klasse verwalten",
                            style: TextStyle(
                                fontSize: 30.0, color: Color(0xFF333951)),
                            textAlign: TextAlign.center,
                          ), //
                        ),
                        SizedBox(height: 40.0),
                        Center(
                            child: Text(
                          "Wählen Sie die verfügbaren Bereiche/Fächer für die ausgewählte Klasse",
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Color(0xFF333951),
                          ),
                          textAlign: TextAlign.center,
                        ) //
                            ),
                        SizedBox(height: 40.0),
                        DropDownClasses(),
                        SizedBox(height: 40.0),
                        Topics(updateClass),
                      ])),
                  Positioned(
                      child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 100,
                      child: Row(children: <Widget>[
                        Container(
                            child: InkWell(
                                child: FlatButton(
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .pop([cls, '/sort_topics']);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                          child: Container(
                                            width: 20,
                                          ),
                                        ),
                                        Container(
                                          child: InkWell(
                                            child: Text(
                                              "Bereiche/Fächer sortieren",
                                              style: TextStyle(
                                                  color: Color(0xFF333951),
                                                  fontSize: 20.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )))),
                        Expanded(
                          child: SizedBox(),
                        ),
                        Container(
                          child: FlatButton(
                            onPressed: () async {
                              Navigator.of(context).pop([cls, '/']);
                            },
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Fertig",
                                  style: TextStyle(
                                      color: Color(0xFFff8300), fontSize: 20.0),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  height: 20,
                                  child: Image.asset(
                                    'assets/images/login2.png',
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          child: Container(
                              width: MediaQuery.of(context).size.width / 25),
                        ),
                      ]),
                    ),
                  )),
                  Positioned(
                    top: 25.0,
                    right: 30.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Icon(Icons.close,
                            color: Color(0xFFff8400), size: 40.0),
                      ),
                    ),
                  ),
                ],
              ),
            ));
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
        final Class selectedClass = classes.elementAt(0);
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            padding: const EdgeInsets.only(
                left: 20.0, top: 5, right: 10.0, bottom: 5.0),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(0.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ]),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Class>(
                value: selectedClass,
                hint: Text('Wählen Sie eine Klasse aus'),
                isExpanded: true,
                iconEnabledColor: Color(0xFFff8400),
                iconSize: 40,
                onChanged: (Class newValue) {
                  if (newValue.id != selectedClass.id) {
                    context.bloc<DashboardBloc>()
                      ..add(UpdateClass(
                          oldClass: selectedClass, newClass: newValue));
                  }
                },
                items: classes.map<DropdownMenuItem<Class>>((Class value) {
                  return DropdownMenuItem<Class>(
                    value: value,
                    child: Text(value.className),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      } else {
        return Container();
      }
    });
  }
}

class Topics extends StatelessWidget {
  final Function updateClass;
  Topics(this.updateClass);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
        buildWhen: (previousState, state) {
      return state is DashboardLoadClassSuccess;
    }, builder: (context, state) {
      if (state is DashboardLoadClassSuccess) {
        final List<Class> classes = state.classes;
        final Class selectedClass = classes.elementAt(0);
        return TopicsItems(
            selectedClass: selectedClass, updateClass: updateClass);
      } else {
        return Container();
      }
    });
  }
}

class TopicsItems extends StatefulWidget {
  final Class selectedClass;
  final Function updateClass;
  TopicsItems(
      {Key key, @required this.selectedClass, @required this.updateClass})
      : super(key: key);

  @override
  _TopicsItemsState createState() =>
      _TopicsItemsState(selectedClass, updateClass);
}

class _TopicsItemsState extends State<TopicsItems> {
  Class selectedClass;
  Function updateClass;
  _TopicsItemsState(this.selectedClass, this.updateClass);

  @override
  didUpdateWidget(TopicsItems oldWidget) {
    if (oldWidget.selectedClass.id != widget.selectedClass.id) {
      setState(() {
        selectedClass = widget.selectedClass;
        updateClass = widget.updateClass;
      });
    }
  }

  void updateTopic(Topic topic) {
    Topic tpc = selectedClass.topics
        .firstWhere((element) => element.name == topic.name);
    tpc.selected = !tpc.selected;
    updateClass(selectedClass);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: SingleChildScrollView(
          child: Wrap(alignment: WrapAlignment.center, spacing: 20, children: [
            for (var topic in selectedClass.topics)
              Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: InkWell(
                    onTap: () {
                      updateTopic(topic);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                      elevation: 1.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              child: Container(
                                height: 40,
                                child: Center(
                                    child: Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Icon(Icons.check,
                                      color: getTopicColor(topic)),
                                )),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 5,
                              child: Center(
                                  child: Text(
                                topic.name,
                                style: TextStyle(
                                    fontSize: 15, color: getTopicColor(topic)),
                              ))),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: InkWell(
                                child: Padding(
                                    padding: EdgeInsets.only(right: 15.0),
                                    child: Icon(Icons.adjust,
                                        color: getTopicColor(topic))),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
          ]),
        ),
      ),
    );
  }
}
