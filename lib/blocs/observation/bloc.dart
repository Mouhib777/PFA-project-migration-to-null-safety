import 'package:bloc/bloc.dart';
import 'package:docu_diary/connectionStatusSingleton.dart';
import 'package:docu_diary/db/dao/dao.dart';
import 'package:docu_diary/models/models.dart';
import 'package:equatable/equatable.dart';
import 'package:docu_diary/repositories/repositories.dart';
part 'event.dart';
part 'state.dart';

int formatRating(double value) {
  final int intPart = value.floor();
  final double decimalPart = value - intPart;
  return decimalPart > 0.5 ? intPart + 1 : intPart;
}

class ObservationBloc extends Bloc<ObservationEvent, ObservationState> {
  final TokenDao _tokenDao = TokenDao();
  final ClassDao _classDao = ClassDao();
  final ObservationRepository _observationRepository = ObservationRepository();
  final ConnectionStatusSingleton connectionStatus =
      ConnectionStatusSingleton.getInstance();
  ObservationBloc() : super(ObservationLoadInProgress());

  @override
  Stream<ObservationState> mapEventToState(ObservationEvent event) async* {
    if (event is AddSpontaneousObservation) {
      yield* _mapAddSpontaneousObservationToState(event);
    }
  }

  Stream<ObservationState> _mapAddSpontaneousObservationToState(
      AddSpontaneousObservation event) async* {
    try {
      final String classId = event.classId;
      final Topic topic = event.topic;
      final Control control = event.control;
      final String studentId = event.studentId;
      final String title = event.title;
      final int rating = event.rating;
      final bool hasConnection = await connectionStatus.checkConnection();
      if (hasConnection) {
        Token token = await _tokenDao.getToken();
        Map<String, dynamic> data = {
          'classId': classId,
          'topicId': topic.id,
          'controlId': control.id,
          'studentId': studentId,
          'title': title,
          'rating': rating,
        };

        await _observationRepository.sendObservation(
            token: token.accessToken, data: data);
      } else {
        Class cls = await _classDao.getClass(classId);
        Observation observation = new Observation(
            classId: classId,
            topicId: topic.id,
            topicName: topic.name,
            controlId: control.id,
            controlName: control.controlName,
            type: 'SPONTANEOUS',
            title: title,
            completed: true,
            synchronize: true);
        Student student = cls.students.firstWhere((e) => e.id == studentId);
        student.observation += 1;
        if (rating > 0) {
          student.rating = formatRating((student.rating + rating) / 2);
        }
        ObservationRating observationRating = new ObservationRating(
            studentId: student.id,
            firstName: student.firstName,
            lastName: student.lastName,
            rating: rating,
            picture: student.picture,
            isFavorite: false);
        observation.ratings = [observationRating];
        cls.observations.add(observation);
        cls.updatedAt = new DateTime.now().millisecondsSinceEpoch;
        cls.synchronize = true;
        await _classDao.update(cls);
      }
    } catch (_) {
      yield ObservationFailure();
    }
  }
}
