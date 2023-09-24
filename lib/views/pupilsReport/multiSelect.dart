import 'package:docu_diary/config/url.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:docu_diary/models/class.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:docu_diary/db/dao/token.dart';
import 'package:docu_diary/models/models.dart';
import 'package:docu_diary/db/dao/classSelected.dart';
import 'package:docu_diary/db/dao/dao.dart';

class MultiSelect extends StatefulWidget {
  final Class? selectedClass;
  final Function? updateTopics;

  MultiSelect(
      {Key? key, @required this.selectedClass, @required this.updateTopics})
      : super(key: key);

  @override
  _MultiSelectState createState() =>
      _MultiSelectState(selectedClass!, updateTopics!);
}

class _MultiSelectState extends State<MultiSelect> {
  Class selectedClass;
  Function updateTopics;
  _MultiSelectState(this.selectedClass, this.updateTopics);
  final List<Topic> selectedValues = <Topic>[];
  final _scrollController = ScrollController();
  TokenDao _tokenDao = TokenDao();
  String userToken = '';
  SelectedClassDao _selectedclassDao = SelectedClassDao();
  var isLoading = false;
  String _selectedClassId = '';
  List<Class> selectData = [];
  static final _baseUrl = BaseUrl.urlAPi;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  _fetchData() async {
    Class? cls = await _selectedclassDao.getClass();
    Token? token = await _tokenDao.getToken();
    setState(() {
      isLoading = true;
      userToken = token!.accessToken!;
      _selectedClassId = cls!.id!;
    });
    try {
      final response = await http.get(
        Uri.parse(
        '$_baseUrl/class'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "bearer " + userToken,
        },
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body).toList();
        responseJson.forEach((v) => {
              selectData.add(Class.fromJson(v)),
            });
        selectedClass = _selectedClassId != null
            ? selectData
                .where((element) => element.id == _selectedClassId)
                .first
            : selectData.first;

        setState(() {
          selectData = selectData;
          selectedClass.topics
              .removeWhere((element) => element.selected == false);
          for (var i = 0; i < selectedClass.topics.length; i++) {
            selectedClass.topics[i].selected = false;
          }
        });
      } else {}
    } catch (e) {}
  }

  Color hexToColor(String code) {
    return Color(int.parse(code));
  }

  Color getTopicColor(Topic topic) {
    return topic.selected! ? hexToColor(topic.color!) : Colors.grey[400]!;
  }

  void updateTopic(Topic topic) {
    Topic tpc =
        selectedClass.topics.firstWhere((element) => element.id == topic.id);
    tpc.selected = !tpc.selected!;

    if (tpc.selected!) {
      selectedValues.add(topic);
    } else {
      selectedValues.remove(topic);
    }
    updateTopics(selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      SizedBox(width: 20),
      Center(
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: MediaQuery.of(context).size.width * 0.25,
            child: Scrollbar(
                controller: _scrollController, // <---- Here, the controller

                // isAlwaysShown: true,
                child: SingleChildScrollView(
                  controller:
                      _scrollController, // <---- Same as the Scrollbar controller

                  child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      children: [
                        for (var topic in selectedClass.topics)
                          Container(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: InkWell(
                                onTap: () {
                                  updateTopic(topic);
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(50.0)),
                                  elevation: 1.0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: InkWell(
                                          child: Container(
                                            height: 40,
                                            child: Center(
                                                child: Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10.0),
                                              child: Icon(Icons.check,
                                                  color: getTopicColor(topic)),
                                            )),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          flex: 6,
                                          child: Center(
                                              child: Text(
                                            topic.name!,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: getTopicColor(topic)),
                                          ))),
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: InkWell(
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: 15.0),
                                                child: Icon(Icons.adjust,
                                                    color:
                                                        getTopicColor(topic))),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                      ]),
                )),
          ),
        ),
      ),
    ]);
  }
}
