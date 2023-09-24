import 'package:docu_diary/views/Observations/Observation_history.dart';
import 'package:docu_diary/views/dashboard/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:docu_diary/config/url.dart';
import 'package:docu_diary/views/Drawer/drawer.dart';
import 'package:docu_diary/models/pupilsModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:docu_diary/models/class.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:docu_diary/blocs/report/bloc.dart';
import 'package:docu_diary/widgets/loading_indicator.dart';
import 'dart:io';
import 'package:docu_diary/connectionStatusSingleton.dart';
import 'package:docu_diary/models/Observations.dart';
import 'package:docu_diary/models/PuplisReport.dart';
import 'package:docu_diary/utils/snackbar.dart';
import 'package:docu_diary/views/dashboard/smiley_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'ExpandableCardView.dart';
import 'multiSelect.dart';
import 'package:docu_diary/models/models.dart';
import 'dart:convert';
import 'Dart:typed_data';
import 'package:docu_diary/db/dao/dao.dart';
import 'package:docu_diary/repositories/repositories.dart';
import 'package:http/http.dart' as http;

class PupilsReport extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  PupilsReport();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: BlocProvider(
            create: (BuildContext context) => ReportBloc(),
            child: Row(children: <Widget>[
              AppDrawer(currentPage: 'PupilsReport', scaffoldKey: _scaffoldKey),
              Expanded(
                child: Scaffold(
                    backgroundColor: Colors.white,
                    resizeToAvoidBottomInset: false,
                    body: PupilsReportContent(
                      _scaffoldKey,
                    )),
              )
            ])));
  }
}

class PupilsReportContent extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  PupilsReportContent(this._scaffoldKey);
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
  
//   _PupilsReportContentState createState() =>
//       _PupilsReportContentState(_scaffoldKey);
//
}

class _PupilsReportContentState extends State<PupilsReportContent> {
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  // _PupilsReportContentState(this._scaffoldKey);

  late StreamSubscription _connectionChangeStream;

  // SingingCharacter _character = SingingCharacter.full_report;
  static final _baseUrl = BaseUrl.urlAPi;
  ObservationsModel observations = ObservationsModel();
  String userToken = '';
  final TokenDao _tokenDao = TokenDao();
  final ObservationRepository _observationRepository = ObservationRepository();

  Class? selectedClass;

  var items = [];

  final ScrollController _scrollController = ScrollController();

  bool _hasConnection = true;

  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () {
      // context.bloc<ReportBloc>()..add(LoadReport());
    });
//! voir lib/utils/snackbar
    // ConnectionStatusSingleton connectionStatus =
    //     ConnectionStatusSingleton.getInstance();
    // new Future.delayed(Duration.zero, () {
    //   _hasConnection = connectionStatus.hasConnection;
  //     if (!connectionStatus.hasConnection) {
  //       _showSnackbarConnectionStatus(false);
  //     }
  //     _connectionChangeStream =
  //         connectionStatus.connectionChange.listen(connectionChanged);
  //   });
  // }

  // void _hideSnackbar() {
  //   SnackBarUtils.hideSnackbar(_scaffoldKey);
  // }

  // void _showSnackbarConnectionStatus(bool connected) {
  //   _hideSnackbar();
  //   SnackBarUtils.showSnackbarPupilsReportConnectionStatus(
  //       _scaffoldKey, connected, _hideSnackbar);
  // }

  // void connectionChanged(dynamic hasConnection) {
  //   _showSnackbarConnectionStatus(hasConnection);
  //   setState(() {
  //     _hasConnection = hasConnection;
  //   });
  // }
  }
  @override
  void dispose() {
    _connectionChangeStream.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  var isLoading = false;

  List<String>? filteredTopics = [];

  updateFilteredTopics(List<Topic> filtered) {
    setState(() {
      filteredTopics = filtered.map((e) => e.id!).toList();
    });
  }

  final pdf = pw.Document();
  var anchor;

  savePDFNew(List<PupilsModel> listPupils, List<PuplisReport> listReports,
      String className, int position) async {
    if (position == null) {
      return;
    }

    print('---------------------- pdf save');
    Token? token = await _tokenDao.getToken();
    // var selectedClassName = cls.className;
    var userToken = token!.accessToken;
    // String classID = id;

    final topicList = filteredTopics!.isEmpty
        ? listReports.first.topics
        : listReports.first.topics
            !.where((e) => filteredTopics!.indexOf(e.sId!) > -1)
            .toList();

    final x = [];
    for (var i = 0; i < topicList!.length; i++) {
      x.add(topicList[i].sId);
    }

    var responseJson = await _observationRepository.getPuplisReportPdf(
        token: userToken,
        studentId: listPupils[position].sId,
        observationList: x);

    // String dir = (await getApplicationDocumentsDirectory()).path;
    if (kIsWeb) {
      // Set web-specific directory
      if (responseJson != '') {
        try {
          http.Response response = await http.get(Uri.parse('$_baseUrl$responseJson'));

          await Printing.sharePdf(
              bytes: response.bodyBytes,
              filename: '' +
                  listPupils[position].firstName! +
                  ' ' +
                  listPupils[position].lastName! +
                  '_' +
                  new DateFormat('yyyyMMdd').format(new DateTime.now()) +
                  '.pdf');
        } catch (e) {
          print(e);
        }
      }
    } else {
      http.Response response = await http.get(Uri.parse('$_baseUrl$responseJson'));

      await Printing.sharePdf(
          bytes: response.bodyBytes,
          filename: '' +
              listPupils[position].firstName! +
              ' ' +
              listPupils[position].lastName! +
              '_' +
              new DateFormat('yyyyMMdd').format(new DateTime.now()) +
              '.pdf');
    }
  }

  savePdf(List<PupilsModel> listPupils, List<PuplisReport> listReports,
      String className, int position) async {
    if (position == null) {
      return;
    }

    final PupilsModel student = listPupils[position];

    final String currentDate =
        new DateFormat('yyyyMMdd').format(new DateTime.now());

    Token? token = await _tokenDao.getToken();
    // var selectedClassName = cls.className;
    var userToken = token!.accessToken;
    // String classID = id;

    final topicList = filteredTopics!.isEmpty
        ? listReports.first.topics
        : listReports.first.topics
            !.where((e) => filteredTopics!.indexOf(e.sId!) > -1)
            .toList();

    final x = [];
    for (var i = 0; i < topicList!.length; i++) {
      x.add(topicList[i].sId);
    }

    var responseJson = await _observationRepository.getPuplisReportPdf(
        token: userToken,
        studentId: listPupils[position].sId,
        observationList: x);

    // final doc =
    //     await buildPdfDocument(listPupils, listReports, className, position);
    if (responseJson != '') {
      try {
        http.Response response = await http.get(Uri.parse('$_baseUrl/$responseJson'));

        // await Printing.sharePdf(
        //     bytes: response.bodyBytes,
        //     filename: '' +
        //         listPupils[position].firstName +
        //         ' ' +
        //         listPupils[position].lastName +
        //         '_' +
        //         new DateFormat('yyyyMMdd').format(new DateTime.now()) +
        //         '.pdf');

        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String appDocPath = appDocDir.path;

        final File file = File(appDocPath +
            '/' +
            currentDate +
            '_' +
            student.firstName! +
            ' ' +
            student.lastName! +
            '.pdf');
        await file.writeAsBytes(response.bodyBytes);
        OpenFile.open(file.path);
      } catch (e) {
        print(e);
      }
    }
  }

  buildPdfDocument(List<PupilsModel> listPupils, List<PuplisReport> listReports,
      String className, int position) async {
    final pageFormat = PdfPageFormat.letter.copyWith(
        marginTop: 1 * PdfPageFormat.cm,
        marginBottom: 0.75 * PdfPageFormat.cm,
        marginLeft: 1 * PdfPageFormat.cm,
        marginRight: 1 * PdfPageFormat.cm);
    final PupilsModel student = listPupils[position];

    final topicList = filteredTopics!.isEmpty
        ? listReports.first.topics
        : listReports.first.topics
            !.where((e) => filteredTopics!.indexOf(e.sId!) > -1)
            .toList();

    final String currentDate =
        new DateFormat('yyyyMMdd').format(new DateTime.now());
    final doc = pw.Document(
        title: currentDate + '_' + student.firstName! + ' ' + student.lastName!);

    final PdfImage logoImage = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('assets/images/Logo.png'))
          .buffer
          .asUint8List(),
    );

    final PdfImage profileImage = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('assets/images/_e-reading.png'))
          .buffer
          .asUint8List(),
    );

    final PdfImage painRating = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('assets/images/pain.png'))
          .buffer
          .asUint8List(),
    );

    final PdfImage sadRating = PdfImage.file(
      doc.document,
      bytes:
          (await rootBundle.load('assets/images/sad.png')).buffer.asUint8List(),
    );

    final PdfImage happyRating = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('assets/images/happy.png'))
          .buffer
          .asUint8List(),
    );

    final PdfImage amazingRating = PdfImage.file(
      doc.document,
      bytes: (await rootBundle.load('assets/images/amazing.png'))
          .buffer
          .asUint8List(),
    );

    PdfImage _getRating(rate) {
      switch (rate) {
        case 1:
          return painRating;
        case 2:
          return sadRating;
        case 3:
          return happyRating;
        case 4:
          return amazingRating;
        default:
          return painRating;
      }
    }

    doc.addPage(pw.MultiPage(
        pageFormat: pageFormat,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        footer: (pw.Context context) {
          return pw.Container(
              padding: pw.EdgeInsets.symmetric(horizontal: 25),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.ClipRRect(
                        horizontalRadius: 5,
                        verticalRadius: 5,
                        child: pw.Image(
                          logoImage as pw.ImageProvider,
                          width: 100,
                        )),
                    pw.Text(
                        'Seite ${context.pageNumber} von ${context.pagesCount}',
                        style: pw.Theme.of(context)
                            .defaultTextStyle
                            .copyWith(color: PdfColors.grey))
                  ]));
        },
        build: (pw.Context context) => <pw.Widget>[
              pw.Header(
                  level: 0,
                  margin: pw.EdgeInsets.only(right: 35, left: 25),
                  padding: pw.EdgeInsets.only(bottom: 10),
                  child: pw.Row(
                      // mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: <pw.Widget>[
                        pw.ClipRRect(
                            horizontalRadius: 5,
                            verticalRadius: 5,
                            child: pw.Image(
                              profileImage as pw.ImageProvider,
                              width: 40,
                              height: 40,
                            )),
                        pw.SizedBox(
                          width: pageFormat.width * 0.035,
                        ),
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                (filteredTopics!.isEmpty &&
                                            listReports.isNotEmpty
                                        ? listReports.first.firstName
                                        : student.firstName)! +
                                    ' ' +
                                    (filteredTopics!.isEmpty &&
                                            listReports.isNotEmpty
                                        ? listReports.first.lastName!
                                        : student.lastName!),
                                style: pw.TextStyle(
                                    color: PdfColor.fromInt(0x808080),
                                    fontSize: 14.0,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text(
                                "Klasse " +
                                    className +
                                    ", Schuljahr " +
                                    student.schoolYear!,
                                style: pw.TextStyle(
                                    color: PdfColor.fromInt(0x808080),
                                    fontSize: 13.0,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ]),
                        pw.Spacer(),
                        pw.Container(
                          child: pw.Text(
                            getObservationCountText((filteredTopics!.isEmpty &&
                                    listReports.isNotEmpty
                                ? listReports.first.observation!
                                : student.observation!)),
                            style: pw.TextStyle(
                                color: PdfColor.fromInt(0xFFff6c00),
                                fontSize: 12.0,
                                fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ])),
              pw.Column(
                  children: topicList!.map((topic) {
                return pw.Container(
                    margin: pw.EdgeInsets.only(top: 10),
                    padding: pw.EdgeInsets.symmetric(horizontal: 20),
                    child: pw.Column(children: [
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                                topic.name! +
                                    ' ( ' +
                                    topic.observation.toString() +
                                    ' )',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 12.0,
                                    color:PdfColors.black)),
                          ]),
                      pw.Row(children: [
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: topic.controls!.map((control) {
                              return pw.Container(
                                  padding: pw.EdgeInsets.only(
                                      left: 30, top: 10, bottom: 10),
                                  child: pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Container(
                                          child: pw.Text(
                                            control.name!,
                                            style: pw.TextStyle(
                                                fontWeight: pw.FontWeight.bold,
                                                fontSize: 12.0,
                                                color: PdfColors.black),
                                          ),
                                        ),
                                        pw.Container(
                                            child: pw.Column(
                                                mainAxisAlignment:
                                                    pw.MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    pw.CrossAxisAlignment.start,
                                                children: control.observations
                                                    !.map((value) {
                                                  return pw.Container(
                                                      width: pageFormat.width *
                                                          0.76,
                                                      margin: pw.EdgeInsets
                                                          .symmetric(
                                                              vertical: 5),
                                                      child: pw.Row(
                                                          mainAxisAlignment: pw
                                                              .MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            value.rating! > 0
                                                                ? pw.Image(
                                                                    _getRating(value
                                                                        .rating) as pw.ImageProvider,
                                                                    width: 25,
                                                                    height: 25,
                                                                  )
                                                                : pw.Container(
                                                                    width: 25),
                                                            pw.Container(
                                                                width: pageFormat
                                                                        .width *
                                                                    0.50,
                                                                child: pw.Text(
                                                                  value.title
                                                                      .toString()
                                                                      .replaceAll(
                                                                          "„",
                                                                          ",,")
                                                                      .replaceAll(
                                                                          "“",
                                                                          "''")
                                                                      .replaceAll(
                                                                          "–",
                                                                          "-"),
                                                                  style: pw.TextStyle(
                                                                      fontSize:
                                                                          12.0),
                                                                )),
                                                            pw.Text(
                                                              value.dateOfUpdate ==
                                                                      null
                                                                  ? value.date!
                                                                  : value
                                                                      .dateOfUpdate!,
                                                              style: pw.TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                  color: PdfColors
                                                                      .grey500),
                                                            )
                                                          ]));
                                                }).toList()))
                                      ]));
                            }).toList())
                      ]),
                    ]));
              }).toList()),
            ]));
    return doc;
  }

  _printDocument(List<PupilsModel> listPupils, List<PuplisReport> listReports,
      String className, int position) async {
    if (position == null) {
      return;
    }
    Token? token = await _tokenDao.getToken();
    // var selectedClassName = cls.className;
    var userToken = token!.accessToken;
    // String classID = id;
    final topicList = filteredTopics!.isEmpty
        ? listReports.first.topics
        : listReports.first.topics
            !.where((e) => filteredTopics!.indexOf(e.sId!) > -1)
            .toList();

    final x = [];
    for (var i = 0; i < topicList!.length; i++) {
      x.add(topicList[i].sId);
    }
    var responseJson = await _observationRepository.getPuplisReportPdf(
        token: userToken,
        studentId: listPupils[position].sId,
        observationList: x);
    print(responseJson);
    // String dir = (await getApplicationDocumentsDirectory()).path;
    if (responseJson != "") {
      // Set web-specific directory
      try {
        http.Response response = await http.get(Uri.parse('$_baseUrl$responseJson'));
        var pdfData = response.bodyBytes;

        Printing.layoutPdf(
          onLayout: (pageFormat) async {
            return pdfData;
          },
        );
      } catch (e) {
        print(e);
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportBloc, ReportState>(
        listenWhen: (previous, current) {
      return current is ReportFailure;
    }, listener: (context, state) {
      if (state is ReportFailure) {}
    }, buildWhen: (previous, current) {
      return current is ReportLoadInProgress || current is ReportLoadSuccess;
    }, builder: (context, state) {
      if (state is ReportLoadInProgress) {
        return Center(
          child: Container(child: LoadingIndicator()),
        );
      } else if (state is ReportLoadSuccess) {
        final List<Class> classes = state.classes!;
        final Class selectedClass = classes.first;
        final List<PupilsModel> listPupils = state.listPeoples!;
        final List<PuplisReport> listReports = state.listReports!;

        final selectedYear = state.selectedYear;
        final visibility = state.visibility;

        final int? position = state.position != null ? state.position : null;

        return Row(
          children: <Widget>[
            SafeArea(
                child: Container(
              width: MediaQuery.of(context).size.width * 0.60,
              padding: EdgeInsets.only(top: 40, left: 20, right: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // SchoolYear(currentYear: selectedYear),
                          Container(
                            child: DropdownButton<Class>(
                              value: selectedClass,
                              underline: Container(),
                              icon: Icon(Icons.keyboard_arrow_down),
                              iconSize: 50.0,
                              iconEnabledColor: Color(0xFFff7f00),
                              onChanged: (Class? newValue) {
                                // context.bloc<ReportBloc>()
                                //   ..add(UpdateClass(newValue));
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
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.24,
                              height: MediaQuery.of(context).size.height * 0.05,
                              // child: Search(selectedClass: selectedClass)
                              )
                              )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // part left
                  Expanded(
                    child: Container(
                        child: Scrollbar(
                      // isAlwaysShown: true,
                      controller: _scrollController,
                      child: visibility!
                          ? Container(
                              child: ListView.separated(
                                shrinkWrap: true,
                                controller: _scrollController,
                                itemCount: listPupils.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      // context.bloc<ReportBloc>()
                                      //   ..add(GetPuplisReport(
                                      //       studentId: listPupils[index].sId,
                                      //       observationNbr:
                                      //           listPupils[index].observation,
                                      //       visibility: visibility,
                                      //       index: index));
                                    },
                                    child: Container(
                                        decoration:
                                            new BoxDecoration(boxShadow: [
                                          new BoxShadow(
                                            color: Colors.grey.withOpacity(.04),
                                            blurRadius: 3,
                                          ),
                                        ]),
                                        child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            elevation: 0.0,
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              child: Center(
                                                child: Row(children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.030,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.060,
                                                        margin: EdgeInsets.only(
                                                            left: 15),
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child: listPupils[index]
                                                                            .picture !=
                                                                        null &&
                                                                    listPupils[index]
                                                                            .picture !=
                                                                        ''
                                                                ? Image.network(
                                                                    '$_baseUrl' +
                                                                        'public/${listPupils[index].picture.toString()}',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : Image.asset(
                                                                    'assets/images/_e-reading.png',
                                                                    width: 50,
                                                                    height: 50,
                                                                  )),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                          context,
                                                          '/addPupil',
                                                          arguments: <String,
                                                              String>{
                                                            'id': listPupils[
                                                                    index]
                                                                .sId!,
                                                            'firstName':
                                                                listPupils[
                                                                        index]
                                                                    .firstName!,
                                                            'lastName':
                                                                listPupils[
                                                                        index]
                                                                    .lastName!,
                                                            'className':
                                                                listPupils[
                                                                        index]
                                                                    .className!,
                                                            'birthdayDate':
                                                                listPupils[
                                                                        index]
                                                                    .birthdayDate!,
                                                            'CurrentPage':
                                                                'pupilsReport',
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: 20),
                                                  Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                        child: Text(
                                                            listPupils[index]
                                                                    .firstName! +
                                                                ' ' +
                                                                listPupils[
                                                                        index]
                                                                    .lastName!,
                                                            style: TextStyle(
                                                                fontSize: 15)),
                                                      )),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        child: Text(
                                                            getObservationCountText(
                                                                listPupils[
                                                                        index]
                                                                    .observation!),
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xFFd0d1d4),
                                                                fontSize: 15)),
                                                      )),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        child: SmileyWidget(
                                                            classId:
                                                                selectedClass
                                                                    ?.id,
                                                            studentId:
                                                                listPupils[
                                                                        index]
                                                                    .sId,
                                                            observationId: '',
                                                            rating: listPupils[
                                                                    index]
                                                                .rating,
                                                            isShowAllSmileys:
                                                                false),
                                                      )),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        child: InkWell(
                                                          child: ClipRRect(
                                                            child: Image.asset(
                                                              'assets/images/ea.png',
                                                              width: 36,
                                                              height: 36,
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            // change here
                                                            // context.bloc<
                                                            //     ReportBloc>()
                                                            //   ..add(GetPuplisReport(
                                                            //       studentId:
                                                            //           listPupils[
                                                            //                   index]
                                                            //               .sId,
                                                            //       observationNbr:
                                                            //           listPupils[
                                                            //                   index]
                                                            //               .observation,
                                                            //       visibility:
                                                            //           visibility,
                                                            //       index:
                                                            //           index));
                                                          },
                                                        ),
                                                      ))
                                                ]),
                                              ),
                                            ))),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 3));
                                },
                              ),
                            )
                          : InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => PupilsReport(),
                                    transitionDuration: Duration(seconds: 0),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.only(right: 15),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          child: InkWell(
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(right: 15.0),
                                              child: Icon(
                                                  Icons.arrow_back_sharp,
                                                  color: Color(0xFFf45d27)),
                                            ),
                                            onTap: () {
                                              // change here
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) =>
                                                      PupilsReport(),
                                                  transitionDuration:
                                                      Duration(seconds: 0),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.065,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.075,
                                          margin: EdgeInsets.only(left: 15),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: listPupils[position!]
                                                              .picture !=
                                                          null &&
                                                      listPupils[position]
                                                              .picture
                                                              .toString() !=
                                                          ""
                                                  ? Image.network(
                                                      '$_baseUrl' +
                                                          'public/${listPupils[position].picture.toString()}',
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/_e-reading.png',
                                                      width: 50,
                                                      height: 50,
                                                    )),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.015,
                                        ),
                                        new GestureDetector(
                                          onTap: () {},
                                          child: new Text(
                                            (filteredTopics!.isEmpty &&
                                                        listReports.isNotEmpty
                                                    ? listReports
                                                        .first.firstName
                                                    : listPupils[position]
                                                        .firstName)! +
                                                ' ' +
                                                (filteredTopics!.isEmpty &&
                                                        listReports.isNotEmpty
                                                    ? listReports.first.lastName
                                                    : listPupils[position]
                                                        .lastName)!,
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Spacer(),
                                        Container(
                                          margin: EdgeInsets.only(right: 15.0),
                                          child: Text(
                                            getObservationCountText(
                                                (filteredTopics!.isEmpty &&
                                                        listReports.isNotEmpty
                                                    ? listReports
                                                        .first.observation
                                                    : listPupils[position]
                                                        .observation)!),
                                            style: TextStyle(
                                                color: Color(0xFFff6c00),
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: ExpandableCardView(
                                        topicList: filteredTopics!.isEmpty &&
                                                listReports.isNotEmpty
                                            ? listReports.first.topics
                                            : listReports.first.topics
                                                !.where((e) =>
                                                    filteredTopics
                                                        !.indexOf(e.sId!) >
                                                    -1)
                                                .toList(),
                                        sid: listPupils[position].sId,
                                      ),
                                    ),
                                    InkWell(
                                        child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) =>
                                                      PupilsReport(),
                                                  transitionDuration:
                                                      Duration(seconds: 0),
                                                ),
                                              );
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  height: 20,
                                                  child: Image.asset(
                                                    'assets/images/back_button.png',
                                                  ),
                                                ),
                                                SizedBox(
                                                  child: Container(
                                                    width: 10,
                                                  ),
                                                ),
                                                Container(
                                                  child: InkWell(
                                                    child: Text(
                                                      "Zurück",
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFFff8300),
                                                          fontSize: 20.0),
                                                    ),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          pageBuilder: (_, __,
                                                                  ___) =>
                                                              PupilsReport(),
                                                          transitionDuration:
                                                              Duration(
                                                                  seconds: 0),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ))),
                                  ],
                                ),
                              )),
                    )),
                  )
                ],
              ),
            )),
            // part right
            Expanded(
              child: Container(
                color: Color(0xFFf7f7ff),
                child: Column(
                  children: [
                    Container(
                        height: MediaQuery.of(context).size.height * 0.05),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Report Einstellungen',
                                style: TextStyle(
                                    color: Color(0xFF333951),
                                    fontSize: 18.7,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Hier stellen Sie Ihren Schülerreport ein.',
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.blueGrey[600],
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        )),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.55,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            title: kIsWeb
                                ? Text(
                                    'Vollständiger Report',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 17.0,
                                    ),
                                  )
                                : Text(
                                    'Vollständiger \n Report',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 17.0,
                                    ),
                                  ),
                            // leading: ((position != null) &&
                            //         listPupils[position].observation! > 0)
                                // ? Radio(
                                //     // value: SingingCharacter.full_report,
                                //     groupValue: _character,
                                //     // onChanged: (SingingCharacter value) {
                                //     //   setState(() {
                                //     //     _character = value;
                                //     //     updateFilteredTopics(
                                //     //         selectedClass.topics);
                                //     //   });
                                //     // },
                                //   )
                                // : Container(
                                //     width: 45,
                                //     child: Icon(
                                //       Icons.radio_button_unchecked,
                                //       size: 21.0,
                                    // )
                                // ),
                          ),
                          ListTile(
                              title: kIsWeb
                                  ? Text(
                                      'Ausgewählte Bereiche',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 17.0,
                                      ),
                                    )
                                  : Text(
                                      'Ausgewählte \n Bereiche',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 17.0,
                                      ),
                                    ),
                              // leading: (position != null &&
                              //         listPupils[position].observation! > 0)
                              //     ? Radio(
                              //         // value: SingingCharacter.select_topic,
                              //         groupValue: _character,
                              //         onChanged: (SingingCharacter value) {
                              //           setState(() {
                              //             _character = value;
                              //             updateFilteredTopics(
                              //                 selectedClass.topics);
                              //           });
                              //         },
                              //       )
                              //     : Container(
                              //         width: 45,
                              //         child: Icon(
                              //           Icons.radio_button_unchecked,
                              //           size: 21.0,
                              //         ),
                                    // )
                                    ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          // selectedClass != null &&
                          //         _character == SingingCharacter.select_topic
                          //     ? MultiSelect(
                          //         selectedClass: selectedClass,
                          //         updateTopics: updateFilteredTopics)
                          //     : SizedBox(
                          //         height:
                          //             MediaQuery.of(context).size.height * 0.3),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.27,
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                                child: Center(
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: AutoSizeText(
                                        kIsWeb
                                            ? 'Hier können Sie den Schülerreport drucken. Für das Speichern als PDF-Datei nutzen Sie einen PDF-Drucker oder die direkte PDF-Druckoption auf unseren Tablet-Apps (iOS oder Android).'
                                            : 'Hier können Sie den Schülerreport drucken oder als PDF-Datei speichern.',
                                        maxLines: 3,
                                        style: TextStyle(
                                          color: Color(0xFF333951),
                                          fontSize: 13,
                                        ),
                                      )),
                                )),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            !kIsWeb
                                ? position != null &&
                                        listPupils[position].observation! > 0
                                    ? Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: <Color>[
                                              Colors.orange,
                                              Color(0xFFff6c00),
                                            ],
                                          ),
                                        ),
                                        child: ElevatedButton(
                                            // textColor: Colors.white,
                                            child: new Text(
                                              "PDF Report erstellen",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ),
                                            onPressed: () {
                                              savePDFNew(
                                                  listPupils,
                                                  listReports,
                                                  selectedClass.className!,
                                                  position);
                                            }),
                                      )
                                    : Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        child: const ElevatedButton(
                                          onPressed: null,
                                          child: Text("PDF Report erstellen",
                                              style: TextStyle(fontSize: 15)),
                                        ))
                                : position != null &&
                                        listPupils[position].observation! > 0
                                    ? Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: <Color>[
                                              Colors.orange,
                                              Color(0xFFff6c00),
                                            ],
                                          ),
                                        ),
                                        child: ElevatedButton(
                                            // textColor: Colors.white,
                                            child: new Text(
                                              "PDF Report erstellen",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.white),
                                            ),
                                            onPressed: () {
                                              savePDFNew(
                                                  listPupils,
                                                  listReports,
                                                  selectedClass.className!,
                                                  position);
                                            }),
                                      )
                                    : Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        child: const ElevatedButton(
                                          onPressed: null,
                                          child: Text("PDF Report erstellen",
                                              style: TextStyle(fontSize: 15)),
                                        )),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            position != null &&
                                    ((listPupils[position].observation! > 0) ||
                                        (filteredTopics!.isEmpty &&
                                            listReports.isNotEmpty &&
                                            listReports.first.observation! > 0))
                                ? Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: <Color>[
                                          Colors.orange,
                                          Color(0xFFff6c00),
                                        ],
                                      ),
                                    ),
                                    child: ElevatedButton(
                                        // textColor: Colors.white,
                                        child: new Text(
                                          "Drucken",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white),
                                        ),
                                        onPressed: () {
                                          _printDocument(
                                              listPupils,
                                              listReports,
                                              selectedClass.className!,
                                              position);
                                        }),
                                  )
                                : Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    child: const ElevatedButton(
                                      onPressed: null,
                                      child: Text("Drucken",
                                          style: TextStyle(fontSize: 15)),
                                    )),
                          ],
                        )),
                  ],
                ),
              ),
            )
          ],
        );
      } else
        return Container();
    });
  }
}
//!!!!!!!!!!!!!!!!!!!
// yaer

// class SchoolYear extends StatefulWidget {
//   final String currentYear;
//   SchoolYear({Key key, @required this.currentYear}) : super(key: key);

//   @override
//   _SchoolYearState createState() => _SchoolYearState(currentYear);
// }

// class _SchoolYearState extends State<SchoolYear> {
//   String currentYear;
//   _SchoolYearState(this.currentYear);
//   Widget build(BuildContext context) {
//     return Theme(
//       data: ThemeData(
//         highlightColor: Colors.grey[900],
//         primaryColor: Color(0xFFFB415B),
//         fontFamily: 'Cera-Medium',
//       ),
//       child: Container(
//         padding: EdgeInsets.only(left: 40),
//         child: Text(
//           'Schuljahr $currentYear',
//           style: TextStyle(color: Color(0xFF87333951), fontSize: 19.3),
//         ),
//       ),
//     );
//   }
// }

// class Search extends StatefulWidget {
//   final Class selectedClass;
//   Search({Key key, @required this.selectedClass}) : super(key: key);

//   @override
//   _SearchState createState() => _SearchState(selectedClass);
// }

// class _SearchState extends State<Search> {
//   Class selectedClass;
//   final textController = TextEditingController();
//   _SearchState(this.selectedClass);

//   void initState() {
//     super.initState();
//     textController.addListener(_filterStudents);
//   }

//   _filterStudents() {
//     context.bloc<ReportBloc>()..add(FilterReport(textController.text));
//   }

//   @override
//   didUpdateWidget(Search oldWidget) {
//     setState(() {
//       selectedClass = widget.selectedClass;
//       if (oldWidget.selectedClass?.id != widget.selectedClass?.id) {
//         textController.text = '';
//         FocusScope.of(context).unfocus();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
//       child: Container(
//         width: MediaQuery.of(context).size.width * 0.24,
//         height: MediaQuery.of(context).size.height * 0.05,
//         child: TextField(
//           controller: textController,
//           decoration: InputDecoration(
//               contentPadding: EdgeInsets.symmetric(vertical: 10),
//               filled: true,
//               fillColor: Color(0xFFf7f7ff),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(40),
//                 ),
//                 borderSide: BorderSide.none,
//               ),
//               hintText: 'Suche ...',
//               labelStyle: TextStyle(
//                 color: Color(0xFFa5a5a5),
//                 fontSize: 18,
//               ),
//               prefixIcon: Icon(
//                 Icons.search,
//                 color: Color(0xFFff7800),
//               )),
//         ),
//       ),
//     );
//   }
// }

// /* ***********************/
// enum SingingCharacter { full_report, select_topic }
// String getObservationCountText(int count) {
//   if (count == 1) return count.toString() + ' Notiz';

//   return count.toString() + ' Notizen';
// }

// PdfColor getTopicColor(String topicColor) {
//   if (topicColor != '') return PdfColor.fromInt(int.parse('$topicColor'));
//   return PdfColors.black;
// }
