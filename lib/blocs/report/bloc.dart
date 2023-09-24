import 'package:bloc/bloc.dart';
import 'package:docu_diary/db/dao/dao.dart';
// import 'package:docu_diary/utils/synchronize_singleton.dart';
import 'package:equatable/equatable.dart';
import 'package:docu_diary/repositories/repositories.dart';

import 'package:docu_diary/models/Observation_history.model.dart';
import 'package:docu_diary/models/PuplisReport.dart';
import 'package:docu_diary/models/pupilsModel.dart';

import 'package:docu_diary/models/token.dart';
import 'package:docu_diary/models/class.dart';
// import 'dart:typed_data';
import 'dart:async';

part 'event.dart';
part 'state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final TokenDao _tokenDao = TokenDao();
  final ClassDao _classDao = ClassDao();

  final SelectedClassDao _selectedClassDao = SelectedClassDao();
  // final SynchronizeSingleton _synchronizeSingleton = SynchronizeSingleton();
  final SelectedYearsDao _selectedYearDao = SelectedYearsDao();
  final ObservationRepository _observationRepository = ObservationRepository();

  ReportBloc() : super(ReportLoadInProgress());

  @override
  Stream<ReportState> mapEventToState(ReportEvent event) async* {
    if (event is LoadReport) {
      yield* _mapLoadedObservationToState();
    } else if (event is UpdateClass) {
      yield* _mapLoadedClassObservationToState(event);
    } else if (event is EditObservation) {
      yield* _mapEditObservationToState(event);
    } else if (event is GetPuplisReport) {
      yield* _mapGetPuplisReportToState(event);
    } else if (event is FilterReport) {
      yield* _mapFilterStudentsToState(event);
    } else if (event is FilterReportByTopics) {
      yield* _mapFilterStudentsBytopicsToState(event);
    }
  }

  Stream<ReportState> _mapLoadedObservationToState() async* {
    try {
      yield* _reloadReport();
    } catch (_) {
      yield ReportFailure();
    }
  }

  Stream<ReportState> _reloadReport({
    String filter = '',
    bool sortBySelectedClass = false,
    String studentId = '',
    bool visibilityT = true,
    int? position,
  }) async* {
    try {
      Token? token = await _tokenDao.getToken();
      Class? cls = await _selectedClassDao.getClass();

      var selectyear = await _selectedYearDao.getYear();
      var currentYear = selectyear!.name;

      var selectedClassId = cls!.id;
      // var selectedClassName = cls.className;
      var userToken = token!.accessToken;

      List<Observation> listObservations = [];
      List<PupilsModel> listPeoples = [];

      List<Class> classes = await _classDao.getClasses(currentYear!);
      if (classes.isEmpty) {
      }
      // await _selectedClassDao.update(classes.first);
      else {
        final Class? selectedClass = await _selectedClassDao.getClass();
        if (selectedClass != null) {
          classes = rearrange(classes, selectedClass);
        } else {
          await _selectedClassDao.update(classes.first);
        }

        var responseJsonTwo = await _observationRepository.fetchPeople(
            token: userToken, id: selectedClassId!);

        responseJsonTwo.forEach((v) => {
              listPeoples.add(PupilsModel.fromJson(v)),
            });

        if (filter != '') {
          listPeoples = listPeoples
              .where((e) =>
                  (e.firstName!.toLowerCase() + e.lastName!.toLowerCase())
                      .contains(filter
                          .toLowerCase()
                          .replaceAll(new RegExp(r"\s+\b|\b\s"), "")))
              .toList();
        }

        List<PuplisReport> listReports = [];
        if (studentId != '') {
          // var reportDetails = [];

          var responseJson = await _observationRepository.getPuplisReport(
              token: userToken, studentId: studentId);

          responseJson.forEach((v) => {
                listReports.add(PuplisReport.fromJson(v)),
              });
        }

        yield ReportLoadSuccess(
            classes: classes,
            selectedYear: currentYear,
            listPeoples: listPeoples,
            listReports: listReports,
            visibility: visibilityT,
            position: position!);
      }
    } catch (_) {
      yield ReportFailure();
    }
  }

  List<Class> rearrange(List<Class> classes, Class selectedClass) {
    final int index = classes.indexWhere((e) => e.id == selectedClass.id);
    if (index > -1) {
      final Class cls = classes.elementAt(index);
      classes.removeAt(index);
      classes.insert(0, cls);
    }

    return classes;
  }

  Stream<ReportState> _mapLoadedClassObservationToState(
      UpdateClass event) async* {
    final Class newClass = event.newClass;

    newClass.updatedAt = new DateTime.now().millisecondsSinceEpoch;
    await _classDao.update(newClass);
    await _selectedClassDao.update(newClass);

    yield* _reloadReport(sortBySelectedClass: true);
    try {} catch (_) {
      yield ReportFailure();
    }
  }

  Stream<ReportState> _mapFilterStudentsToState(FilterReport event) async* {
    try {
      final String text = event.text.toLowerCase();
      if (text.isEmpty) {
        yield* _reloadReport(sortBySelectedClass: true);
      } else {
        yield* _reloadReport(filter: text);
      }
    } catch (_) {
      yield ReportFailure();
    }
  }

  Stream<ReportState> _mapFilterStudentsBytopicsToState(
      FilterReportByTopics event) async* {
    try {
      // yield* _reloadReport(filterList: event.topics);
    } catch (_) {
      yield ReportFailure();
    }
  }

  Stream<ReportState> _mapEditObservationToState(EditObservation event) async* {
    try {
      Token? token = await _tokenDao.getToken();
      var idobservation = event.id;
      // String classID = id;

      var userToken = token!.accessToken;

      Map<String, dynamic> data = {
        'title': event.title,
        'classId': event.classId,
        'topicId': event.topicId,
        'controlId': event.controlId,
        'rating': event.rating,
        'studentId': event.studentId
      };

      await _observationRepository.sendeditObservation(
          token: userToken, id: idobservation!, observation: data);

      yield* _reloadReport(sortBySelectedClass: true);
    } catch (_) {
      yield ReportFailure();
    }
  }

  Stream<ReportState> _mapGetPuplisReportToState(GetPuplisReport event) async* {
    try {
      var studentId = event.studentId;
      var visibility = event.visibility;
      var observationNbr = event.observationNbr;
      var index = event.index;
      // String classID = id;

      yield* _reloadReport(
          studentId: studentId!,
          visibilityT: observationNbr! > 0 ? !visibility! : visibility!,
          position: index);
    } catch (_) {
      yield ReportFailure();
    }
  }
}
