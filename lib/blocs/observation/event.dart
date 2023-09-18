part of 'bloc.dart';

abstract class ObservationEvent extends Equatable {
  const ObservationEvent();

  @override
  List<Object> get props => [];
}

class AddSpontaneousObservation extends ObservationEvent {
  final String classId;
  final Topic topic;
  final Control control;
  final String studentId;
  final String title;
  final int rating;

  const AddSpontaneousObservation(this.classId, this.topic, this.control,
      this.studentId, this.title, this.rating);

  @override
  List<Object> get props => [classId, topic, control, studentId, title, rating];

  @override
  String toString() =>
      'AddSpontaneousObservation { classId: $classId, topic: $topic, control: $control, studentId: $studentId, title: $title, rating: $rating }';
}
