import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:docu_diary/config/url.dart';
import 'package:docu_diary/blocs/observation/bloc.dart';
import 'package:docu_diary/models/models.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

final _smileys = <String>['pain', 'sad', 'happy', 'amazing'];
final _baseUrl = BaseUrl.urlAPi;

class SpontaneousObservation extends StatefulWidget {
  final Class selectedClass;
  final dynamic student;
  final bool isGlobal;
  SpontaneousObservation(
      {Key key,
      @required this.selectedClass,
      @required this.student,
      this.isGlobal = false})
      : super(key: key);
  @override
  _SpontaneousObservationState createState() =>
      _SpontaneousObservationState(selectedClass, student, isGlobal);
}

class _SpontaneousObservationState extends State<SpontaneousObservation> {
  Class selectedClass;
  dynamic student;
  bool isGlobal;

  _SpontaneousObservationState(this.selectedClass, this.student, this.isGlobal);
  Topic topic;
  Control control;
  int rating = 0;
  final _formKey = GlobalKey<FormState>();
  TextEditingController textController;
  TextEditingController autoCompleteController;

  GlobalKey<AutoCompleteTextFieldState<Student>> autocompleteKey =
      new GlobalKey();

  ObservationBloc _observationBloc;
  final focusText = FocusNode();
  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    if (student != null) {
      textController.text = '  ${student.name} ';
    }
    autoCompleteController = TextEditingController();
    _observationBloc = ObservationBloc();
    if (selectedClass.selectedTopicId != null) {
      topic = selectedClass.topics.firstWhere((e) =>
          e.id == selectedClass.selectedTopicId ||
          e.name == selectedClass.selectedTopicId);
      if (selectedClass.selectedControlId != null) {
        control = topic.controls.firstWhere((e) =>
            e.id == selectedClass.selectedControlId ||
            e.controlName == selectedClass.selectedControlId);
      } else if (topic.controls.length == 1) {
        control = topic.controls[0];
      }
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    textController.dispose();
    autoCompleteController.dispose();
    _observationBloc.close();
    super.dispose();
  }

  Widget _smileyWidget(String type, int index) => InkWell(
        highlightColor: Colors.transparent,
        onTap: () {
          setState(() {
            if (rating > -1 && rating == index + 1) {
              rating = 0;
            } else {
              rating = index + 1;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(4.0),
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Image.asset(
            "assets/images/${type + (rating != index + 1 ? "_desabled" : "")}.png",
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
        ),
      );

  Widget row(Student st) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 50,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: st.picture != null && st.picture.isNotEmpty
                    ? Image.network(
                        '$_baseUrl' + 'public/${st.picture}',
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      )
                    : Image.asset(
                        'assets/images/_e-reading.png',
                        width: 50,
                        height: 50,
                      )),
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            '${st.name}',
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Future<bool> _sendObservation() async {
    try {
      if (_formKey.currentState.validate() &&
          topic != null &&
          control != null &&
          student != null) {
        _formKey.currentState.save();
        var hasProperty = false;
        try {
          (student as dynamic).studentId;
          hasProperty = true;
        } on NoSuchMethodError {}

        _observationBloc
          ..add(AddSpontaneousObservation(
              selectedClass.id,
              topic,
              control,
              hasProperty ? student.studentId : student.id,
              textController.text,
              rating));
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.of(context).pop();
        return true;
      }
      return false;
    } catch (err) {
      Navigator.of(context).pop();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Wrap(
            children: [
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text('Spontane Beobachtung',
                        style: (TextStyle(
                            color: Color(0xFF333951),
                            fontSize: 15,
                            fontWeight: FontWeight.bold))),
                  ),
                  Container(
                    width: 250,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: topic != null
                            ? Colors.grey.withOpacity(.2)
                            : Colors.red.withOpacity(.5),
                        blurRadius: 10,
                      ),
                    ]),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Listener(
                          onPointerDown: (_) =>
                              FocusScope.of(context).unfocus(),
                          child: LimitedBox(
                            maxHeight: 300,
                            child: DropdownButton<Topic>(
                                value: topic,
                                hint: Text('Themenname',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF333951))),
                                underline: Container(),
                                icon: Icon(Icons.keyboard_arrow_down),
                                iconSize: 20.0,
                                iconEnabledColor: Color(0xFFff7f00),
                                items: selectedClass.topics
                                    .where((e) => e.selected)
                                    .map<DropdownMenuItem<Topic>>(
                                        (Topic value) {
                                  return DropdownMenuItem<Topic>(
                                    value: value,
                                    child: Text(
                                      value.name,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333951)),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (Topic value) {
                                  setState(() {
                                    topic = value;
                                    control = topic.controls.length == 1
                                        ? topic.controls[0]
                                        : null;
                                  });
                                }),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 250,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: control != null
                            ? Colors.grey.withOpacity(.2)
                            : Colors.red.withOpacity(.5),
                        blurRadius: 10,
                      ),
                    ]),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Listener(
                          onPointerDown: (_) =>
                              FocusScope.of(context).unfocus(),
                          child: LimitedBox(
                            maxHeight: 300,
                            child: DropdownButton<Control>(
                              value: control,
                              hint: Text('Unterkategorie',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333951))),
                              underline: Container(),
                              icon: Icon(Icons.keyboard_arrow_down),
                              iconSize: 20.0,
                              iconEnabledColor: Color(0xFFff7f00),
                              items: topic?.controls
                                  ?.map<DropdownMenuItem<Control>>(
                                      (Control value) {
                                return DropdownMenuItem<Control>(
                                  value: value,
                                  child: Text(
                                    value.controlName,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF333951),
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              })?.toList(),
                              onChanged: (Control value) {
                                setState(() {
                                  control = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: FlatButton(
                      highlightColor: Colors.transparent,
                      child: Icon(
                        Icons.close,
                        size: 30,
                        color: Color(0xFFff8300),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              )),
              SizedBox(
                height: 75,
              ),
              buildAutoCompletedStudents(),
              Container(
                color: Color(0xFFf7f7ff),
                child: TextFormField(
                  focusNode: focusText,
                  autofocus: !isGlobal,
                  controller: textController,
                  maxLines: 5,
                  decoration: InputDecoration.collapsed(
                      hintText: "Geben Sie hier Ihre Beobachtung ein"),
                  validator: (input) => input.length < 3
                      ? 'Name muss mindestens 3 Zeichen lang sein'
                      : null,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 50,
                    width: 250,
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                              color: Color(0xFF333951),
                              width: 4.0,
                            )),
                          ),
                          child: Container(
                            child: Text('  ${student?.name ?? ''}'),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Container(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: student?.picture != null &&
                                      student?.picture != ""
                                  ? CachedNetworkImage(
                                      placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator()),
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
                      ],
                    ),
                  ),
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _smileys
                        .map<Widget>(
                            (d) => _smileyWidget(d, _smileys.indexOf(d)))
                        .toList(),
                  )),
                  Container(
                      child: InkWell(
                          highlightColor: Colors.transparent,
                          child: Text(
                            "Speichern",
                            style: TextStyle(
                                color: Color(0xFFff8300), fontSize: 20.0),
                          ),
                          onTap: () async {
                            await _sendObservation();
                          })),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  final focus = FocusNode();

  Widget buildAutoCompletedStudents() {
    if (!isGlobal) {
      return SizedBox(height: 10);
    }

    return AutoCompleteTextField<Student>(
      key: autocompleteKey,
      controller: autoCompleteController,
      clearOnSubmit: false,
      suggestions: selectedClass.students,
      style: TextStyle(color: Colors.black, fontSize: 16.0),
      decoration: InputDecoration(
        hintText: "Name des Schülers",
        hintStyle: TextStyle(color: Colors.black),
      ),
      itemFilter: (item, query) {
        return item.name.toLowerCase().contains(query.toLowerCase());
      },
      itemSorter: (a, b) {
        return a.name.compareTo(b.name);
      },
      itemSubmitted: (item) {
        textController.text = '  ${item.name} ';
        autoCompleteController.text = '${item.name}';
        setState(() {
          student = item;
        });
        FocusScope.of(context).requestFocus(focusText);
      },
      itemBuilder: (context, item) {
        // ui for the autocomplete row

        return row(item);
      },
    );
  }
}
