import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:async';
import 'package:docu_diary/config/url.dart';
import 'package:docu_diary/views/Drawer/drawer.dart';
import 'package:docu_diary/models/Observation_history.model.dart';
import 'package:docu_diary/models/pupilsModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:docu_diary/connectionStatusSingleton.dart';

import 'package:docu_diary/models/class.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'edit_spontaneous_observation.dart';
import 'package:docu_diary/utils/snackbar.dart';

import 'package:docu_diary/blocs/observationsHistory/bloc.dart';
// import 'package:docu_diary/utils/snackbar.dart';
import 'package:docu_diary/widgets/loading_indicator.dart';
import 'package:easy_debounce/easy_debounce.dart';

class Observations extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Observations();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: BlocProvider(
            create: (BuildContext context) => ObservationsBloc(),
            child: Row(children: <Widget>[
              AppDrawer(currentPage: 'observations', scaffoldKey: _scaffoldKey),
              Expanded(
                  child: SafeArea(
                child: Row(children: [
                  ObservationsContent(
                    _scaffoldKey,
                  )
                ]),
              ))
            ])));
  }
}

class ObservationsContent extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  ObservationsContent(this._scaffoldKey);
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

  // _ObservationsContentState createState() =>
      // _ObservationsContentState(_scaffoldKey);
}

class _ObservationsContentState extends State<ObservationsContent> {
  // final GlobalKey<ScaffoldState> _scaffoldKey;

  // _ObservationsContentState(this._scaffoldKey);

  List<Observations>? listofObservations;
  bool _hasConnection = true;
  StreamSubscription? _connectionChangeStream;

  void initState() {
    super.initState();

    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    new Future.delayed(Duration.zero, () {
      // context.bloc<ObservationsBloc>()..add(LoadObservations());
      _hasConnection = connectionStatus.hasConnection;
      if (!connectionStatus.hasConnection) {
        // _showSnackbarConnectionStatus(false);
      }
      _connectionChangeStream =
          connectionStatus.connectionChange.listen(connectionChanged);
    });
  }
//! voir lib/utils/snackbar
  void connectionChanged(dynamic hasConnection) {
    // _showSnackbarConnectionStatus(hasConnection);
    setState(() {
      _hasConnection = hasConnection;
    });
  }

  // void _showSnackbarConnectionStatus(bool connected) {
  //   _hideSnackbar();
  //   SnackBarUtils.showSnackbarNoteHistoryConnectionStatus(
  //       _scaffoldKey, connected, _hideSnackbar);
  // }

  // void _hideSnackbar() {
  //   SnackBarUtils.hideSnackbar(_scaffoldKey);
  // }

  @override
  void dispose() {
    _connectionChangeStream!.cancel();

    super.dispose();
    // _hideSnackbar();
  }

  int selectedIndex = -1;
  bool pressAttention = false;
  bool pressButton = false;
  bool isSelected = true;
  String? salectedStudent;
  bool enabled = false;
  String iconRate = 'assets/images/pain.png';
  String classID = '';
  String? observationName;
  String? observationId;
  String? defaultSelectValue;

  var items = [];

  final ScrollController _scrollController = ScrollController();
  final duplicateItems = List<String>.generate(10, (i) => "Item $i");
  Map<String, bool> changeColor = {
    'ADD': false,
    'HOME': true,
    'FOLDER': true,
    'MESSAGE': true,
    'SETTINGS': true,
  };

  var isLoading = false;
  List<Class> newClassesList = [];
  List<Observation> listObservations = [];
  List<Observation> secondListObservations = [];

  List<String> data = [];
  List<String> observations = [];
  List<PupilsModel> listPeoples = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ObservationsBloc, ObservationsState>(
        listenWhen: (previous, current) {
      return current is ObservationsFailure;
    }, listener: (context, state) {
      if (state is ObservationsFailure) {}
    }, buildWhen: (previous, current) {
      return current is ObservationsLoadInProgress ||
          current is ObservationsLoadSuccess ||
          current is ObservationsDeleteSucces ||
          current is ObservationsFilterLoadSuccess;
    }, builder: (context, state) {
      if (state is ObservationsLoadInProgress) {
        return Center(
          child: Container(child: LoadingIndicator()),
        );
      } else if (state is ObservationsLoadSuccess) {
        final List<Class> classes = state.classes!;
        final Class selectedClass = classes.first;
        final List<Observation> listObservations = state.listObservations!;
        final selectedYear = state.selectedYear;
        return Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SchoolYear(currentYear: selectedYear!),
                          Container(
                            child: DropdownButton<Class>(
                              value: selectedClass,
                              underline: Container(),
                              icon: Icon(Icons.keyboard_arrow_down),
                              iconSize: 50.0,
                              iconEnabledColor: Color(0xFFff7f00),
                              onChanged: (Class? newValue) {
                                // context.bloc<ObservationsBloc>()
                                  // ..add(UpdateClass(newValue));
                              },
                              items: classes
                                  .map<DropdownMenuItem<Class>>((Class value) {
                                return DropdownMenuItem<Class>(
                                  value: value,
                                  child: Text(value.className!,
                                      style: TextStyle(
                                          fontSize: 34.7,
                                          color: Color(0xFF333951))),
                                );
                              }).toList(),
                            ),
                          ),
                        ]),
                    Column(
                      children: [
                        Search(selectedClass: selectedClass),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    children: [
                      Container(
                          height: MediaQuery.of(context).size.height * 0.77,
                          child: Scrollbar(
                            // isAlwaysShown: state.listObservations!.length > 6
                            //     ? true
                            //     : false,
                            controller: _scrollController,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: Container(
                                    child: ObservationList(
                                        listofObservations: listObservations,
                                        classId: state.classes!.first.id!)),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      } else
        return Container();
    });
  }
}

class ObservationList extends StatefulWidget {
  final List<Observation>? listofObservations;
  final String? classId;
  ObservationList(
      {Key? key, @required this.listofObservations, @required this.classId})
      : super(key: key);
  @override
  _ObservationListState createState() =>
      _ObservationListState(listofObservations!, classId!);
}

class _ObservationListState extends State<ObservationList> {
  var currentPage = 0;
  
  _ObservationListState(List<Observation> list, String s);
  void nextPage() {
    setState(() {
      currentPage += 1;
    });
  }

  void prevPage() {
    setState(() {
      currentPage -= 1;
    });
  }

  setPage(int page) {
    currentPage = page;
  }

  getPagination(int size) {
    var number = size / 20;
    var rest = size % 20;
    if (rest > 0) {
      return number.truncate().toInt() + 1;
    }
    return number.truncate().toInt();
  }

  List<Observation>? listofObservations;
  List<Observation>? list;
  late final String? classId;
  // _ObservationListState(this.listofObservations, this.classId);
  static final _baseUrl = BaseUrl.urlAPi;
  String iconRate = 'assets/images/pain.png';

  String _getRating(rate) {
    rate == 1
        ? setState(() {
            iconRate = 'assets/images/pain.png';
          })
        : rate == 2
            ? setState(() {
                iconRate = 'assets/images/sad.png';
              })
            : rate == 3
                ? setState(() {
                    iconRate = 'assets/images/happy.png';
                  })
                : setState(() {
                    iconRate = 'assets/images/amazing.png';
                  });
    return iconRate;
  }

  @override
  didUpdateWidget(ObservationList oldWidget) {
    setState(() {
      listofObservations = widget.listofObservations;
      currentPage = 0;
    });
  }

  _deleteObervation(BuildContext context, String observationId) {
    // context.bloc<ObservationsBloc>()
      // ..add(DeleteSpontaneousObservation(observationId));
    Navigator.of(context, rootNavigator: true).pop();
  }

  _deleteStructuredObervation(
      BuildContext context, String observationId, String studentId) {
    // context.bloc<ObservationsBloc>()
      // ..add(DeleteStructuredObservation(
          // observationId: observationId, studentId: studentId));
    Navigator.of(context, rootNavigator: true).pop();
  }

  showAlertDialog(BuildContext context, Observation ob) {
    // set up the buttons
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
        content: Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(children: <Widget>[
        Container(
            width: width * 0.35,
            height: height * 0.4,
            padding: EdgeInsets.only(
              top: 40.0 + 16.0,
              left: 16.0,
              right: 16.0,
            ),
            margin: EdgeInsets.only(top: 20.0),
            decoration: new BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  )
                ]),
            child: Column(
                mainAxisSize: MainAxisSize.min, // To make the card compact
                children: <Widget>[
                  Spacer(),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: width * 0.3,
                      child: Text(
                          'Möchten Sie die ausgewählte Beobachtung löschen?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              // fontSize: 18,
                              color: Color(0xFF333951))),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Spacer(),
                  Container(
                    width: width * 0.3,
                    child: Row(
                      children: [
                        ElevatedButton(
                          child: Text(
                            'Stornieren',
                            style: TextStyle(
                                fontSize: 15, color: Color(0xFF333951)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Spacer(),
                        ElevatedButton(
                          child: Text(
                            'Löschen',
                            style: TextStyle(
                                fontSize: 15, color: Color(0xFFf97209)),
                          ),
                          onPressed: () {
                            ob.type != 'STRUCTURED'
                                ? _deleteObervation(
                                    context,
                                    ob.sId!,
                                  )
                                : _deleteStructuredObervation(
                                    context, ob.sId!, ob.student!.sId!);
                          },
                        ),
                      ],
                    ),
                  )
                ])),
        Positioned(
          left: 16.0,
          right: 16.0,
          child: Image.asset(
            'assets/images/default_user.png',
            width: 100,
            height: 100,
          ),
        )
      ]),
    ));

    showDialog(
        context: context,
        builder: (_) => Center(
                // Aligns the container to center
                child: Container(
              // A simplified version of dialog.
              height: height * 0.5,
              child: alert,
            )));
  }

  PersistentBottomSheetController _showSpontaneousObservation(
      BuildContext context, Observation obs, String classId) {
    return showBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return EditSpontaneousObservation(
            title: obs.title,
            obId: obs.sId,
            studentId: obs.studentId,
            classId: obs.classId,
            studentName: obs.student!.firstName,
            topicId: obs.topicId,
            controlId: obs.controlId,
            rating: obs.rating,
            studentSurName: obs.student!.lastName,
            picture: obs.student!.picture,
            date: obs.dateofupdate == '' || obs.dateofupdate == null
                ? obs.date
                : obs.dateofupdate);
      },
    );
  }

  Widget classItem(BuildContext context, Observation ob) {
    return Container(
      decoration: new BoxDecoration(
        boxShadow: [
          new BoxShadow(
            color: Color(0xFFfcfcfc),
            //blurRadius: 0.1,
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width * 0.40,
      height: MediaQuery.of(context).size.height * 0.31,
      child: Card(
        elevation: 0.1,
        // borderOnForeground: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      margin: EdgeInsets.only(
                          left: 18.0, top: 15.0, bottom: 0.0, right: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.22,
                            child: Text(
                              ob.dateofupdate! == '' || ob.dateofupdate! == null
                                  ? ob.date!
                                  : ob.dateofupdate!,
                              style: TextStyle(
                                  height: 1,
                                  color: Color(0xFF333951),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cera-Medium'),
                            ),
                          ),

                          // topic + control name
                          Container(
                            width: MediaQuery.of(context).size.width * 0.26,
                            height: MediaQuery.of(context).size.height * 0.060,
                            child: AutoSizeText(
                              ob.topicName! + ' : ' + ob.controlName!,
                              //  maxLines: 2,
                              style: TextStyle(
                                  height: 2,
                                  color: ob.topicColor != ""
                                      ? Color(int.parse('${ob.topicColor}'))
                                      : Color(0xff000000),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      )),
                  Spacer(),
                  ob.type == 'SPONTANEOUS'
                      ? Column(
                          children: [
                            Container(
                                child: IconButton(
                                    hoverColor: Colors.black12,
                                    icon: Image.asset(
                                      'assets/images/tools_and_utensils_2.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    onPressed: () async {
                                      final PersistentBottomSheetController
                                          bottomSheetController =
                                          _showSpontaneousObservation(
                                              context, ob, classId!);
                                      await bottomSheetController.closed;
                                      // context.bloc<ObservationsBloc>()
                                        // ..add(LoadObservations());
                                    })),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.042)
                          ],
                        )
                      : Spacer(),
                  Column(
                    children: [
                      Container(
                          child: IconButton(
                              hoverColor: Colors.black12,
                              icon: Icon(Icons.close, color: Color(0xFFf45d27)),
                              onPressed: () {
                                showAlertDialog(context, ob);
                              })),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.042)
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.01,
                  ),
                ],
              ),
            ),
            Container(
              //  height: 40,
              child: Row(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          left: 18.0, top: 0.0, bottom: 0.0, right: 19.0),
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Container(
                        // color: Colors.red,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Text(
                          ob.title!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                          softWrap: true,
                          style: TextStyle(
                              height: 1.5,
                              color: Color(0xFF333951),
                              fontSize: 12,

                              //fontWeight: FontWeight.bold,
                              fontFamily: 'Cera-Medium'),
                        ),
                      ),
                    )
                  ]),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 13.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          left: 18.0, top: 0.0, bottom: 0.0, right: 18.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.070,
                        width: MediaQuery.of(context).size.width * 0.070,
                        margin: EdgeInsets.only(left: 15),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: ob.student != null &&
                                    ob.student!.picture != null &&
                                    ob.student!.picture != ""
                                ? Image.network(
                                    '$_baseUrl' +
                                        'public/${ob.student!.picture}',
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/_e-reading.png',
                                    width: 50,
                                    height: 50,
                                  )),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ob.student != null
                            ? Text(
                                ob.student!.firstName! +
                                    ' ' +
                                    ob.student!.lastName!,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold),
                              )
                            : Text(''),
                      ],
                    ),
                    Spacer(),
                    ButtonBar(
                      children: <Widget>[
                        Image.asset(
                            ob.rating == 1
                                ? _getRating(ob.rating)
                                : 'assets/images/-e-pain.png',
                            width: 20.0,
                            height: 20.0),
                        SizedBox(
                          width: 0.02,
                        ),
                        Image.asset(
                            ob.rating == 2
                                ? _getRating(ob.rating)
                                : 'assets/images/-e-sad.png',
                            width: 20.0,
                            height: 20.0),
                        SizedBox(
                          width: 0.2,
                        ),
                        Image.asset(
                            ob.rating == 3
                                ? _getRating(ob.rating)
                                : 'assets/images/-e-happy.png',
                            width: 20.0,
                            height: 20.0),
                        SizedBox(
                          width: 0.2,
                        ),
                        Image.asset(
                            ob.rating == 4
                                ? _getRating(ob.rating)
                                : 'assets/images/-e-amazing.png',
                            width: 20.0,
                            height: 20.0),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(600, 0, 0, 0),
            child: Row(
              children: [
                (listofObservations!.length == null || currentPage != 0)
                    ? ElevatedButton(
                        // textColor: Color(0xFF6200EE),
                        onPressed: () {
                          if (currentPage - 1 >= 0) {
                            setState(() {
                              currentPage -= 1;
                            });
                          }
                        },
                        child: Text("<<",
                            style: TextStyle(
                                color: Color(0xFFff7800), fontSize: 20)),
                      )
                    : ElevatedButton(
                      onPressed: () {
                        
                      },
                        child: Text(
                          " ",
                        ),
                      ),
                getPagination(listofObservations!.length) <= 5
                    ? Container(
                        child: Row(
                          children: [
                            for (var i = 0;
                                i < getPagination(listofObservations!.length);
                                i += 1)
                              getPagination(listofObservations!.length) == 1
                                  ? Container()
                                  : InkWell(
                                      child: (currentPage == i)
                                          ? Text(
                                              " " + (i + 1).toString() + " ",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Color(0xFFff7800)),
                                            )
                                          : Text(
                                              " " + (i + 1).toString() + " ",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                      onTap: () {
                                        setState(() {
                                          currentPage = i;
                                        });
                                      },
                                    )
                          ],
                        ),
                      )
                    : Container(
                        child: Row(
                          children: [
                            InkWell(
                              child: Text(
                                "1 ",
                                style: (currentPage == 0)
                                    ? TextStyle(
                                        fontSize: 20, color: Color(0xFFff7800))
                                    : TextStyle(
                                        fontSize: 20,
                                      ),
                              ),
                              onTap: () {
                                setState(() {
                                  currentPage = 1;
                                });
                              },
                            ),
                            (currentPage >= 2)
                                ? InkWell(
                                    child: Text(
                                      " ... ",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {});
                                    },
                                  )
                                : Container(),
                            (currentPage == 0 ||
                                    currentPage ==
                                        getPagination(
                                                listofObservations!.length) -
                                            1)
                                ? Container()
                                : InkWell(
                                    child: Text(
                                      " " + (currentPage + 1).toString() + " ",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xFFff7800)),
                                    ),
                                  ),
                            (currentPage <
                                    getPagination(listofObservations!.length) -
                                        2)
                                ? Text(
                                    " ... ",
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  )
                                : Container(),
                            InkWell(
                              child: Text(
                                " " +
                                    getPagination(listofObservations!.length)
                                        .toString(),
                                style: (currentPage ==
                                        getPagination(
                                                listofObservations!.length) -
                                            1)
                                    ? TextStyle(
                                        fontSize: 20, color: Color(0xFFff7800))
                                    : TextStyle(
                                        fontSize: 20,
                                      ),
                              ),
                              onTap: () {
                                setState(() {
                                  currentPage =
                                      getPagination(listofObservations!.length);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                (currentPage + 1 <=
                        getPagination(listofObservations!.length) - 1)
                    ? ElevatedButton(
                        // textColor: Color(0xFF6200EE),
                        onPressed: () {
                          if (currentPage + 1 <
                              getPagination(listofObservations!.length)) {
                            setState(() {
                              currentPage += 1;
                            });
                          }
                        },
                        child: Text(">>",
                            style: TextStyle(
                                color: Color(0xFFff7800), fontSize: 20)),
                      )
                    : ElevatedButton(
                      onPressed: () {
                        
                      },
                        child: Text(
                          "",
                        ),
                      )
              ],
            ),
          ),
          Center(
            child: Wrap(
              children: listofObservations
                  !.skip(
                      currentPage == 0 ? currentPage * 20 : (currentPage * 20))
                  .take(20)
                  .map((e) => classItem(context, e))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SchoolYear extends StatefulWidget {
  final String? currentYear;
  SchoolYear({Key? key, @required this.currentYear}) : super(key: key);

  @override
  _SchoolYearState createState() => _SchoolYearState(currentYear!);
}

class _SchoolYearState extends State<SchoolYear> {
  String currentYear;
  _SchoolYearState(this.currentYear);
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        highlightColor: Colors.grey[900],
        primaryColor: Color(0xFFFB415B),
        fontFamily: 'Cera-Medium',
      ),
      child: Container(
        padding: EdgeInsets.only(left: 40),
        child: Text(
          'Schuljahr $currentYear',
          style: TextStyle(color: Color(0xFF87333951), fontSize: 19.3),
        ),
      ),
    );
  }
}

class Search extends StatefulWidget {
  final Class? selectedClass;
  Search({Key? key, @required this.selectedClass}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }


  // _SearchState createState() => _SearchState(selectedClass);
}

class _SearchState extends State<Search> {
  Class? selectedClass;
  final textController = TextEditingController();
  // _SearchState(this.selectedClass);
  Timer? _debounce;

  void initState() {
    super.initState();
    textController.addListener(_filterStudents);
  }

  _filterStudents() {
    // EasyDebounce.debounce(
    //     // 'my-debouncer', // <-- An ID for this particular debouncer
    //     // Duration(milliseconds: 800) // <-- The debounce duration
    //     // () => context.bloc<ObservationsBloc>()
    //     //   ..add(FilterObservation(textController.text)) // <-- The target method
    //     );

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // do something with _searchQuery.text
    });
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
          // onEditingComplete: _filterStudentsTwo(),
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
