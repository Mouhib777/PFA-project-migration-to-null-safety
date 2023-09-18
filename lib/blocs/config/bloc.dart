import 'package:bloc/bloc.dart';
import 'package:docu_diary/db/dao/dao.dart';
import 'package:docu_diary/models/models.dart';
import 'package:docu_diary/utils/synchronize_singleton.dart';
import 'package:equatable/equatable.dart';
import 'package:docu_diary/repositories/repositories.dart';
import 'package:connectivity/connectivity.dart';
part 'event.dart';
part 'state.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  final ClassDao _classDao = ClassDao();
  final TokenDao _tokenDao = TokenDao();
  final UserDao _userDao = UserDao();
  final ClassRepository _classRepository = ClassRepository();
  final SelectedClassDao _selectedClassDao = SelectedClassDao();
  final SynchronizeSingleton _synchronizeSingleton = SynchronizeSingleton();
  final SelectedYearsDao _selectedYearDao = SelectedYearsDao();
  ConfigBloc() : super(ConfigLoadInProgress());
  final _yearDefault = '2021/2022';

  @override
  Stream<ConfigState> mapEventToState(ConfigEvent event) async* {
    if (event is LoadClasses) {
      yield* _mapClassLoadedToState();
    } else if (event is AddClass) {
      yield* _mapAddClassToState(event);
    } else if (event is DeleteClass) {
      yield* _mapDeleteClassToState(event);
    } else if (event is LoadTopics) {
      yield* _mapLoadTopicsToState(event);
    } else if (event is AddTopic) {
      yield* _mapAddTopicToState(event);
    } else if (event is DeleteTopic) {
      yield* _mapDeleteTopicToState(event);
    } else if (event is UpdateTopicName) {
      yield* _mapUpdateTopicNameToState(event);
    } else if (event is UpdateTopicColor) {
      yield* _mapUpdateTopicColorToState(event);
    } else if (event is SortTopics) {
      yield* _mapSortTopicsToState(event);
    } else if (event is UpdateControls) {
      yield* _mapUpdateControlsToState(event);
    } else if (event is UpdateClassName) {
      yield* _mapUpdateClassNameToState(event);
    } else if (event is Synchronize) {
      yield* _mapSynchronizeClassToState(event);
    } else if (event is UpdateConnectionStatus) {
      yield* _mapConnectionStatusToState(event);
    }
  }

  Stream<ConfigState> _reloadClasses() async* {
    try {
      final PaidYears selectedYear = await _selectedYearDao.getYear();

      final List<Class> classes = await _classDao.getClasses(
          selectedYear.name != null ? selectedYear.name : _yearDefault);
      yield ConfigLoadClassSuccess(classes);
    } catch (_) {
      yield ConfigFailure();
    }
  }

  Stream<ConfigState> _mapClassLoadedToState() async* {
    try {
      yield* _reloadClasses();
    } catch (_) {
      yield ConfigFailure();
    }
  }

  Stream<ConfigState> _mapAddClassToState(AddClass event) async* {
    try {
      final className = event.name;
      final PaidYears selectedYear = await _selectedYearDao.getYear();

      final Class cls = await _classDao.getClassByName(
          schoolYear:
              selectedYear.name != null ? selectedYear.name : _yearDefault,
          className: className);
      if (cls != null) {
        return;
      }
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Token token = await _tokenDao.getToken();
        final Class addedClass = await _classRepository.addClass(
            className: className,
            token: token.accessToken,
            schoolYear:
                selectedYear.name != null ? selectedYear.name : _yearDefault);
        await _classDao.insert(addedClass);
      } else {
        User user = await _userDao.getUser();
        final Class offlineClass = new Class(
            teacherId: user.id,
            className: className,
            synchronize: true,
            schoolYear:
                selectedYear.name != null ? selectedYear.name : _yearDefault);
        offlineClass.updatedAt = new DateTime.now().millisecondsSinceEpoch;
        final Class onlineClass = await _classDao.findOnlineClass(
            selectedYear.name != null ? selectedYear.name : _yearDefault);
        if (onlineClass != null) {
          onlineClass.topics.forEach((tp) => {
                tp.controls.forEach((ct) => {
                      ct.hasActiveObservation = false,
                    })
              });
          offlineClass.topics = onlineClass.topics;
        }
        await _classDao.insert(offlineClass);
      }
      yield* _reloadClasses();
    } catch (_) {
      yield ConfigFailure();
    }
  }

  Stream<ConfigState> _mapDeleteClassToState(DeleteClass event) async* {
    try {
      final cls = event.cls;
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Token token = await _tokenDao.getToken();
        await _classRepository.deleteClass(
            classId: cls.id, token: token.accessToken);
        await _classDao.delete(cls);
      } else if (cls.synchronize) {
        await _classDao.delete(cls);
      } else {
        cls.synchronize = true;
        cls.isDeleted = true;
        await _classDao.update(cls);
      }
      yield* _reloadClasses();
    } catch (_) {
      yield ConfigFailure();
    }
  }

  Stream<ConfigState> _reloadClass() async* {
    try {
      final PaidYears selectedYear = await _selectedYearDao.getYear();
      final Class cls = await _classDao.findFirst(selectedYear.name);
      if (cls != null) {
        cls.topics.sort((prev, next) =>
            int.parse(prev.order).compareTo(int.parse(next.order)));
      }
      yield ConfigLoadTopicsSuccess(cls);
    } catch (_) {
      yield ConfigFailure();
    }
  }

  Stream<ConfigState> _mapLoadTopicsToState(LoadTopics event) async* {
    try {
      yield* _reloadClass();
    } catch (_) {
      yield ConfigFailure();
    }
  }

  Stream<ConfigState> _mapAddTopicToState(AddTopic event) async* {
    try {
      String topicName = event.name;
      Topic topic;
      final PaidYears selectedYear = await _selectedYearDao.getYear();
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Token token = await _tokenDao.getToken();
        topic = await _classRepository.addTopic(
            topicName: topicName,
            token: token.accessToken,
            schoolYear:
                selectedYear.name != null ? selectedYear.name : _yearDefault);
      } else {
        Class cls = await _classDao.findFirst(
            selectedYear.name != null ? selectedYear.name : _yearDefault);
        final String order =
            cls != null ? (cls.topics.length + 1).toString() : '1';
        topic = new Topic(name: topicName, order: order);
      }
      final List<Class> classes = await _classDao.getClasses(
          selectedYear.name != null ? selectedYear.name : _yearDefault);

      classes.forEach((Class cls) {
        cls.topics.add(topic);
        cls.synchronize = true;
        cls.topicsIsUpdated = true;
      });
      await _classDao.insertMany(classes);
      await Future.delayed(const Duration(milliseconds: 100));
      yield* _reloadClass();
    } catch (_) {
      yield ConfigFailure();
    }
  }

  Stream<ConfigState> _mapDeleteTopicToState(DeleteTopic event) async* {
    try {
      final Topic topic = event.topic;
      final PaidYears selectedYear = await _selectedYearDao.getYear();
      final List<Class> classes = await _classDao.getClasses(
          selectedYear.name != null ? selectedYear.name : _yearDefault);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Token token = await _tokenDao.getToken();

        await _classRepository.deleteTopic(
            name: topic.name,
            token: token.accessToken,
            schoolYear:
                selectedYear.name != null ? selectedYear.name : _yearDefault);

        classes.forEach((Class cls) {
          cls.topics = cls.topics.where((e) => e.name != topic.name).toList();
        });
      } else {
        classes.forEach((Class cls) {
          cls.synchronize = true;
          cls.topicsIsUpdated = true;
          cls.topics = cls.topics.where((e) => e.name != topic.name).toList();
          if (topic.id != null && topic.id == cls.selectedTopicId) {
            cls.hasActiveObservation = false;
            cls.selectedTopicId = null;
            cls.selectedControlId = null;
            cls.observation = null;
          }
        });
      }
      await _classDao.insertMany(classes);
      await Future.delayed(const Duration(milliseconds: 100));
      yield* _reloadClass();
    } catch (_) {
      yield ConfigFailure();
    }
  }

  Stream<ConfigState> _mapUpdateTopicNameToState(UpdateTopicName event) async* {
    try {
      final Topic topic = event.topic;
      final String topicName = event.name;
      final PaidYears selectedYear = await _selectedYearDao.getYear();
      final List<Class> classes = await _classDao.getClasses(
          selectedYear.name != null ? selectedYear.name : _yearDefault);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Token token = await _tokenDao.getToken();
        await _classRepository.updateTopicName(
            oldName: topic.name,
            newName: topicName,
            token: token.accessToken,
            schoolYear:
                selectedYear.name != null ? selectedYear.name : _yearDefault);

        classes.forEach((Class cls) {
          final int idx = cls.topics.indexWhere((e) => e.name == topic.name);
          if (idx > -1) {
            cls.topics[idx].name = topicName;
          }
        });
      } else {
        classes.forEach((Class cls) {
          cls.synchronize = true;
          cls.topicsIsUpdated = true;
          final int idx = cls.topics.indexWhere((e) => e.name == topic.name);
          if (idx > -1) {
            cls.topics[idx].name = topicName;
          }
        });
      }
      await _classDao.insertMany(classes);
      await Future.delayed(const Duration(milliseconds: 100));
      yield* _reloadClass();
    } catch (_) {
      yield ConfigFailure();
    }
  }

  Stream<ConfigState> _mapUpdateTopicColorToState(
      UpdateTopicColor event) async* {
    try {
      final Topic topic = event.topic;
      final String topicColor = event.color;
      final PaidYears selectedYear = await _selectedYearDao.getYear();
      final List<Class> classes = await _classDao.getClasses(
          selectedYear.name != null ? selectedYear.name : _yearDefault);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Token token = await _tokenDao.getToken();
        await _classRepository.updateTopicColor(
            topicId: topic.id,
            topicColor: topicColor,
            token: token.accessToken);
        classes.forEach((Class cls) {
          final int idx = cls.topics.indexWhere((e) => e.name == topic.name);
          if (idx > -1) {
            cls.topics[idx].color = topicColor;
          }
        });
      } else {
        classes.forEach((Class cls) {
          cls.synchronize = true;
          cls.topicsIsUpdated = true;
          final int idx = cls.topics.indexWhere((e) => e.name == topic.name);
          if (idx > -1) {
            cls.topics[idx].color = topicColor;
          }
        });
      }
      await _classDao.insertMany(classes);
      await Future.delayed(const Duration(milliseconds: 100));
      yield* _reloadClass();
    } catch (_) {
      yield ConfigFailure();
    }
  }

  Stream<ConfigState> _mapSortTopicsToState(SortTopics event) async* {
    try {
      final List<Topic> topics = event.topics;

      final PaidYears selectedYear = await _selectedYearDao.getYear();
      final List<Class> classes = await _classDao.getClasses(
          selectedYear.name != null ? selectedYear.name : _yearDefault);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Token token = await _tokenDao.getToken();

        await _classRepository.sortTopics(
            topics: topics,
            token: token.accessToken,
            schoolYear:
                selectedYear.name != null ? selectedYear.name : _yearDefault);

        classes.forEach((Class cls) {
          for (var i = 0; i < topics.length; i++) {
            final Topic topic =
                cls.topics.firstWhere((e) => e.name == topics[i].name);
            if (topic != null) {
              topic.order = '${i + 1}';
            }
          }
          cls.topics.sort((prev, next) =>
              int.parse(prev.order).compareTo(int.parse(next.order)));
        });
      } else {
        classes.forEach((Class cls) {
          cls.synchronize = true;
          cls.topicsIsUpdated = true;
          for (var i = 0; i < topics.length; i++) {
            final Topic topic =
                cls.topics.firstWhere((e) => e.name == topics[i].name);
            if (topic != null) {
              topic.order = '${i + 1}';
            }
          }
          cls.topics.sort((prev, next) =>
              int.parse(prev.order).compareTo(int.parse(next.order)));
        });
      }

      await _classDao.insertMany(classes);
      await Future.delayed(const Duration(milliseconds: 100));
      yield* _reloadClass();
    } catch (_) {
      yield ConfigFailure();
    }
  }

  Stream<ConfigState> _mapUpdateControlsToState(UpdateControls event) async* {
    try {
      final Topic topic = event.topic;
      final PaidYears selectedYear = await _selectedYearDao.getYear();
      final List<Class> classes = await _classDao.getClasses(
          selectedYear.name != null ? selectedYear.name : _yearDefault);
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Token token = await _tokenDao.getToken();

        await _classRepository.updateControls(
            topic: topic, token: token.accessToken);
        classes.forEach((Class cls) {
          final int tpIdx = cls.topics.indexWhere((e) => e.name == topic.name);
          if (tpIdx > -1) {
            cls.topics[tpIdx] = topic;
          }
        });
      } else {
        classes.forEach((Class cls) {
          cls.synchronize = true;
          cls.topicsIsUpdated = true;
          final int tpIdx = cls.topics.indexWhere((e) => e.name == topic.name);
          if (tpIdx > -1) {
            cls.topics[tpIdx] = topic;
          }
        });
      }
      await _classDao.insertMany(classes);
      await Future.delayed(const Duration(milliseconds: 100));
      yield* _reloadClass();
    } catch (_) {
      yield ConfigFailure();
    }
  }

  Stream<ConfigState> _mapUpdateClassNameToState(UpdateClassName event) async* {
    try {
      final Class cls = event.cls;
      final String className = event.name;

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        Token token = await _tokenDao.getToken();
        await _classRepository.updateClassName(
            classId: cls.id, className: className, token: token.accessToken);
      } else {
        cls.synchronize = true;
        // cls.isDeleted = true;
        // final Class offlineClass = Class.fromJson(cls.toJson());
        // offlineClass.id = null;
        // offlineClass.className = className;
        // offlineClass.isDeleted = false;
        // offlineClass.updatedAt = new DateTime.now().millisecondsSinceEpoch;
        // User user = await _userDao.getUser();
        // final PaidYears selectedYear = await _selectedYearDao.getYear();
        // final Class offlineClass = new Class(
        //     teacherId: user.id,
        //     className: className,
        //     synchronize: true,
        //     schoolYear: selectedYear.name != null ? selectedYear.name : _yearDefault);
        // offlineClass.updatedAt = new DateTime.now().millisecondsSinceEpoch;
        // final Class onlineClass =
        //     await _classDao.findOnlineClass(selectedYear.name != null ? selectedYear.name : _yearDefault);
        // if (onlineClass != null) {
        //   onlineClass.topics.forEach((tp) => {
        //         tp.controls.forEach((ct) => {
        //               ct.hasActiveObservation = false,
        //             })
        //       });
        //   offlineClass.topics = onlineClass.topics;
        // }
        // await _classDao.insert(offlineClass);
      }
      cls.className = className;
      await _classDao.update(cls);
      yield* _reloadClasses();
    } catch (_) {
      yield ConfigFailure();
    }
  }

  Stream<ConfigState> _mapSynchronizeClassToState(Synchronize event) async* {
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
          await _selectedClassDao.update(newClasses.first);
          await Future.delayed(const Duration(milliseconds: 300));
          _synchronizeSingleton.finishSynchronize();
          yield* _reloadClasses();
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

  Stream<ConfigState> _mapConnectionStatusToState(
      UpdateConnectionStatus event) async* {
    try {
      final bool isOnline = event.isOnline;
      yield ConnectionStatus(isOnline);
    } catch (_) {
      yield ConfigFailure();
    }
  }
}
