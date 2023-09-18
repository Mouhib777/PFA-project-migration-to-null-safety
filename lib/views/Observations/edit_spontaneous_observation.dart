import 'dart:async';
import 'package:docu_diary/blocs/observationsHistory/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter/foundation.dart';
import 'package:docu_diary/models/Observations.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:docu_diary/widgets/loading_indicator.dart';

import 'package:docu_diary/models/myTopics.model.dart';
import 'package:docu_diary/models/ControlsModel.dart';
import 'package:docu_diary/db/dao/token.dart';
import 'package:docu_diary/models/token.dart';
import 'package:docu_diary/config/url.dart';
import 'package:docu_diary/views/dashboard/save_inherited_widget.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class EditSpontaneousObservation extends StatelessWidget {
  final String studentId;
  final String obId;
  final String title;
  final String classId;
  final String studentName;
  final String studentSurName;
  final String topicId;
  final String controlId;
  final Function fun;
  final int rating;
  final String picture;
  final String date;

  EditSpontaneousObservation(
      {@required this.studentId,
      this.classId,
      this.studentName,
      this.studentSurName,
      this.topicId,
      this.controlId,
      this.title,
      this.fun,
      this.rating,
      this.obId,
      this.picture,
      this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: EditSpontaneousObservationContent(
          studentId,
          classId,
          studentName,
          studentSurName,
          topicId,
          controlId,
          title,
          fun,
          rating,
          obId,
          picture,
          date),
    );
  }
}

class EditSpontaneousObservationContent extends StatefulWidget {
  final String studentId;
  final String obId;
  final String title;
  final String classId;
  final String studentName;
  final String studentSurName;
  final String topicId;
  final String controlId;
  final Function fun;
  final int rating;
  final String picture;
  final String date;
  EditSpontaneousObservationContent(
      this.studentId,
      this.classId,
      this.studentName,
      this.studentSurName,
      this.topicId,
      this.controlId,
      this.title,
      this.fun,
      this.rating,
      this.obId,
      this.picture,
      this.date);
  @override
  _EditSpontaneousObservationContentState createState() =>
      _EditSpontaneousObservationContentState(
          studentId,
          classId,
          studentName,
          studentSurName,
          topicId,
          controlId,
          title,
          fun,
          rating,
          obId,
          picture,
          date);
}

class _EditSpontaneousObservationContentState
    extends State<EditSpontaneousObservationContent> {
  final String studentId;
  final String obId;
  final String title;
  final String classId;
  final String studentName;
  final String studentSurName;
  final String topicId;
  final String controlId;
  final Function fun;
  final int rating;
  final String picture;
  final String date;
  _EditSpontaneousObservationContentState(
      this.studentId,
      this.classId,
      this.studentName,
      this.studentSurName,
      this.topicId,
      this.controlId,
      this.title,
      this.fun,
      this.rating,
      this.obId,
      this.picture,
      this.date);

  static final _baseUrl = BaseUrl.urlAPi;
  final _smileys = <String>['pain', 'sad', 'happy', 'amazing'];

  int _selectedIndex = -1;
  String _name;
  String _controlename;
  String _texttosend;
  String dropdownValue = 'topic 1';
  String dropdownValu = 'Control 1';
  String _topicId;
  String _controleId;
  DateTime _date;
  bool deselectedSmiley = true;
  var isLoading = false;
  List<String> ctrs = [];
  List<MyTopic> selectData = [];
  List<String> data = [];
  List<MyTopic> listControls = [];
  List<ControlModel> controls = [];
  ObservationsModel observations = ObservationsModel();
  TokenDao _tokenDao = TokenDao();
  String userToken = '';
  bool secondSelected = false;
  ObservationsBloc _observationBloc;

  final _formKey = GlobalKey<FormState>();

  _getTopicsByClass(String classId) async {
    Token token = await _tokenDao.getToken();

    setState(() {
      isLoading = true;
      userToken = token.accessToken;
    });
    var w = widget.classId;
    try {
      final response = await http.get(
        '$_baseUrl/class/getClassTopics?classId=$w',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "bearer " + userToken
        },
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body).toList();
        setState(() {
          responseJson.forEach((v) => {
                if (v['selected'])
                  {
                    selectData.add(MyTopic.fromJson(v)),
                    data.add(MyTopic.fromJson(v).name),
                    data.add(MyTopic.fromJson(v).sId),
                  }
              });
          _selectedIndex = widget.rating - 1;
        });

        if (widget.topicId != null) {
          var p = selectData.firstWhere((e) => e.sId == widget.topicId);

          setState(() {
            _name = selectData[selectData.indexOf(p)].sId;
            _topicId = selectData[selectData.indexOf(p)].sId;
          });
          _getControlsByTopicsId(selectData[selectData.indexOf(p)].sId);
        }
      } else {}
    } catch (e) {}
  }

  _getControlsByTopicsId(String id) async {
    Token token = await _tokenDao.getToken();

    setState(() {
      isLoading = true;
      userToken = token.accessToken;
    });
    try {
      final response = await http.get(
        '$_baseUrl/teacher/getControlsByTopicsId/?classId=${widget.classId}&topicId=$id',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "bearer " + userToken,
        },
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body).toList();

        setState(() {
          controls.clear();
          listControls.clear();
          ctrs.clear();
          responseJson.forEach((v) => {
                controls.add(ControlModel.fromJson(v)),
                listControls.add(MyTopic.fromJson(v)),
                ctrs.add(MyTopic.fromJson(v).controlname),
              });

          if (widget.controlId != null && widget.topicId == id) {
            _controlename = widget.controlId;
            _controleId = widget.controlId;
          } else {
            _controlename = null;
            _controleId = null;
          }
        });
      } else {}
    } catch (e) {}
  }

  Future _sendObservation(String id) async {
    if (_formKey.currentState.validate() &&
        _topicId != null &&
        _controleId != null) {
      _formKey.currentState.save();
      int rating = _selectedIndex + 1;

      _observationBloc
        ..add(EditObservation(
          id: id,
          title: _texttosend,
          classId: widget.classId,
          topicId: _topicId,
          controlId: _controleId,
          rating: rating,
          studentId: widget.studentId,
          date: _date != null
              ? DateFormat("yyyy-MM-dd")?.format(_date)
              : date.substring(6, 10) +
                  '-' +
                  date.substring(3, 5) +
                  '-' +
                  date.substring(0, 2),
        ));

      await Future.delayed(const Duration(milliseconds: 100));
      Navigator.of(context).pop();
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    _observationBloc = ObservationsBloc();

    _getTopicsByClass(widget.classId);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.

    _observationBloc.close();
    super.dispose();
  }

  Widget _smileyWidget(String type, int index) => InkWell(
        onTap: () {
          setState(() {
            if (deselectedSmiley == true && _selectedIndex == index) {
              _selectedIndex = -1;
            } else {
              _selectedIndex = index;
            }
            deselectedSmiley = !deselectedSmiley;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(4.0),
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Image.asset(
            "assets/images/${type + (_selectedIndex != index ? "_desabled" : "")}.png",
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    var inheritedSaveWidget =
        context.findAncestorWidgetOfExactType<SaveInheritedWidget>();
    var isShowAllSmileys = inheritedSaveWidget?.isSaved ?? true;
    return SingleChildScrollView(
      child: Container(
        child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          // color: Colors.blue,
                          // height: MediaQuery.of(context).size.height * 0.08,
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text('Spontane Beobachtung',
                                    // maxLines: 1,
                                    style: (TextStyle(
                                        color: Color(0xFF333951),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold))),
                              ),
                              Container(
                                width:
                                    MediaQuery.of(context).size.width * 0.025,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                decoration: new BoxDecoration(boxShadow: [
                                  _topicId != null
                                      ? new BoxShadow(
                                          color: Colors.grey.withOpacity(.2),
                                          blurRadius: 10,
                                        )
                                      : new BoxShadow(
                                          color: Colors.red.withOpacity(.5),
                                          blurRadius: 10,
                                        ),
                                ]),
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width *
                                        0.08,
                                    child: InkWell(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          DropdownButton<String>(
                                              value: _name,
                                              hint: Text('Themenname',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(0xFF333951))),
                                              underline: Container(),
                                              icon: Icon(
                                                  Icons.keyboard_arrow_down),
                                              iconSize: 20.0,
                                              iconEnabledColor:
                                                  Color(0xFFff7f00),
                                              items: selectData.map<
                                                      DropdownMenuItem<String>>(
                                                  (MyTopic value) {
                                                return DropdownMenuItem<String>(
                                                  value: value.sId,
                                                  child: Text(
                                                    value.name,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF333951)),
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (String value) {
                                                _getControlsByTopicsId(value);
                                                setState(() {
                                                  _name = value;
                                                  _topicId = value;
                                                  //
                                                });
                                              }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width:
                                    MediaQuery.of(context).size.width * 0.025,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                decoration: new BoxDecoration(boxShadow: [
                                  _controleId != null
                                      ? new BoxShadow(
                                          color: Colors.grey.withOpacity(.2),
                                          blurRadius: 10,
                                        )
                                      : new BoxShadow(
                                          color: Colors.red.withOpacity(.5),
                                          blurRadius: 10,
                                        ),
                                ]),
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Container(
                                    height: 40,
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Center(
                                        child: InkWell(
                                      child: DropdownButton<String>(
                                        value: _controlename,
                                        hint: Text('Unterkategorie',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF333951))),
                                        underline: Container(),
                                        icon: Icon(Icons.keyboard_arrow_down),
                                        iconSize: 20.0,
                                        iconEnabledColor: Color(0xFFff7f00),
                                        items: controls
                                            .map<DropdownMenuItem<String>>(
                                                (ControlModel value) {
                                          return DropdownMenuItem<String>(
                                            value: value.sId,
                                            child: Text(
                                              value.controlName,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF333951)),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String value) {
                                          setState(() {
                                            // Toggle value to display only one smiley

                                            _controlename = value;
                                            _controleId = value;
                                            //
                                          });
                                        },
                                      ),
                                    )),
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.05,
                              ),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    FlatButton(
                                      child: Icon(
                                        Icons.close,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.025,
                                        color: Color(0xFFff8300),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        //color: Colors.red,
                        height: MediaQuery.of(context).size.height * 0.15,
                        //width: MediaQuery.of(context).size.width * 1,
                        color: Color(0xFFf7f7ff),
                        //  color: Colors.red,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(

                                  // controller: new TextEditingController.fromValue(new TextEditingValue(text: widget.title,selection: new TextSelection.collapsed(offset: widget.title.length))),
                                  autofocus: true,
                                  maxLines: 3,
                                  initialValue: '   ${widget.title} ',
                                  decoration: InputDecoration.collapsed(
                                    hintText:
                                        "Geben Sie hier Ihre Beobachtung ein",
                                  ),
                                  validator: (input) => input.length < 3
                                      ? 'Name muss mindestens 3 Zeichen lang sein'
                                      : null,
                                  onSaved: (input) {
                                    _texttosend = input;
                                    setState(() {
                                      _texttosend = input.trim();
                                    });
                                  }),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          // color: Colors.yellow,
                          // height: MediaQuery.of(context).size.height * 0.1,
                          child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: new BoxDecoration(boxShadow: [
                                    new BoxShadow(
                                      color: Colors.grey.withOpacity(.04),
                                      blurRadius: 3,
                                    ),
                                  ]),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(1.0),
                                      ),
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.08,
                                                //width: MediaQuery.of(context).size,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                      left: BorderSide(
                                                    color: Color(0xFF333951),
                                                    width: 4.0,
                                                  )),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Container(
                                                        child: Text(
                                                            '  ${widget.studentName} ${widget.studentSurName} '),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.12,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.062,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.060,
                                                margin:
                                                    EdgeInsets.only(left: 15),
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: widget.picture !=
                                                                null &&
                                                            widget.picture != ""
                                                        ? Image.network(
                                                            '$_baseUrl' +
                                                                'public/${widget.picture}',
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.asset(
                                                            'assets/images/_e-reading.png',
                                                            width: 50,
                                                            height: 50,
                                                          )),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              // color: Colors.blue,
                              width: MediaQuery.of(context).size.width * 0.05),
                          InkWell(
                            child: Container(
                                child: Icon(
                              Icons.calendar_today,
                            )),
                            onTap: () async {
                              final date = await showDatePicker(
                                  context: context,
                                  locale: const Locale("de", "DE"),
                                  firstDate: DateTime(1960),
                                  initialDate:
                                      (widget?.date != '') && _date == null
                                          ? DateFormat("dd.MM.yyyy")
                                              .parse(widget.date)
                                          : _date,
                                  lastDate: DateTime(2100));
                              setState(() => _date = date);

                              return date;
                            },
                          ),
                          Container(
                              // color: Colors.blue,
                              width: MediaQuery.of(context).size.width * 0.05),
                          InkWell(
                            child: Container(
                              child: Text(
                                _date == null
                                    ? widget.date
                                    : _date.day.toString() +
                                        '.' +
                                        _date.month.toString() +
                                        '.' +
                                        _date.year.toString(),
                                style: TextStyle(
                                    height: 1,
                                    color: Color(0xFF333951),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cera-Medium'),
                              ),
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                  context: context,
                                  locale: const Locale("de", "DE"),
                                  firstDate: DateTime(1960),
                                  initialDate:
                                      (widget?.date != '') && _date == null
                                          ? DateFormat("dd.MM.yyyy")
                                              .parse(widget.date)
                                          : _date,
                                  lastDate: DateTime(2100));
                              setState(() => _date = date);
                              return date;
                            },
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ...isShowAllSmileys
                                          ? _smileys
                                              .map<Widget>((d) => _smileyWidget(
                                                  d, _smileys.indexOf(d)))
                                              .toList()
                                          : _smileys
                                              .map<Widget>((d) => _smileyWidget(
                                                  d, _smileys.indexOf(d)))
                                              .toList(),
                                    ],
                                  )
                                ],
                              ))),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.12,
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                      child: Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text(
                                          "Speichern",
                                          style: TextStyle(
                                              color: Color(0xFFff8300),
                                              fontSize: 20.0),
                                        ),
                                      ),
                                      onTap: () async {
                                        _controleId == null
                                            ? setState(() {
                                                // firstSelected = true;
                                                secondSelected = true;
                                              })
                                            : null;
                                        _sendObservation(widget.obId);
                                      }),
                                ],
                              ))),
                        ],
                      )),
                    ],
                  ),
                ))),
      ),
    );
  }
}
