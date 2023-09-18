import 'dart:async';
import 'package:docu_diary/blocs/addPupils/bloc.dart';
import 'package:docu_diary/utils/snackbar.dart';
import 'package:docu_diary/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:docu_diary/connectionStatusSingleton.dart';

import 'dart:io';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/foundation.dart';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

import 'dart:math' as Math;

class AddPupilsView extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Map argument;
  AddPupilsView({
    this.argument,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => StudentsBloc(),
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          body: SafeArea(child: AddPupilsViewContent(argument, _scaffoldKey))),
    );
  }
}

class AddPupilsViewContent extends StatefulWidget {
  final Map argument;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  AddPupilsViewContent(this.argument, this._scaffoldKey);
  @override
  _AddPupilsViewContentState createState() =>
      _AddPupilsViewContentState(argument, _scaffoldKey);
}

class _AddPupilsViewContentState extends State<AddPupilsViewContent> {
  final Map argument;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  _AddPupilsViewContentState(this.argument, this._scaffoldKey);
  bool _hasConnection = true;
  StreamSubscription _connectionChangeStream;
  @override
  void initState() {
    super.initState();

    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    new Future.delayed(Duration.zero, () {
      context.bloc<StudentsBloc>()..add(LoadStudents(argument));

      _hasConnection = connectionStatus.hasConnection;
      if (!connectionStatus.hasConnection) {
        _showSnackbarConnectionStatus(false);
      } else {}
      _connectionChangeStream =
          connectionStatus.connectionChange.listen(connectionChanged);
    });

    new Future.delayed(Duration.zero, () {});
  }

  void connectionChanged(dynamic hasConnection) {
    _showSnackbarConnectionStatus(hasConnection);
    setState(() {
      _hasConnection = hasConnection;
    });
  }

  void _showSnackbarConnectionStatus(bool connected) {
    _hideSnackbar();
    SnackBarUtils.showSnackbarAddPupilsConnectionStatus(
        _scaffoldKey, connected, _hideSnackbar);
  }

  void _hideSnackbar() {
    SnackBarUtils.hideSnackbar(_scaffoldKey);
  }

  void _showSnackbarStudentFailure() {
    _hideSnackbar();
    new Future.delayed(Duration.zero, () {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    });
  }

  void _showSnackbarStudentClassFailure(BuildContext context) {
    setState(() {
      _firstName = '';
      _birthdayDate = null;
    });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 1), () {
            new Future.delayed(Duration.zero, () {
              Navigator.of(context).pushReplacementNamed('/addClasses');
            });
            Navigator.of(context).pop();
          });
          return AlertDialog(
            title: Text('Du hast keine Klasse'),
            content: const Text('Du musst zuerst Klasse hinzufügen'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  new Future.delayed(Duration.zero, () {
                    Navigator.of(context).pushReplacementNamed('/addClasses');
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    _connectionChangeStream.cancel();

    super.dispose();
    _hideSnackbar();
  }

  final format = DateFormat("dd.MM.yyyy");

  SharedPreferences prefs;

  String userToken = '';
  bool checked = false;

  final _formKey = GlobalKey<FormState>();
  var isLoading = false;

  String _firstName;
  String _lastName;
  String _emergencyContact = '';
  DateTime _birthdayDate;

  List userData;
  bool edit;
  String userEmail;
  String picture;
  File _galleryFile;

  chooseImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = new Math.Random().nextInt(10000);
    Im.Image image = Im.decodeImage(imageFile.readAsBytesSync());
    var compressedImage = new File('$path/img_$rand.png')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));
    setState(() {
      _galleryFile = compressedImage;
    });
  }

  upload(BuildContext context) async {
    try {
      await chooseImage();
      String studentId = widget.argument['id'];

      String fileName = _galleryFile.path;

      context.bloc<StudentsBloc>()
        ..add(UploadPicture(studentId: studentId, galleryFile: fileName));
    } catch (_) {}
  }

  void _submit(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      context.bloc<StudentsBloc>()
        ..add(AddStudent(
          firstName: _firstName.trim(),
          lastName: _lastName.trim(),
          birthdayDate: _birthdayDate != null
              ? DateFormat("yyyy-MM-dd HH:mm:ss")?.format(_birthdayDate)
              : ' ',
          emergencyNumber:
              _emergencyContact.length > 0 ? _emergencyContact.trim() : ' ',
        ));
    }
  }

  void _submitSucces(BuildContext context) async {
    setState(() {
      _firstName = '';
      _birthdayDate = null;
    });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 1), () {
            _formKey.currentState.reset();
            Navigator.of(context).pop();
          });
          return AlertDialog(
            title: Text('Schüler/in hinzugefügt'),
            content: const Text(
                'Der Schüler/Die Schülerin wurde erfolgreich hinzugefügt.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  _formKey.currentState.reset();
                },
              ),
            ],
          );
        });

    new Future.delayed(Duration.zero, () {
      context.bloc<StudentsBloc>()..add(LoadStudents(argument));
    });
  }

  _navigateToPage() async {
    final prefs = await SharedPreferences.getInstance();
    final String activeMenu = prefs.getString('activeMenu') ?? '';
    if (activeMenu != '') {
      Navigator.pushNamed(context, activeMenu);
    } else {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  _updateState() async {
    context.bloc<StudentsBloc>()..add(LoadStudents(argument));
  }

  _getState(state) async {
    if (state == true) {
      setState(() {
        checked = state;
      });
    }
  }

  Future _editStudent(BuildContext context, String id, String firstName,
      String lastName, String birthdayDate) async {
    context.bloc<StudentsBloc>()
      ..add(EditStudent(
        id: id,
        firstName: firstName,
        lastName: lastName,
        birthdayDate: birthdayDate,
      ));
  }

  Future _deletepictureStudent(BuildContext context, String id) async {
    context.bloc<StudentsBloc>()..add(DeletePicture(id));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return BlocConsumer<StudentsBloc, StudentsState>(
        listenWhen: (previous, current) {
      return current is StudentsFailure ||
          current is StudentsClassFailure ||
          current is StudentsEditSucces ||
          current is StudentsDeleteSucces ||
          current is StudentsAddSucces ||
          current is StudentsDeletePictureSucces ||
          current is StudentsUpdatePictureSucces;
    }, listener: (context, state) {
      if (state is StudentsFailure) {
        _showSnackbarStudentFailure();
      } else if (state is StudentsClassFailure) {
        _showSnackbarStudentClassFailure(context);
      } else if (state is StudentsAddSucces) {
        _submitSucces(context);
      } else if (state is StudentsEditSucces) {
        _navigateToPage();
      } else if (state is StudentsUpdatePictureSucces) {
        _updateState();
      } else if (state is StudentsDeletePictureSucces) {
        _updateState();
      }
    }, buildWhen: (previous, current) {
      return current is StudentsLoadInProgress ||
          current is StudentsLoadClassSuccess;
    }, builder: (context, state) {
      if (state is StudentsLoadInProgress) {
        return Center(
          child: Container(child: LoadingIndicator()),
        );
      } else if (state is StudentsLoadClassSuccess) {
        final String classes = state.selectedYear;
        _getState(state.checked);
        return SingleChildScrollView(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                height: height,
                width: width,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.08,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: Container(
                                height: MediaQuery.of(context).size.height / 6,
                                child: Image.asset('assets/images/Logo.png')),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.54,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: Container(
                              child: RichText(
                                text: TextSpan(
                                    text: 'Schuljahr ',
                                    style: TextStyle(
                                        color: Color(0xFF333951),
                                        fontSize: 15.7),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: classes,
                                        style: TextStyle(
                                            color: Color(0xFFf97209),
                                            fontSize: 18.7),
                                      )
                                    ]),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Geben Sie nun Informationen über Ihre\n Schüler aus Ihrer Klasse an, die Sie\n beobachten möchten.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18, color: Color(0xFF333951)),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.005,
                                ),
                                Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        widget.argument['id'] != null &&
                                                state.urlPicture.length > 3
                                            ? Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.25,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.04,
                                                child: Row(
                                                  children: [
                                                    Spacer(),
                                                    MaterialButton(
                                                      onPressed: () {
                                                        _deletepictureStudent(
                                                            context,
                                                            widget.argument[
                                                                'id']);
                                                      },
                                                      color: Color(0xFFff8300),
                                                      textColor: Colors.white,
                                                      child: Icon(
                                                        Icons.delete,
                                                        size: 20,
                                                      ),
                                                      // padding: EdgeInsets.all(16),
                                                      shape: CircleBorder(),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.01,
                                                    ),
                                                  ],
                                                ))
                                            : Container(
                                                width: 0,
                                              ),
                                        Container(
                                          height: 150,
                                          width: 150,
                                          decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(75.0),
                                            child: widget.argument['id'] !=
                                                        null &&
                                                    state.urlPicture.length > 3
                                                ? Image.network(
                                                    state.urlPicture,
                                                    width: 50,
                                                    height: 50,
                                                  )
                                                : Image.asset(
                                                    'assets/images/profile.png'),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          child: kIsWeb
                                              ? state.urlPicture.length > 3
                                                  ? Row(
                                                      children: [
                                                        Checkbox(
                                                          value: true,
                                                          onChanged:
                                                              (bool value) {
                                                            setState(() {
                                                              checked = value;
                                                            });
                                                          },
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                              'Einwilligungserklärung der Eltern zur Nutzung des Schülerfotos liegt vor',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0)),
                                                        )
                                                      ],
                                                    )
                                                  : Container(
                                                      width: 0,
                                                    )
                                              : widget.argument
                                                      .containsKey('id')
                                                  ? Row(
                                                      children: [
                                                        Checkbox(
                                                          value: checked,
                                                          onChanged:
                                                              (bool value) {
                                                            setState(() {
                                                              checked = value;
                                                            });
                                                          },
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                              'Einwilligungserklärung der Eltern zur Nutzung des Schülerfotos liegt vor'),
                                                        )
                                                      ],
                                                    )
                                                  : Container(width: 0),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01,
                                        ),
                                        !kIsWeb &&
                                                widget.argument
                                                    .containsKey('id')
                                            ? OutlineButton(
                                                onPressed: () async {
                                                  checked && upload(context);
                                                },
                                                child: Text('Foto hochladen'),
                                              )
                                            : Container(
                                                width: 0,
                                              ),
                                      ],
                                    )),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                              ],
                            ),
                          ),
                          Form(
                            key: _formKey,
                            child: Expanded(
                              child: Container(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 80, 0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        decoration:
                                            new BoxDecoration(boxShadow: [
                                          new BoxShadow(
                                            color: Colors.grey.withOpacity(.2),
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
                                            decoration: BoxDecoration(
                                              border: Border(
                                                  left: BorderSide(
                                                color: Colors.black,
                                                width: 5.0,
                                              )),
                                            ),
                                            child: Center(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                ),
                                                child: DropDownFormField(
                                                  validator: (input) => state
                                                              .classeId ==
                                                          null
                                                      ? 'Bitte geben Sie eine Klasse'
                                                      : null,
                                                  titleText: 'Klasse',
                                                  hintText:
                                                      'Bitte wählen Sie eine Klasse',
                                                  value: state.classeId,
                                                  onSaved: (value) {},
                                                  onChanged: (value) async {},
                                                  dataSource: state.selectData,
                                                  textField: 'className',
                                                  valueField: '_id',
                                                ),
                                              ),
                                            ),
                                          ),
                                          /*Name*/
                                        ),
                                      ),
                                      // last name
                                      Container(
                                        decoration:
                                            new BoxDecoration(boxShadow: [
                                          new BoxShadow(
                                            color: Colors.grey.withOpacity(.2),
                                            blurRadius: 14,
                                          ),
                                        ]),
                                        child: Card(
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(1.0),
                                          ),
                                          child:

                                              /*Name*/
                                              Container(
                                            height: 80,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                  left: BorderSide(
                                                //                   <--- left side
                                                color: Colors.black,
                                                width: 5.0,
                                              )),
                                            ),
                                            child: Center(
                                              child: TextFormField(
                                                initialValue: widget.argument !=
                                                        null
                                                    ? widget
                                                        .argument['firstName']
                                                    : '',
                                                decoration: (InputDecoration(
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            15.0,
                                                            10.0,
                                                            20.0,
                                                            10.0),
                                                    labelText: 'Vorname',
                                                    labelStyle: TextStyle(
                                                        color:
                                                            Color(0xFFaeaeae),
                                                        fontSize: 14.7))),
                                                validator: (input) => input
                                                        .isEmpty
                                                    ? 'Bitte geben Sie einen Vornamen an'
                                                    : null,
                                                onSaved: (input) =>
                                                    _firstName = input,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _firstName = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          /*Name*/
                                        ),
                                      ),
                                      // name
                                      Container(
                                        decoration:
                                            new BoxDecoration(boxShadow: [
                                          new BoxShadow(
                                            color: Colors.grey.withOpacity(.2),
                                            blurRadius: 14,
                                          ),
                                        ]),
                                        child: Card(
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(1.0),
                                          ),
                                          child:

                                              /*Name*/
                                              Container(
                                            height: 80,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                  left: BorderSide(
                                                //                   <--- left side
                                                color: Colors.black,
                                                width: 5.0,
                                              )),
                                            ),
                                            child: Center(
                                              child: TextFormField(
                                                initialValue: widget.argument !=
                                                        null
                                                    ? widget
                                                        .argument['lastName']
                                                    : '',
                                                decoration: (InputDecoration(
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            15.0,
                                                            10.0,
                                                            20.0,
                                                            10.0),
                                                    labelText: 'Nachname',
                                                    labelStyle: TextStyle(
                                                        color:
                                                            Color(0xFFaeaeae),
                                                        fontSize: 14.7))),
                                                validator: (input) => input
                                                        .isEmpty
                                                    ? 'Bitte geben Sie einen Nachnamen an'
                                                    : null,
                                                onSaved: (input) =>
                                                    _lastName = input,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _lastName = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          /*Name*/
                                        ),
                                      ),
                                      // date
                                      Container(
                                        decoration:
                                            new BoxDecoration(boxShadow: [
                                          new BoxShadow(
                                            color: Colors.grey.withOpacity(.2),
                                            blurRadius: 14,
                                          ),
                                        ]),
                                        child: Card(
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(1.0),
                                          ),
                                          child:
                                              /*Name*/
                                              Container(
                                            height: 80,
                                            padding: const EdgeInsets.fromLTRB(
                                                16, 0, 0, 0),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                  left: BorderSide(
                                                //                   <--- left side
                                                color: Colors.black,
                                                width: 5.0,
                                              )),
                                            ),
                                            child: Center(
                                              child: DateTimeField(
                                                initialValue: (widget?.argument
                                                                ?.containsKey(
                                                                    "birthdayDate") ??
                                                            false) &&
                                                        widget.argument[
                                                                'birthdayDate'] !=
                                                            ''
                                                    ? DateFormat(
                                                            "yyyy-MM-dd HH:mm:ss")
                                                        .parse(widget.argument[
                                                            'birthdayDate'])
                                                    : null,
                                                decoration: InputDecoration(
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    border: InputBorder.none,
                                                    labelText:
                                                        'Geburtsdatum (optional)'),
                                                format: format,
                                                onShowPicker: (context,
                                                    currentValue) async {
                                                  final date = await showDatePicker(
                                                      context: context,
                                                      locale: const Locale(
                                                          "de", "DE"),
                                                      firstDate: DateTime(1900),
                                                      initialDate: (widget
                                                                      ?.argument
                                                                      ?.containsKey(
                                                                          "birthdayDate") ??
                                                                  false) &&
                                                              widget.argument[
                                                                      'birthdayDate'] !=
                                                                  ''
                                                          ? DateFormat(
                                                                  "yyyy-MM-dd HH:mm:ss")
                                                              .parse(widget
                                                                      .argument[
                                                                  'birthdayDate'])
                                                          : DateTime.now(),
                                                      lastDate: DateTime(2100));
                                                  setState(() =>
                                                      _birthdayDate = date);
                                                  return date;
                                                },
                                              ),
                                            ),
                                          ),
                                          /*Name*/
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(children: <Widget>[
                      SizedBox(
                        child: Container(
                            width: MediaQuery.of(context).size.width / 40),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          height: MediaQuery.of(context).size.height * 0.03,
                          child: InkWell(
                            child: FlatButton(
                                onPressed: () {
                                  imageCache.clear();
                                  _navigateToPage();
                                },
                                child: Row /*or Column*/ (
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        height: 20,
                                        width: 50,
                                        child: Image.asset(
                                            'assets/images/back_button.png')),
                                    SizedBox(
                                      child: Container(
                                        width: 10,
                                      ),
                                    ),
                                    Text(
                                      'Zurück',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xFFff8300)),
                                    ),
                                  ],
                                )),
                          )),
                      Spacer(),
                      widget.argument.containsKey('id')
                          ? Container(
                              child: InkWell(
                                child: FlatButton(
                                  onPressed: () async {
                                    showDialog(
                                        context: context,
                                        builder:
                                            (BuildContext context) => Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  elevation: 0.0,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  child: Stack(
                                                      children: <Widget>[
                                                        Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.35,
                                                            height:
                                                                MediaQuery.of(context)
                                                                        .size
                                                                        .height *
                                                                    0.4,
                                                            padding:
                                                                EdgeInsets.only(
                                                              top: 40.0 + 16.0,
                                                              left: 16.0,
                                                              right: 16.0,
                                                            ),
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 40.0),
                                                            decoration: new BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        16.0),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black26,
                                                                    blurRadius:
                                                                        10.0,
                                                                    offset:
                                                                        const Offset(
                                                                            0.0,
                                                                            10.0),
                                                                  )
                                                                ]),
                                                            child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize.min,
                                                                // To make the card compact
                                                                children: <Widget>[
                                                                  Spacer(),
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topCenter,
                                                                    child:
                                                                        Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.3,
                                                                      child: Text(
                                                                          'Möchten Sie den ausgewählten Schüler/die ausgewählte Schülerin inklusive der zugehörigen Beobachtungen löschen?',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                              // fontSize: 18,
                                                                              color: Color(0xFF333951))),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.02,
                                                                  ),
                                                                  Text(
                                                                      widget.argument[
                                                                              'firstName'] +
                                                                          ' ' +
                                                                          widget.argument[
                                                                              'lastName'],
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16.0,
                                                                      )),
                                                                  Text(
                                                                      state
                                                                          .selectedClassName,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16.0,
                                                                      )),
                                                                  Spacer(),
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.3,
                                                                    child: Row(
                                                                      children: [
                                                                        FlatButton(
                                                                          child:
                                                                              Text(
                                                                            'Stornieren',
                                                                            style:
                                                                                TextStyle(fontSize: 15, color: Color(0xFF333951)),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                        Spacer(),
                                                                        FlatButton(
                                                                          child:
                                                                              Text(
                                                                            'Löschen',
                                                                            style:
                                                                                TextStyle(fontSize: 15, color: Color(0xFFf97209)),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            StudentsBloc()
                                                                              ..add(DeleteStudent(widget.argument['id']));
                                                                            Navigator.pushNamed(context,
                                                                                '/dashboard');
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
                                  },
                                  child: Text(
                                    "Löschen",
                                    style: TextStyle(
                                        fontSize: 20, color: Color(0xFF333951)),
                                  ),
                                ),
                              ),
                            )
                          : Container(width: 0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: InkWell(
                          child: FlatButton(
                              onPressed: () async {
                                (widget.argument == null ||
                                        !widget.argument.containsKey('id'))
                                    ? _submit(context)
                                    : _editStudent(
                                        context,
                                        widget.argument['id'],
                                        _firstName != null
                                            ? _firstName
                                            : widget.argument['firstName'],
                                        _lastName != null
                                            ? _lastName
                                            : widget.argument['lastName'],
                                        _birthdayDate != null
                                            ? DateFormat("yyyy-MM-dd HH:mm:ss")
                                                .format(_birthdayDate)
                                            : widget.argument['birthdayDate'],
                                      );
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    widget.argument.containsKey('id')
                                        ? "Aktualisieren"
                                        : "Hinzufügen",
                                    style: TextStyle(
                                        fontSize: 20, color: Color(0xFFf97209)),
                                  ),
                                  SizedBox(
                                    child: Container(
                                      width: 10,
                                    ),
                                  ),
                                  Container(
                                      height: 20,
                                      width: 25,
                                      child: Image.asset(
                                          'assets/images/login2.png'))
                                ],
                              )),
                        ),
                      ),
                      SizedBox(
                        child: Container(
                            width: MediaQuery.of(context).size.width / 40),
                      ),
                    ]),
                  ],
                )));
      } else {
        return Container();
      }
    });
  }
}
