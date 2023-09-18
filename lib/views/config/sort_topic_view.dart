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

class SortTopicWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Function moveToPage;
  SortTopicWidget(this.moveToPage);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ConfigBloc(),
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
              child: SortTopicWidgetContent(moveToPage, _scaffoldKey))),
    );
  }
}

class SortTopicWidgetContent extends StatefulWidget {
  final Function moveToPage;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  SortTopicWidgetContent(this.moveToPage, this._scaffoldKey);

  @override
  _SortTopicWidgetContentState createState() =>
      _SortTopicWidgetContentState(moveToPage, _scaffoldKey);
}

class _SortTopicWidgetContentState extends State<SortTopicWidgetContent> {
  final Function moveToPage;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  _SortTopicWidgetContentState(this.moveToPage, this._scaffoldKey);

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
                      'Bereiche/Fächer',
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
                      'In diesem Schritt können Sie die Reihenfolge Ihrer Bereiche/Fächer festlegen, wie sie Ihnen später in der Schülerübersicht angezeigt werden soll.',
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
                Container(height: 100, child: Actions(moveToPage)),
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

  @override
  didUpdateWidget(TopicList oldWidget) {
    setState(() {
      cls = widget.cls;
    });
  }

  Widget buildGrid(int index) {
    final Topic topic = cls.topics[index];

    Card card = Card(
      key: ValueKey(index),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 1,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.30,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Center(
                  child: Text(
                '${index + 1}. ',
                style: TextStyle(
                    fontSize: 24.0,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold),
              )),
            ),
            Expanded(
                flex: 6,
                child: Container(
                  // width: 220,
                  child: Center(
                    child: AutoSizeText(
                      '${topic.name}',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.0,
                        color: Color(int.parse('${topic.color}')),
                      ),
                    ),
                  ),
                )),
            Expanded(
              flex: 2,
              child: Icon(
                Icons.dehaze,
                color: Colors.blueGrey,
                size: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
    Draggable dragGridCard = Draggable(
      data: topic,
      maxSimultaneousDrags: 1,
      child: card,
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: card,
      ),
      feedback: Material(
        color: Colors.black.withOpacity(0.2),
        child: card,
      ),
    );

    return DragTarget(
      onWillAccept: (fromChange) {
        return cls.topics.indexOf(fromChange) != index;
      },
      onAccept: (fromChange) {
        final int changeFromIndex = cls.topics.indexOf(fromChange);
        final Topic changeToValue = cls.topics[index];

        setState(() {
          cls.topics[index] = fromChange;
          cls.topics[changeFromIndex] = changeToValue;
        });

        context.bloc<ConfigBloc>()..add(SortTopics(cls.topics));
      },
      builder:
          (BuildContext context, selectedData, List<dynamic> rejectedData) {
        return Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.29,
              height: 80,
              // color: Colors.orange,
              child: selectedData.isEmpty ? dragGridCard : card,
            )
          ],
        );
      },
    );
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
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          childAspectRatio: 4.9,
          mainAxisSpacing: 3,
        ),
        itemBuilder: (BuildContext context, int index) {
          return buildGrid(index);
        });
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
            moveToPage(2);
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
            moveToPage(4);
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
