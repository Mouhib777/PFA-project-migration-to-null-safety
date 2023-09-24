import 'package:bloc/bloc.dart';
import 'package:docu_diary/db/dao/dao.dart';
// import 'package:docu_diary/utils/synchronize_singleton.dart';
import 'package:equatable/equatable.dart';
import 'package:docu_diary/repositories/repositories.dart';

import 'package:docu_diary/models/Observation_history.model.dart';

import 'package:docu_diary/models/token.dart';
import 'package:docu_diary/models/class.dart';
import 'package:docu_diary/models/pupilsModel.dart'; // import 'package:connectivity/connectivity.dart';
// import 'dart:typed_data';
import 'dart:async';

part 'event.dart';
part 'state.dart';

class ObservationsBloc extends Bloc<ObservationsEvent, ObservationsState> {
  final TokenDao _tokenDao = TokenDao();
  final ClassDao _classDao = ClassDao();

  final SelectedClassDao _selectedClassDao = SelectedClassDao();
  // final SynchronizeSingleton _synchronizeSingleton = SynchronizeSingleton();
  final SelectedYearsDao _selectedYearDao = SelectedYearsDao();
  final ObservationRepository _observationRepository = ObservationRepository();

  ObservationsBloc() : super(ObservationsLoadInProgress());

  @override
  Stream<ObservationsState> mapEventToState(ObservationsEvent event) async* {
    if (event is LoadObservations) {
      yield* _mapLoadedObservationToState();
    } else if (event is UpdateClass) {
      yield* _mapLoadedClassObservationToState(event);
    } else if (event is LoadStudent) {
      yield* _mapLoadedStudentObservationToState(event);
    } else if (event is DeleteSpontaneousObservation) {
      yield* _mapDeleteSpontaneousObservation(event);
    } else if (event is DeleteStructuredObservation) {
      yield* _mapDeleteStructuredObservation(event);
    } else if (event is FilterObservation) {
      yield* _mapFilterStudentsToState(event);
    } else if (event is EditObservation) {
      yield* _mapEditObservationToState(event);
    }
  }

  Stream<ObservationsState> _mapLoadedObservationToState() async* {
    try {
      yield* _reloadObservations();
    } catch (_) {
      yield ObservationsFailure();
    }
  }

  Stream<ObservationsState> _reloadObservations(
      {bool setSelectedClass = false,
      String filter = '',
      bool sortBySelectedClass = false}) async* {
    try {
      Token? token = await _tokenDao.getToken();
      Class? cls = await _selectedClassDao.getClass();
      var selectyear = await _selectedYearDao.getYear();
      var currentYear = selectyear!.name;

      var selectedClassId = cls!.id;
      // var selectedClassName = cls.className;
      var userToken = token!.accessToken;

      List<Observation> listObservations = [];
      String defaultSelectValue;

      List<String> observations = [];

      List<Class>? classes = await _classDao.getClasses(currentYear!);
      if (classes.isEmpty) {
        yield ObservationsFailure();
      } else {
        final Class? selectedClass = await _selectedClassDao.getClass();
        if (selectedClass != null) {
          classes = rearrange(classes, selectedClass);
        } else {
          await _selectedClassDao.update(classes.first);
        }

        var responseJsonThree = await _observationRepository
            .getStudentsObservations(token: userToken, id: selectedClassId.toString());

        responseJsonThree.forEach((v) => {
              listObservations.add(Observation.fromJson(v)),
              observations.add(Observation.fromJson(v).sId!),
              observations.add(Observation.fromJson(v).classId!),
              observations.add(Observation.fromJson(v).date!),
              observations.add(Observation.fromJson(v).topicName!),
              observations.add(Observation.fromJson(v).title!),
              observations.add(Observation.fromJson(v).topicColor!),
              observations.add(Observation.fromJson(v).type!),
              Observation.fromJson(v).student != null
                  ? observations.add(Observation.fromJson(v).student!.firstName!)
                  : '',
              Observation.fromJson(v).student != null
                  ? observations.add(Observation.fromJson(v).student!.lastName!)
                  : '',
              Observation.fromJson(v).student != null
                  ? observations.add(Observation.fromJson(v).student!.picture!)
                  : '',
            });
        if (filter != '') {
          listObservations = listObservations
              .where((e) => (e.student!.firstName!.toLowerCase() +
                      e.student!.lastName!.toLowerCase() +
                      e.topicName!.toLowerCase() +
                      e.controlName!.toLowerCase())
                  .contains(filter
                      .toLowerCase()
                      .replaceAll(new RegExp(r"\s+\b|\b\s"), "")))
              .toList();
        }
        String defaultSelectValue = '';
        if(defaultSelectValue !=""){

        
        yield ObservationsLoadSuccess(
          classes: classes,
          listObservations: listObservations,
          defaultSelectValue: defaultSelectValue,
          selectedYear: currentYear,
        );
        }
      }
    } catch (_) {
      yield ObservationsFailure();
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

  Stream<ObservationsState> _mapLoadedClassObservationToState(
      UpdateClass event) async* {
    final Class newClass = event.newClass;

    newClass.updatedAt = new DateTime.now().millisecondsSinceEpoch;
    await _classDao.update(newClass);
    await _selectedClassDao.update(newClass);

    yield* _reloadObservations(sortBySelectedClass: true);
    try {} catch (_) {
      yield ObservationsFailure();
    }
  }

  Stream<ObservationsState> _mapLoadedStudentObservationToState(
      LoadStudent event) async* {
    final String? id = event.id;
    Token? token = await _tokenDao.getToken();
    List<PupilsModel> listPeoples = [];
    List<Observation> listObservations = [];

    List<String> observations = [];

    var items = <PupilsModel>[];
    // String classID = id;

    var userToken = token!.accessToken;

    var responseJson =
        await _observationRepository.fetchPeople(token: userToken, id: id!);

    responseJson.forEach((v) => {
          listPeoples.add(PupilsModel.fromJson(v)),
          items.add(PupilsModel.fromJson(v)),
        });

    var responseJsonTwo = await _observationRepository.getStudentsObservations(
        token: userToken, id: id!);
    responseJsonTwo.forEach((v) => {
          listObservations.add(Observation.fromJson(v)),
          observations.add(Observation.fromJson(v).sId!),
          observations.add(Observation.fromJson(v).classId!),
          observations.add(Observation.fromJson(v).date!),
          observations.add(Observation.fromJson(v).topicName!),
          observations.add(Observation.fromJson(v).title!),
          observations.add(Observation.fromJson(v).topicColor!),
          observations.add(Observation.fromJson(v).type!),
          Observation.fromJson(v).student != null
              ? observations.add(Observation.fromJson(v).student!.firstName!)
              : '',
          Observation.fromJson(v).student != null
              ? observations.add(Observation.fromJson(v).student!.lastName!)
              : '',
          Observation.fromJson(v).student != null
              ? observations.add(Observation.fromJson(v).student!.picture!)
              : '',
        });

    try {} catch (_) {
      yield ObservationsFailure();
    }
  }

  Stream<ObservationsState> _mapDeleteSpontaneousObservation(
      DeleteSpontaneousObservation event) async* {
    final String id = event.observationId;
    Token? token = await _tokenDao.getToken();

    var userToken = token!.accessToken;

    await _observationRepository.deleteSpontaneousObservation(
        token: userToken, observationId: id);
    yield* _reloadObservations(sortBySelectedClass: true);

    try {} catch (_) {
      yield ObservationsFailure();
    }
  }

  Stream<ObservationsState> _mapDeleteStructuredObservation(
      DeleteStructuredObservation event) async* {
    final String? id = event.observationId;
    Token? token = await _tokenDao.getToken();

    var userToken = token!.accessToken;

    await _observationRepository.deleteStructuredObservation(
        token: userToken, observationId: id!, studentId: event.studentId!);
    yield* _reloadObservations(sortBySelectedClass: true);

    try {} catch (_) {
      yield ObservationsFailure();
    }
  }

  Stream<ObservationsState> _mapFilterStudentsToState(
      FilterObservation event) async* {
    try {
      final String text = event.text.toLowerCase();
      if (text.isEmpty) {
        yield* _reloadObservations(sortBySelectedClass: true);
      } else {
        yield* _reloadObservations(filter: text);
      }
    } catch (_) {
      yield ObservationsFailure();
    }
  }

  Stream<ObservationsState> _mapEditObservationToState(
      EditObservation event) async* {
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
        'studentId': event.studentId,
        'date': event.date
      };

      await _observationRepository.sendeditObservation(
          token: userToken, id: idobservation!, observation: data);

      yield* _reloadObservations(sortBySelectedClass: true);
    } catch (_) {
      yield ObservationsFailure();
    }
  }
}
