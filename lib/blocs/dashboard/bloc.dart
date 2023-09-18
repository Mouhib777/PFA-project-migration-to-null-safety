import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:docu_diary/db/dao/dao.dart';
import 'package:docu_diary/repositories/repositories.dart';
import 'package:docu_diary/utils/synchronize_singleton.dart';
import 'package:equatable/equatable.dart';
import 'package:docu_diary/models/models.dart';
import 'package:flutter/foundation.dart';

part 'event.dart';
part 'state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ClassDao _classDao = ClassDao();
  final TokenDao _tokenDao = TokenDao();
  final SelectedClassDao _selectedClassDao = SelectedClassDao();
  final ClassRepository _classRepository = ClassRepository();
  final SynchronizeSingleton _synchronizeSingleton = SynchronizeSingleton();
  final YearDao _yearDao = YearDao();
  final PayementRepository _payementRepository = PayementRepository();
  final SelectedYearsDao _selectedYearDao = SelectedYearsDao();
  DashboardBloc() : super(DashboardLoadInProgress());
  final _yearDefault = '2021/2022';

  @override
  Stream<DashboardState> mapEventToState(DashboardEvent event) async* {
    if (event is LoadClasses) {
      yield* _mapClassLoadedToState();
    } else if (event is UpdateClass) {
      yield* _mapUpdateClassToState(event);
    } else if (event is LoadYears) {
      yield* _mapLoadYearsToState();
    } else if (event is UpdateYear) {
      yield* _mapUpdateYearToState(event);
    } else if (event is LoadControls) {
      yield* _mapLoadControlsToState(event);
    } else if (event is UpdateTopicsClass) {
      yield* _mapUpdateTopicsToState(event);
    } else if (event is LoadStudentsClass) {
      yield* _mapLoadStudentsToState(event.cls);
    } else if (event is LoadObservation) {
      yield* _mapLoadObservationToState(event);
    } else if (event is CreateStructureObservation) {
      yield* _mapCreateStructuredObservationToState(event);
    } else if (event is EditObservationName) {
      yield* _mapEditObservationToState(event);
    } else if (event is CompleteObservation) {
      yield* _mapCompleteObservationToState(event);
    } else if (event is DeleteObservation) {
      yield* _mapDeleteObservationToState(event);
    } else if (event is UpdateRating) {
      yield* _mapUpdateRatingToState(event);
    } else if (event is UpdateFavorite) {
      yield* _mapUpdateFavoriteToState(event);
    } else if (event is FilterStudents) {
      yield* _mapFilterStudentsToState(event);
    } else if (event is LoadLocalClasses) {
      yield* _mapLoadLocalClassToState();
    } else if (event is Synchronize) {
      yield* _mapSynchronizeClassToState(event);
    } else if (event is UpdateConnectionStatus) {
      yield* _mapConnectionStatusToState(event);
    }
  }

  Stream<DashboardState> _mapClassLoadedToState() async* {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Token token = await _tokenDao.getToken();
        final classes =
            await _classRepository.loadOfflineClasses(token: token.accessToken);
        if (classes.length > 0) {
          await _classDao.insertMany(classes);
          await Future.delayed(const Duration(milliseconds: 300));
          if (kIsWeb) {
            final PaidYears newYear = await _selectedYearDao.getYear();
            newYear.updatedAt = new DateTime.now().millisecondsSinceEpoch;
            await _yearDao.update(newYear);
            await _selectedYearDao.update(newYear);
          }
          yield* _reloadClasses(sortBySelectedClass: true);
        } else {
          //await _classDao.deleteAll();
          final years = await _yearDao.getYears();
          yield DashboardHasNoConfig(years);
        }
      } else {
        yield* _reloadClasses();
      }
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapUpdateClassToState(UpdateClass event) async* {
    try {
      final Class oldClass = event.oldClass;
      final Class newClass = event.newClass;
      oldClass.hasActiveObservation = false;
      oldClass.selectedTopicId = null;
      oldClass.selectedControlId = null;
      oldClass.observation = null;
      await _classDao.update(oldClass);
      newClass.updatedAt = new DateTime.now().millisecondsSinceEpoch;
      await _classDao.update(newClass);
      yield* _reloadClasses(setSelectedClass: true);
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapLoadYearsToState() async* {
    try {
      Token token = await _tokenDao.getToken();

      final List<PaidYears> years =
          await _payementRepository.getYears(token: token.accessToken);

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        if (years.length > 0) {
          await _yearDao.insertMany(years);
          await _selectedYearDao.update(years.first);

          //yield DashboardLoadClassSuccess(years: years);

          yield* _mapClassLoadedToState();
        } else {
          yield DashboardHasNoConfig();
        }
      } else {
        if (kIsWeb) {
          yield DashboardFailure();
        } else {
          await _yearDao.insertMany(years);
          await _selectedYearDao.update(years.first);
          yield* _reloadClasses();
        }
      }
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapUpdateYearToState(UpdateYear event) async* {
    try {
      final PaidYears newYear = event.year;
      newYear.updatedAt = new DateTime.now().millisecondsSinceEpoch;
      await _yearDao.update(newYear);
      await _selectedYearDao.update(newYear);
      yield* _reloadClasses(setSelectedClass: true);
    } catch (_) {
      yield DashboardFailure();
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

  Stream<DashboardState> _reloadClasses(
      {bool setSelectedClass = false,
      bool sortBySelectedClass = false}) async* {
    try {
      final List<PaidYears> years = await _yearDao.getYears();
      final PaidYears selectedYear = await _selectedYearDao.getYear();

      List<Class> classes = await _classDao.getClasses(
          selectedYear.name != null ? selectedYear.name : _yearDefault);

      if (classes.isEmpty) {
        yield DashboardHasNoConfig(years);
      } else {
        if (setSelectedClass) {
          await _selectedClassDao.update(classes.first);
        }
        if (sortBySelectedClass) {
          final Class selectedClass = await _selectedClassDao.getClass();
          if (selectedClass != null) {
            classes = rearrange(classes, selectedClass);
          } else {
            await _selectedClassDao.update(classes.first);
          }
        }
        yield DashboardLoadClassSuccess(years: years, classes: classes);
      }
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapLoadControlsToState(LoadControls event) async* {
    try {
      // yield DashboardLoadControlsInProgress();
      final String classId = event.classId;
      final String topicId = event.topicId;
      Class cls = await _classDao.getClass(classId);
      cls.selectedTopicId = topicId;
      cls.selectedControlId = null;
      cls.hasActiveObservation = false;
      cls.observation = null;
      cls.updatedAt = new DateTime.now().millisecondsSinceEpoch;
      await _classDao.update(cls);
      yield* _reloadClasses();
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapUpdateTopicsToState(
      UpdateTopicsClass event) async* {
    try {
      Class cls = event.cls;
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Token token = await _tokenDao.getToken();
        await _classRepository.updateTopics(token: token.accessToken, cls: cls);
      } else {
        cls.synchronize = true;
        cls.topicsIsUpdated = true;
      }
      cls.updatedAt = new DateTime.now().millisecondsSinceEpoch;
      cls.selectedTopicId = null;
      cls.selectedControlId = null;
      cls.hasActiveObservation = false;
      cls.observation = null;
      await _classDao.update(cls);
      yield* _reloadClasses();
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapLoadStudentsToState(Class cls) async* {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Token token = await _tokenDao.getToken();
        List<Student> students = await _classRepository.getStudents(
            token: token.accessToken, classId: cls.id);
        await _selectedClassDao.update(cls);
        cls.updatedAt = new DateTime.now().millisecondsSinceEpoch;
        cls.students = students;
        await _classDao.update(cls);
      }
      yield* _reloadClasses();
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapLoadObservationToState(
      LoadObservation event) async* {
    try {
      String classId = event.classId;
      String topicId = event.topicId;
      String controlId = event.controlId;
      final bool selected = event.selected;
      Class cls = await _classDao.getClass(classId);
      if (selected) {
        Observation observation = cls.observations.firstWhere(
            (e) =>
                e.classId == classId &&
                (e.topicId == topicId || e.topicName == topicId) &&
                (e.controlId == controlId || e.controlName == controlId) &&
                e.completed == false &&
                e.isDeleted == false &&
                e.type == 'STRUCTURED',
            orElse: () => null);
        cls.selectedControlId = controlId;
        cls.hasActiveObservation = observation != null;
        cls.observation = observation;
      } else {
        cls.selectedControlId = null;
        cls.hasActiveObservation = false;
        cls.observation = null;
      }

      cls.selectedTopicId = topicId;
      cls.updatedAt = new DateTime.now().millisecondsSinceEpoch;

      await _classDao.update(cls);
      yield* _reloadClasses();
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapCreateStructuredObservationToState(
      CreateStructureObservation event) async* {
    try {
      String classId = event.classId;
      String topicId = event.topicId;
      String controlId = event.controlId;
      final String name = event.name;
      Class cls = await _classDao.getClass(classId);
      Topic topic =
          cls.topics.firstWhere((e) => e.id == topicId || e.name == topicId);
      Control ctrl = topic.controls
          .firstWhere((e) => e.id == controlId || e.controlName == controlId);
      Observation observation;
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Token token = await _tokenDao.getToken();
        observation = await _classRepository.createStructuredObservation(
          token: token.accessToken,
          classId: classId,
          topicId: topicId,
          controlId: controlId,
          name: name,
        );
      } else {
        observation = new Observation(
            classId: classId,
            topicId: topic.id,
            topicName: topic.name,
            controlId: ctrl.id,
            controlName: ctrl.controlName,
            type: 'STRUCTURED',
            title: name,
            synchronize: true);
        cls.synchronize = true;
      }
      cls.observations.add(observation);
      observation.ratings = cls.students.map((Student student) {
        return new ObservationRating(
            studentId: student.id,
            firstName: student.firstName,
            lastName: student.lastName,
            rating: 0,
            picture: student.picture,
            isFavorite: false);
      }).toList();

      cls.hasActiveObservation = true;
      cls.observation = observation;
      ctrl.hasActiveObservation = true;
      cls.updatedAt = new DateTime.now().millisecondsSinceEpoch;
      await _classDao.update(cls);
      yield* _reloadClasses();
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapEditObservationToState(
      EditObservationName event) async* {
    try {
      final Class cls = event.cls;
      final Observation observation = event.observation;
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final Token token = await _tokenDao.getToken();
        await _classRepository.editObservationName(
            token: token.accessToken,
            observationId: observation.id,
            name: observation.title);
      } else {
        cls.synchronize = true;
        observation.synchronize = true;
      }
      cls.observation = observation;
      final int idx = cls.observations.indexWhere((e) =>
          e.classId == cls.id &&
          (e.topicId == cls.selectedTopicId ||
              e.topicName == cls.selectedTopicId) &&
          (e.controlId == cls.selectedControlId ||
              e.controlName == cls.selectedControlId) &&
          e.completed == false &&
          e.isDeleted == false &&
          e.type == 'STRUCTURED');
      if (idx > -1) {
        cls.observations[idx] = observation;
      }
      cls.updatedAt = new DateTime.now().millisecondsSinceEpoch;
      await _classDao.update(cls);
      yield* _reloadClasses();
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapCompleteObservationToState(
      CompleteObservation event) async* {
    try {
      final Class cls = event.cls;
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final Token token = await _tokenDao.getToken();
        await _classRepository.completeObservation(
          token: token.accessToken,
          observationId: cls.observation.id,
        );
        final int idx = cls.observations.indexWhere((e) =>
            e.classId == cls.id &&
            e.topicId == cls.selectedTopicId &&
            e.controlId == cls.selectedControlId &&
            e.completed == false &&
            e.isDeleted == false &&
            e.type == 'STRUCTURED');
        if (idx > -1) {
          cls.observations.removeAt(idx);
        }
      } else {
        final int idx = cls.observations.indexWhere((e) =>
            e.classId == cls.id &&
            (e.topicId == cls.selectedTopicId ||
                e.topicName == cls.selectedTopicId) &&
            (e.controlId == cls.selectedControlId ||
                e.controlName == cls.selectedControlId) &&
            e.completed == false &&
            e.isDeleted == false &&
            e.type == 'STRUCTURED');
        if (idx > -1) {
          cls.observations[idx].completed = true;
          cls.observations[idx].synchronize = true;
          cls.synchronize = true;
        }
      }

      Topic topic = cls.topics.firstWhere(
          (e) => e.id == cls.selectedTopicId || e.name == cls.selectedTopicId);
      Control ctrl = topic.controls.firstWhere((e) =>
          e.id == cls.selectedControlId ||
          e.controlName == cls.selectedControlId);
      ctrl.hasActiveObservation = false;
      cls.hasActiveObservation = false;
      cls.observation = null;
      cls.updatedAt = new DateTime.now().millisecondsSinceEpoch;
      await _classDao.update(cls);
      yield* _mapLoadStudentsToState(cls);
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapDeleteObservationToState(
      DeleteObservation event) async* {
    try {
      final Class cls = event.cls;
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final Token token = await _tokenDao.getToken();
        await _classRepository.deleteObservation(
          token: token.accessToken,
          observationId: cls.observation.id,
        );
        final int idx =
            cls.observations.indexWhere((e) => e.id == cls.observation.id);
        if (idx > -1) {
          cls.observations.removeAt(idx);
        }
      } else {
        int idx = cls.observations.indexWhere((e) =>
            e.classId == cls.id &&
            (e.topicId == cls.selectedTopicId ||
                e.topicName == cls.selectedTopicId) &&
            (e.controlId == cls.selectedControlId ||
                e.controlName == cls.selectedControlId) &&
            e.completed == false &&
            e.isDeleted == false &&
            e.type == 'STRUCTURED');
        if (idx > -1) {
          final Observation observation = cls.observations.elementAt(idx);
          if (observation.id != null) {
            cls.synchronize = true;
            observation.isDeleted = true;
            observation.synchronize = true;
            cls.observations[idx] = observation;
          } else {
            cls.observations.removeAt(idx);
          }
        }
      }

      Topic topic = cls.topics.firstWhere(
          (e) => e.id == cls.selectedTopicId || e.name == cls.selectedTopicId);
      Control control = topic.controls.firstWhere((e) =>
          e.id == cls.selectedControlId ||
          e.controlName == cls.selectedControlId);
      control.hasActiveObservation = false;
      cls.hasActiveObservation = false;
      cls.selectedTopicId = null;
      cls.selectedControlId = null;
      cls.observation = null;
      cls.updatedAt = new DateTime.now().millisecondsSinceEpoch;
      await _classDao.update(cls);
      yield* _mapLoadStudentsToState(cls);
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapUpdateRatingToState(UpdateRating event) async* {
    try {
      final String classId = event.classId;
      final String observationId = event.observationId;
      final String studentId = event.studentId;
      final int rating = event.rating;
      Class cls = await _classDao.getClass(classId);
      final ObservationRating observationRt =
          cls.observation.ratings.firstWhere((r) => r.studentId == studentId);

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final Token token = await _tokenDao.getToken();
        await _classRepository.updateRating(
            token: token.accessToken,
            observationId: observationId,
            studentId: studentId,
            rating: rating);

        observationRt.rating = rating;
      } else {
        cls.synchronize = true;
        cls.observation.synchronize = true;
        final Student student =
            cls.students.firstWhere((r) => r.id == studentId);
        if (observationRt.rating == 0 && rating > 0) {
          student.observation += 1;
        } else if (rating == 0) {
          student.observation -= 1;
        }
        observationRt.rating = rating;
      }
      final int idx = cls.observations.indexWhere((e) =>
          e.classId == classId &&
          (e.topicId == cls.selectedTopicId ||
              e.topicName == cls.selectedTopicId) &&
          (e.controlId == cls.selectedControlId ||
              e.controlName == cls.selectedControlId) &&
          e.completed == false &&
          e.isDeleted == false &&
          e.type == 'STRUCTURED');
      if (idx > -1) {
        cls.observations[idx] = cls.observation;
      }
      cls.updatedAt = new DateTime.now().millisecondsSinceEpoch;
      await _classDao.update(cls);
      yield* _reloadClasses();
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapUpdateFavoriteToState(
      UpdateFavorite event) async* {
    try {
      final String classId = event.classId;
      final String observationId = event.observationId;
      final String studentId = event.studentId;
      final bool isFavorite = event.isFavorite;

      Class cls = await _classDao.getClass(classId);
      ObservationRating rating =
          cls.observation.ratings.firstWhere((r) => r.studentId == studentId);
      rating.isFavorite = isFavorite;
      cls.observation.ratings.sort((a, b) {
        if (b.isFavorite) {
          return 1;
        }
        return -1;
      });

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        final Token token = await _tokenDao.getToken();
        await _classRepository.updateFavorite(
            token: token.accessToken,
            observationId: observationId,
            studentId: studentId,
            isFavorite: isFavorite);
      } else {
        cls.synchronize = true;
        cls.observation.synchronize = true;
      }

      final int idx = cls.observations.indexWhere((e) =>
          e.classId == classId &&
          (e.topicId == cls.selectedTopicId ||
              e.topicName == cls.selectedTopicId) &&
          (e.controlId == cls.selectedControlId ||
              e.controlName == cls.selectedControlId) &&
          e.completed == false &&
          e.isDeleted == false &&
          e.type == 'STRUCTURED');
      if (idx > -1) {
        cls.observations[idx] = cls.observation;
      }
      cls.updatedAt = new DateTime.now().millisecondsSinceEpoch;
      await _classDao.update(cls);
      yield* _reloadClasses();
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapFilterStudentsToState(
      FilterStudents event) async* {
    try {
      Class cls = event.cls;
      final String text = event.text.toLowerCase();
      if (text.isEmpty) {
        yield* _reloadClasses();
      } else {
        final List<PaidYears> years = await _yearDao.getYears();
        final PaidYears selectedYear = await _selectedYearDao.getYear();
        final List<Class> classes = await _classDao.getClasses(
            selectedYear.name != null ? selectedYear.name : _yearDefault);
        if (cls.hasActiveObservation) {
          cls.observation.ratings = classes[0].observation.ratings.where((r) {
            return r.name.toLowerCase().contains(text);
          }).toList();
          classes[0].observation = cls.observation;
        } else {
          cls.students = classes[0].students.where((s) {
            return s.name.toLowerCase().contains(text);
          }).toList();
          classes[0].students = cls.students;
        }
        yield DashboardLoadClassSuccess(years: years, classes: classes);
      }
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapLoadLocalClassToState() async* {
    try {
      yield* _reloadClasses();
    } catch (_) {
      yield DashboardFailure();
    }
  }

  Stream<DashboardState> _mapSynchronizeClassToState(Synchronize event) async* {
    try {
      _synchronizeSingleton.startSynchronize();
      final List<Class> classes = await _classDao.getClassesToSync();
      if (classes.length > 0) {
        yield SynchronizeStart();
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult != ConnectivityResult.none) {
          Token token = await _tokenDao.getToken();
          await _classRepository.synchronizeClasses(
              classes: classes, token: token.accessToken);
          await Future.delayed(const Duration(milliseconds: 300));
          final newClasses = await this
              ._classRepository
              .loadOfflineClasses(token: token.accessToken);
          await _classDao.insertMany(newClasses);
          await Future.delayed(const Duration(milliseconds: 300));
          _synchronizeSingleton.finishSynchronize();
          yield* _reloadClasses(setSelectedClass: true);
        }
        // yield SynchronizeEnd();
      }
      _synchronizeSingleton.finishSynchronize();
    } catch (_) {
      if (_.message != 'ANOTHER_SYNC_IS_IN_PROGRESS') {
        yield SynchronizeError();
      }
      _synchronizeSingleton.finishSynchronize();
    }
  }

  Stream<DashboardState> _mapConnectionStatusToState(
      UpdateConnectionStatus event) async* {
    try {
      final bool isOnline = event.isOnline;
      yield ConnectionStatus(isOnline);
    } catch (_) {
      yield DashboardFailure();
    }
  }
}
