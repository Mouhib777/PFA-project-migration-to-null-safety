import 'package:bloc/bloc.dart';
import 'package:docu_diary/db/dao/dao.dart';
import 'package:docu_diary/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:docu_diary/repositories/repositories.dart';

import 'dart:async';

part 'event.dart';
part 'state.dart';

class StudentsBloc extends Bloc<StudentsEvent, StudentsState> {
  final TokenDao _tokenDao = TokenDao();
  // final UserDao _userDao = UserDao();
  final SelectedClassDao _selectedClassDao = SelectedClassDao();
  // final SynchronizeSingleton _synchronizeSingleton = SynchronizeSingleton();
  final SelectedYearsDao _selectedYearDao = SelectedYearsDao();
  final PupilesRepository _studentRepository = PupilesRepository();
  final ClassDao _classDao = ClassDao();

  StudentsBloc() : super(StudentsLoadInProgress());

  @override
  Stream<StudentsState> mapEventToState(StudentsEvent event) async* {
    if (event is LoadStudents) {
      yield* _mapStudensLoadedToState(event);
    } else if (event is AddStudent) {
      yield* _mapAddStudentToState(event);
    } else if (event is EditStudent) {
      yield* _mapEditStudentToState(event);
    } else if (event is DeleteStudent) {
      yield* _mapDeleteStudentToState(event);
    } else if (event is GetPicture) {
      yield* _mapGetPictureToState(event);
    } else if (event is UploadPicture) {
      yield* _mapUploadPictureToState(event);
    } else if (event is DeletePicture) {
      yield* _mapDeletePictureToState(event);
    }
  }

  Stream<StudentsState> _mapStudensLoadedToState(LoadStudents event) async* {
    try {
      yield* _reloadStudents(event);
    } catch (_) {
      yield StudentsFailure();
    }
  }

  Stream<StudentsState> _reloadStudents(LoadStudents event) async* {
    try {
      String? studentId = '';
      String? classeName;
      String? classeId;
      var urlPicture = '';
      List selectData = [];

      Token? token = await _tokenDao.getToken();
      var selectyear = await _selectedYearDao.getYear();
      List<Class> classes = await _classDao.getClasses(selectyear!.name!);
      if (classes.isEmpty) {
        yield StudentsClassFailure();
      } else {
        await _selectedClassDao.update(classes.first);

        Class? cls = await _selectedClassDao.getClass();

        var currentYear = selectyear!.name;

        var selectedClassId = cls!.id;
        var selectedClassName = cls.className;
        var userToken = token!.accessToken;

        var response = await _studentRepository.getClasses(
            token: userToken, currentYear: currentYear);

        if (event.argument != null) {
          var item = response.firstWhere((e) => e['_id'] == selectedClassId);
          selectData = [item];
          studentId = event.argument['id'];
        } else {
          selectData = response;
        }
        classeId = classeId == null ? selectedClassId : classeName;
        if (event.argument != null && event.argument['id'] != null) {
          urlPicture = await _studentRepository.getStudentPicture(
              token: userToken, studentId: event.argument['id']);
        }

        yield StudentsLoadClassSuccess(
            selectedYear: currentYear!,
            selectedClassName: selectedClassName!,
            selectData: selectData,
            classeId: classeId!,
            studentId: studentId!,
            urlPicture: urlPicture,
            checked: urlPicture.length > 0 ? true : false);
      }
    } catch (_) {
      yield StudentsFailure();
    }
  }

  Stream<StudentsState> _mapAddStudentToState(AddStudent event) async* {
    try {
      Token? token = await _tokenDao.getToken();
      Class? cls = await _selectedClassDao.getClass();
      var selectyear = await _selectedYearDao.getYear();
      var currentYear = selectyear!.name;

      var selectedClassId = cls!.id;
      var selectedClassName = cls.className;
      var userToken = token!.accessToken;

      Map<String, dynamic> data = {
        'firstName': event.firstName!.trim(),
        'lastName': event.lastName!.trim(),
        'birthdayDate': event.birthdayDate,
        'emergencyNumber': ' ',
        'classId': selectedClassId,
        'className': selectedClassName,
        'schoolYear': currentYear,
        'teacherId': ' '
      };

      await _studentRepository.addPupiles(token: userToken, student: data);
      yield StudentsAddSucces();
    } catch (e) {
      yield StudentsFailure();
    }
  }

  Stream<StudentsState> _mapEditStudentToState(EditStudent event) async* {
    try {
      Token? token = await _tokenDao.getToken();

      var userToken = token!.accessToken;

      Map<String, dynamic> data = {
        'firstName': event.firstName,
        'lastName': event.lastName,
        'birthdayDate': event.birthdayDate
      };

      await _studentRepository.editStudent(
          token: userToken, id: event.id!, student: data);

      yield StudentsEditSucces();
    } catch (_) {
      yield StudentsFailure();
    }
  }

  Stream<StudentsState> _mapDeleteStudentToState(DeleteStudent event) async* {
    try {
      Token? token = await _tokenDao.getToken();

      var userToken = token!.accessToken;

      await _studentRepository.deleteStudent(token: userToken, id: event.id);

      yield StudentsDeleteSucces();
    } catch (_) {
      yield StudentsFailure();
    }
  }

  Stream<StudentsState> _mapGetPictureToState(GetPicture event) async* {
    try {} catch (_) {}
  }

  Stream<StudentsState> _mapUploadPictureToState(UploadPicture event) async* {
    try {
      Token? token = await _tokenDao.getToken();

      var userToken = token!.accessToken;

      await _studentRepository.uploadPicture(
          token: userToken,
          studentId: event.studentId!,
          fileName: event.galleryFile!);
      yield StudentsUpdatePictureSucces();
    } catch (_) {
      yield StudentsUpdatePictureError();
    }
  }

  Stream<StudentsState> _mapDeletePictureToState(DeletePicture event) async* {
    try {
      Token? token = await _tokenDao.getToken();

      var userToken = token!.accessToken;

      await _studentRepository.deleteUserPicture(
          token: userToken, id: event.id);

      yield StudentsDeletePictureSucces();
    } catch (_) {
      yield StudentsDeletePictureError();
    }
  }
}
