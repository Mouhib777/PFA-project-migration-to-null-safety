import 'dart:convert';
import 'dart:typed_data';
import 'package:docu_diary/config/url.dart';
import 'package:docu_diary/models/Classes.dart';
import 'package:docu_diary/views/Drawer/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:docu_diary/db/dao/token.dart';
import 'package:docu_diary/models/models.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';
import 'dart:math' as Math;
import 'Dart:async';
import 'Dart:typed_data';
import 'package:package_info/package_info.dart';
import 'dart:io' show Platform, stdout;
import 'package:file_picker/file_picker.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String userEmail;
  String picture;
  static final _baseUrl = BaseUrl.urlAPi;
  File _galleryFile;
  String status = '';
  Uint8List _bytesImage;
  bool enterVerification = false;
  TokenDao _tokenDao = TokenDao();
  String userToken = '';
  PackageInfo _packageInfo = PackageInfo(
    buildNumber: 'Unknown',
  );
  pickImage() async {
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

  PlatformFile objFile = null;

  void chooseFileUsingFilePicker() async {
    //-----pick file by file picker,

    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],

      withReadStream:
          true, // this will return PlatformFile object with read stream
    );
    if (result != null) {
      setState(() {
        objFile = result.files.single;
      });
      uploadSelectedFile();
    }
  }

  void uploadSelectedFile() async {
    //---Create http package multipart request objec

    final request = http.MultipartRequest(
      "POST",
      Uri.parse('$_baseUrl/teacher/addpicture'),
    );
    //-----add other fields if needed
    request.fields["id"] = "abc";
    request.headers["Content-Type"] = "multipart/form-data";
    request.headers["Authorization"] = "Bearer " + userToken;
    //-----add selected file with request
    request.files.add(new http.MultipartFile(
        "file", objFile.readStream, objFile.size,
        filename: objFile.name));

    //-------Send request
    var resp = await request.send();
    getProfilePicture();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => SettingsView(),
        transitionDuration: Duration(seconds: 0),
      ),
    );
  }

  uploadProfilePicture() async {
    await pickImage();
    String fileName = _galleryFile.path;
    Token token = await _tokenDao.getToken();
    setState(() {
      userToken = token.accessToken;
    });
    String mimeType = mime(fileName);
    String mimee = mimeType.split('/')[0];
    String type = mimeType.split('/')[1];
    Dio dio = new Dio();
    dio.options.headers["Content-Type"] = "multipart/form-data";
    dio.options.headers["Authorization"] = "Bearer " + userToken;
    FormData formData = new FormData.fromMap({
      'file': await MultipartFile.fromFile(fileName,
          filename: fileName, contentType: MediaType(mimee, type))
    });
    await dio
        .post(
          '$_baseUrl/teacher/addpicture',
          data: formData,
        )
        .catchError((e) => print(e));
    getProfilePicture();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => SettingsView(),
        transitionDuration: Duration(seconds: 0),
      ),
    );
  }

  getProfilePicture() async {
    Token token = await _tokenDao.getToken();
    setState(() {
      isLoading = true;
      userToken = token.accessToken;
    });

    try {
      final response = await http.get(
        '$_baseUrl/teacher/getpicture',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + userToken,
        },
      );
      if (response.statusCode == 200) {
        _bytesImage = base64.decode(response.body.split(', ').last);
        setState(() {
          _bytesImage = _bytesImage;
        });
      } else {}
    } catch (e) {}
  }

  _fetchData() async {
    Token token = await _tokenDao.getToken();

    setState(() {
      userToken = token.accessToken;
    });
    setState(() {
      isLoading = true;
    });
    // Or, use a predicate getter.

    try {
      final response = await http.get(
        '$_baseUrl/teacher/profile',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "bearer " + userToken,
        },
      );
      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        User user = User.fromJson(responseJson);

        String email = user.email;

        setState(() {
          userEmail = email;
        });
        String name = user.name;
        picture = user.picture;
        if (picture != null) {
          setState(() {
            picture = user.picture;
          });
        }
        setState(() {
          controller = TextEditingController(text: email);
          controllerName = TextEditingController(text: name);
          _email = email;
          _name = name;
        });
      } else {}
    } catch (e) {}
  }

  Future<bool> _deleteUserPicture() async {
    Token token = await _tokenDao.getToken();
    setState(() {
      userToken = token.accessToken;
    });
    final response = await http.delete(
      '$_baseUrl' + 'teacher/deletepicture',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "Bearer " + userToken,
      },
    );
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => SettingsView(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    } else if (response.statusCode < 200 || response.statusCode >= 300) {
      throw new Exception('error delele user picture ! ');
    }

    return true;
  }

  _deleteUser() async {
    if (_deleteAccountFormKey.currentState.validate()) {
      _deleteAccountFormKey.currentState.save();
      Token token = await _tokenDao.getToken();
      setState(() {
        userToken = token.accessToken;
      });
      Map<String, dynamic> data = {
        'password': _confirmDeletePassword.trim(),
      };
      final response = await http.patch(
        '$_baseUrl/auth/delete-account',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': "Bearer " + userToken,
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        await Navigator.pushNamed(context, '/login');
      } else if (response.statusCode < 200 || response.statusCode >= 300) {
        throw new Exception('error when deleting profile');
      }
      return true;
    }
  }

  Future<String> sendVerificationEmail({@required String email}) async {
    final url = '$_baseUrl/auth/send-password-reset';
    Map<String, dynamic> data = {
      'email': email,
    };

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw new Exception('error user login');
    }
    return "Succes";
  }

  void submitEmail() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Token token = await _tokenDao.getToken();
      setState(() {
        userToken = token.accessToken;
      });

      Map<String, dynamic> data = {
        'email': _newEmail.trim(),
      };
      try {
        final response = await http.post(
          '$_baseUrl/auth/update-email-request',
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': "Bearer " + userToken,
          },
          body: jsonEncode(data),
        );
        if (response.statusCode == 200) {
          Navigator.of(context).pop();
          _enterVerificationCode();
        } else {}
      } catch (e) {}
    }
  }

  void submitVerificationCode() async {
    if (_secondFormKey.currentState.validate()) {
      _secondFormKey.currentState.save();
      Token token = await _tokenDao.getToken();
      setState(() {
        userToken = token.accessToken;
      });
      Map<String, dynamic> data = {
        'NewEmail': _newEmail.trim(),
        'code': code.trim()
      };

      try {
        final response = await http.post(
          '$_baseUrl/auth/update-email',
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': "Bearer " + userToken,
          },
          body: jsonEncode(data),
        );
        if (response.statusCode == 200) {
          Navigator.of(context).pushNamed('/login');
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Passwort ändern'),
                  content: Container(
                      width: 600,
                      child: const Text(
                          "Ihr eingegebener Aktivierungscode war nicht korrekt")),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Ok'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
        }
      } catch (e) {}
    }
  }

  String _email,
      _password,
      _name,
      _confirmPassword,
      _confirmDeletePassword,
      _newEmail,
      _verifyNewEmail = '',
      _confirmationEmail,
      code;
  TextEditingController controller;
  TextEditingController controllerName;
  TextEditingController controllerLastName;

  final _formKey = GlobalKey<FormState>();
  final _secondFormKey = GlobalKey<FormState>();
  final _deleteAccountFormKey = GlobalKey<FormState>();

  var _passKey = GlobalKey<FormFieldState>();
  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Widget _infoTile(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: TextStyle(color: Color(0xFF333951), fontSize: 12.0)),
        Text(subtitle ?? 'version not found!',
            style: TextStyle(color: Color(0xFF333951), fontSize: 12.0)),
      ],
    );
  }

  void initState() {
    super.initState();
    _initPackageInfo();

    _fetchData();
    getProfilePicture();
  }

  var isLoading = false;
  List<Classes> selectData = []; //
  List<String> data = [];

  _enterVerificationCode() {
    return showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
                child: Form(
              key: _secondFormKey,
              child: Stack(children: <Widget>[
                Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.height * 0.4,
                    padding: EdgeInsets.only(
                      top: 40.0 + 16.0,
                      left: 16.0,
                      right: 16.0,
                    ),
                    margin: EdgeInsets.only(top: 40.0),
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
                    child: Column(mainAxisSize: MainAxisSize.min,
                        // To make the card compact
                        children: <Widget>[
                          Spacer(),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text(
                                  'Bitte geben Sie hier Ihren Bestätigungscode ein, den Sie per E-Mail erhalten haben:',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF333951))),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 35.0),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(1.0),
                              ),
                              child: Container(
                                height: 100,
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
                                    decoration: (InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          15.0, 10.0, 20.0, 10.0),
                                      hintText: 'Aktivierungscode',
                                    )),
                                    validator: (input) => input.length < 3
                                        ? 'Name muss mindestens 3 Zeichen lang sein'
                                        : null,
                                    onSaved: (input) => code = input,
                                    onChanged: (value) {
                                      setState(() {
                                        code = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: Row(
                              children: [
                                FlatButton(
                                  child: Text(
                                    'Abbrechen',
                                    style: TextStyle(
                                        fontSize: 15, color: Color(0xFF333951)),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                Spacer(),
                                FlatButton(
                                  child: Text(
                                    'Weiter',
                                    style: TextStyle(
                                        fontSize: 15, color: Color(0xFFf97209)),
                                  ),
                                  onPressed: () async {
                                    submitVerificationCode();
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
                    'assets/images/group_20.png',
                    width: 100,
                    height: 100,
                  ),
                )
              ]),
            ))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row(
        children: <Widget>[
//         side bar
          AppDrawer(currentPage: ''),
          //side bar
          Container(
            width: MediaQuery.of(context).size.width * 0.60,
            child: DefaultTabController(
              length: 1,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  bottom: TabBar(
                    indicatorColor: Color(0xFFf45d27),
                    tabs: [
                      Text(
                        'Profil',
                        style:
                            TextStyle(color: Color(0xFFf45d27), fontSize: 23),
                      )
                    ],
                  ),
                  title: Text(''),
                ),
                body: TabBarView(
                  children: [
                    Container(
                      child: Padding(
                          padding: EdgeInsets.only(left: 80.0, top: 50.0),
                          child: Container(
                            child: Row(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width) *
                                        0.6,
                                    // color: Colors.red,
                                    child: Column(
                                      children: <Widget>[
                                        //-----------------------------------------------------------------
                                        Container(
                                          width: (MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                              0.6,
                                          // height: MediaQuery.of(context)
                                          //         .size
                                          //         .height *
                                          //     0.7,
                                          child: Container(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  // first name
                                                  Container(
                                                    width: 300,
                                                    child:

                                                        /*Name*/
                                                        Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                      child: Center(
                                                        child: TextFormField(
                                                          enabled: false,
                                                          controller:
                                                              controllerName,
                                                          decoration: (InputDecoration(
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          15.0,
                                                                          10.0,
                                                                          20.0,
                                                                          10.0),
                                                              labelText: 'Name',
                                                              labelStyle: TextStyle(
                                                                  color: Color(
                                                                      0xFF213344)))),
                                                          validator: (input) =>
                                                              input.length < 3
                                                                  ? 'Der Name muss mindestens 3 Buchstaben enthalten'
                                                                  : null,
                                                          onSaved: (input) =>
                                                              _name = input,
                                                        ),
                                                      ),

                                                      /*Name*/
                                                    ),
                                                  ),

                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.12,
                                                  ),
                                                  // email
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 300,
                                                        child:

                                                            /*Name*/
                                                            Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                          child: Center(
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  controller,
                                                              decoration: (InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  contentPadding:
                                                                      EdgeInsets.fromLTRB(
                                                                          15.0,
                                                                          10.0,
                                                                          20.0,
                                                                          10.0),
                                                                  labelText:
                                                                      'E-Mail',
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Color(0xFF213344)))),
                                                              validator: (input) =>
                                                                  input.length <
                                                                          3
                                                                      ? 'Der Name muss mindestens 3 Buchstaben enthalten'
                                                                      : null,
                                                              onSaved:
                                                                  (input) =>
                                                                      _name =
                                                                          input,
                                                              enabled: false,
                                                            ),
                                                          ),
                                                        ),
                                                        /*Name*/
                                                      ),
                                                      Spacer(),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 80.0),
                                                        child: FlatButton(
                                                          child: Text(
                                                            'E-Mail ändern',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Color(
                                                                    0xFFf45d27)),
                                                          ),
                                                          onPressed: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder: (BuildContext context) =>
                                                                    Dialog(
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                        ),
                                                                        elevation:
                                                                            0.0,
                                                                        backgroundColor:
                                                                            Colors.transparent,
                                                                        child: SingleChildScrollView(
                                                                            child: Form(
                                                                          key:
                                                                              _formKey,
                                                                          child:
                                                                              Stack(children: <Widget>[
                                                                            Container(
                                                                                width: MediaQuery.of(context).size.width * 0.35,
                                                                                height: MediaQuery.of(context).size.height * 0.5,
                                                                                padding: EdgeInsets.only(
                                                                                  top: 40.0 + 16.0,
                                                                                  left: 16.0,
                                                                                  right: 16.0,
                                                                                ),
                                                                                margin: EdgeInsets.only(top: 40.0),
                                                                                decoration: new BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(16.0), boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: Colors.black26,
                                                                                    blurRadius: 10.0,
                                                                                    offset: const Offset(0.0, 10.0),
                                                                                  )
                                                                                ]),
                                                                                child: Column(mainAxisSize: MainAxisSize.min,
                                                                                    // To make the card compact
                                                                                    children: <Widget>[
                                                                                      Spacer(),
                                                                                      Align(
                                                                                        alignment: Alignment.topCenter,
                                                                                        child: Container(
                                                                                          width: MediaQuery.of(context).size.width * 0.3,
                                                                                          child: Text('Bitte geben Sie hier Ihre neue Email-Adresse zweimalig ein und bestätigen Sie mit "Weiter". Sie erhalten dann an Ihre neue E-Mail Adresse einen Bestätigungscode, den Sie im nächsten Schritt eingeben und bestätigen können.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF333951))),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: MediaQuery.of(context).size.height * 0.02,
                                                                                      ),
                                                                                      Center(
                                                                                        child: Theme(
                                                                                          data: Theme.of(context).copyWith(
                                                                                            primaryColor: Color(0xFFf97209),
                                                                                          ),
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.only(left: 40.0),
                                                                                            child: Column(
                                                                                              children: [
                                                                                                TextFormField(
                                                                                                  decoration: (InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0), labelText: 'E-Mail', icon: const Icon(Icons.email), labelStyle: TextStyle(color: Color(0xFFaeaeae), fontSize: 14.7))),
                                                                                                  validator: (input) => !input.contains('@') ? 'Bitte geben Sie eine gültige E-Mail an' : null,
                                                                                                  keyboardType: TextInputType.emailAddress,
                                                                                                  onSaved: (input) => {_newEmail = input},
                                                                                                  onChanged: (value) {
                                                                                                    setState(() {
                                                                                                      _newEmail = value;
                                                                                                    });
                                                                                                  },
                                                                                                ),
                                                                                                TextFormField(
                                                                                                  decoration: (InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0), labelText: 'Neue E-Mail Adresse bestätigen', icon: const Icon(Icons.email), labelStyle: TextStyle(color: Color(0xFFaeaeae), fontSize: 14.7))),
                                                                                                  keyboardType: TextInputType.emailAddress,
                                                                                                  validator: (input) => !input.contains('@') ? 'Bitte geben Sie eine gültige E-Mail an' : null,
                                                                                                  onSaved: (input) {
                                                                                                    _verifyNewEmail = input;
                                                                                                  },
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Spacer(),
                                                                                      Container(
                                                                                        width: MediaQuery.of(context).size.width * 0.3,
                                                                                        child: Row(
                                                                                          children: [
                                                                                            FlatButton(
                                                                                              child: Text(
                                                                                                'Abbrechen',
                                                                                                style: TextStyle(fontSize: 15, color: Color(0xFF333951)),
                                                                                              ),
                                                                                              onPressed: () {
                                                                                                Navigator.of(context).pop();
                                                                                              },
                                                                                            ),
                                                                                            Spacer(),
                                                                                            FlatButton(
                                                                                              child: Text(
                                                                                                'Weiter',
                                                                                                style: TextStyle(fontSize: 15, color: Color(0xFFf97209)),
                                                                                              ),
                                                                                              onPressed: () {
                                                                                                if (_formKey.currentState.validate()) {
                                                                                                  _formKey.currentState.save();

                                                                                                  if (_verifyNewEmail.trim() != _newEmail.trim())
                                                                                                    return;
                                                                                                  else
                                                                                                    submitEmail();
                                                                                                }
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
                                                                                'assets/images/group_20.png',
                                                                                width: 100,
                                                                                height: 100,
                                                                              ),
                                                                            )
                                                                          ]),
                                                                        ))));
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  // password

                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 300,
                                                        child:

                                                            /*Name*/
                                                            Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                          child: Center(
                                                            child:
                                                                TextFormField(
                                                              initialValue:
                                                                  '*********',
                                                              decoration: (InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  contentPadding:
                                                                      EdgeInsets.fromLTRB(
                                                                          15.0,
                                                                          10.0,
                                                                          20.0,
                                                                          10.0),
                                                                  labelText:
                                                                      'Passwort',
                                                                  labelStyle:
                                                                      TextStyle(
                                                                          color:
                                                                              Color(0xFF213344)))),
                                                              validator: (input) =>
                                                                  input.length <
                                                                          3
                                                                      ? 'Der Name muss mindestens 3 Buchstaben enthalten'
                                                                      : null,
                                                              onSaved:
                                                                  (input) =>
                                                                      _name =
                                                                          input,
                                                              enabled: false,
                                                            ),
                                                          ),
                                                        ),
                                                        /*Name*/
                                                      ),
                                                      Spacer(),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 80.0),
                                                        child: FlatButton(
                                                          child: Text(
                                                            'Passwort ändern',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Color(
                                                                    0xFFf45d27)),
                                                          ),
                                                          onPressed: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        'Passwort ändern'),
                                                                    content: Container(
                                                                        width:
                                                                            600,
                                                                        child: const Text(
                                                                            'Sie haben an Ihre E-Mail Adresse einen Bestätigungscode gesendet bekommen. Bitte kopieren Sie diesen und geben ihn gemeinsam mit Ihrem neuen Passwort im folgenden Screen ein')),
                                                                    actions: <
                                                                        Widget>[
                                                                      FlatButton(
                                                                        child: Text(
                                                                            'Ok'),
                                                                        onPressed:
                                                                            () async {
                                                                          await sendVerificationEmail(
                                                                              email: userEmail);
                                                                          Navigator.of(context)
                                                                              .pushNamed('/ResetPasswordView');
                                                                        },
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.08,
                                                  ),

                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 80.0),
                                                    child: Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.16,
                                                        child: Row(
                                                          children: [
                                                            Spacer(),
                                                            InkWell(
                                                              child: FlatButton(
                                                                onPressed:
                                                                    () async {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder: (BuildContext context) => Dialog(
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                          elevation: 0.0,
                                                                          backgroundColor: Colors.transparent,
                                                                          child: SingleChildScrollView(
                                                                              child: Form(
                                                                            key:
                                                                                _deleteAccountFormKey,
                                                                            child:
                                                                                Stack(children: <Widget>[
                                                                              Container(
                                                                                  width: MediaQuery.of(context).size.width * 0.35,
                                                                                  height: MediaQuery.of(context).size.height * 0.4,
                                                                                  padding: EdgeInsets.only(
                                                                                    top: 40.0 + 16.0,
                                                                                    left: 16.0,
                                                                                    right: 16.0,
                                                                                  ),
                                                                                  margin: EdgeInsets.only(top: 40.0),
                                                                                  decoration: new BoxDecoration(color: Colors.white, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(16.0), boxShadow: [
                                                                                    BoxShadow(
                                                                                      color: Colors.black26,
                                                                                      blurRadius: 10.0,
                                                                                      offset: const Offset(0.0, 10.0),
                                                                                    )
                                                                                  ]),
                                                                                  child: Column(mainAxisSize: MainAxisSize.min,
                                                                                      // To make the card compact
                                                                                      children: <Widget>[
                                                                                        Spacer(),
                                                                                        Align(
                                                                                          alignment: Alignment.topCenter,
                                                                                          child: Container(
                                                                                            width: MediaQuery.of(context).size.width * 0.3,
                                                                                            child: Text('Möchten Sie wirklich Ihr Nutzerprofil und alle damit verbundenen Daten löschen? Bestätigen Sie diesen Schritt bitte zu Ihren eigenen Sicherheit mit der Eingabe Ihres persönlichen Passworts.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF333951))),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          height: MediaQuery.of(context).size.height * 0.02,
                                                                                        ),
                                                                                        Center(
                                                                                          child: Theme(
                                                                                            data: Theme.of(context).copyWith(
                                                                                              primaryColor: Color(0xFFf97209),
                                                                                            ),
                                                                                            child: TextFormField(
                                                                                              decoration: (InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0), labelText: 'Passwort', icon: const Padding(padding: const EdgeInsets.only(top: 15.0), child: const Icon(Icons.lock)), labelStyle: TextStyle(color: Color(0xFFaeaeae), fontSize: 14.7))),
                                                                                              validator: (input) => input.length < 7 ? 'Bitte geben Sie einen Vornamen an' : null,
                                                                                              onSaved: (input) => _confirmDeletePassword = input,
                                                                                              obscureText: true,
                                                                                              onChanged: (value) {
                                                                                                setState(() {
                                                                                                  _confirmDeletePassword = value;
                                                                                                });
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Spacer(),
                                                                                        Container(
                                                                                          width: MediaQuery.of(context).size.width * 0.3,
                                                                                          child: Row(
                                                                                            children: [
                                                                                              FlatButton(
                                                                                                child: Text(
                                                                                                  'Abbrechen',
                                                                                                  style: TextStyle(fontSize: 15, color: Color(0xFF333951)),
                                                                                                ),
                                                                                                onPressed: () {
                                                                                                  Navigator.of(context).pop();
                                                                                                },
                                                                                              ),
                                                                                              Spacer(),
                                                                                              FlatButton(
                                                                                                child: Text(
                                                                                                  'Löschen',
                                                                                                  style: TextStyle(fontSize: 15, color: Color(0xFFf97209)),
                                                                                                ),
                                                                                                onPressed: () {
                                                                                                  _deleteUser();
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
                                                                          ))));
                                                                },
                                                                child: Text(
                                                                  "Profil löschen",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Color(
                                                                          0xFFf45d27)),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                //  Debut image side.png

                                //  fin image side.png
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Color(0xFFf7f7ff),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    Column(
                      children: [
                        _bytesImage != null
                            ? Container(
                                width:
                                    MediaQuery.of(context).size.height * 0.25,
                                child: Row(
                                  children: [
                                    Spacer(),
                                    MaterialButton(
                                      onPressed: () {
                                        _deleteUserPicture();
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
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                    ),
                                  ],
                                ))
                            : Container(width: 0),
                        Container(
                          height: 150,
                          width: 150,
                          decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(75.0),
                            child: _bytesImage != null
                                ? Image.memory(_bytesImage)
                                : Image.asset('assets/images/profile.png'),
                          ),
                        ),
                      ],
                    ),
                    !kIsWeb && !(Platform.isMacOS)
                        ? Container(
                            padding: EdgeInsets.all(30.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                OutlineButton(
                                  onPressed: uploadProfilePicture,
                                  child: Text('Foto hochladen'),
                                ),
                              ],
                            ),
                          )
                        : kIsWeb
                            ? Container(
                                padding: EdgeInsets.all(30.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    OutlineButton(
                                      onPressed: chooseFileUsingFilePicker,
                                      child: Text('Foto hochladen'),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                width: 0,
                              ),
                    Spacer(),
                    !kIsWeb
                        ? _infoTile('Versionsnummer : ', _packageInfo.version)
                        : Container(
                            width: 0,
                          ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                  ]),
            ),
          )
        ],
      ),
    );
    throw UnimplementedError();
  }
}
