part of 'bloc.dart';

abstract class ObservationsEvent extends Equatable {
  const ObservationsEvent();

  @override
  List<Object> get props => [];
}

class LoadObservations extends ObservationsEvent {}

class UpdateClass extends ObservationsEvent {
  final Class newClass;
  const UpdateClass(this.newClass);

  @override
  List<Object> get props => [newClass];

  @override
  String toString() => 'UpdateClass { : , newClass: $newClass }';
}

class LoadStudent extends ObservationsEvent {
  final String id;
  const LoadStudent({this.id});

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'UpdateClass { oldClass: $id }';
}

class DeleteSpontaneousObservation extends ObservationsEvent {
  final String observationId;
  const DeleteSpontaneousObservation(this.observationId);

  @override
  List<Object> get props => [observationId];

  @override
  String toString() => 'UpdateClass { oldClass: $observationId, newClass: }';
}

class DeleteStructuredObservation extends ObservationsEvent {
  final String observationId;
  final String studentId;
  const DeleteStructuredObservation({this.observationId, this.studentId});

  @override
  List<Object> get props => [observationId, studentId];

  @override
  String toString() =>
      'UpdateClass { oldClass: $observationId, newClass: $studentId }';
}

class FilterObservation extends ObservationsEvent {
  final String text;

  const FilterObservation(this.text);

  @override
  List<Object> get props => [text];

  @override
  String toString() => 'FilterStudents {  text: $text }';
}

class EditObservation extends ObservationsEvent {
  final String id;
  final String title;
  final String classId;
  final String topicId;
  final String controlId;
  final int rating;
  final String studentId;
  final String date;

  const EditObservation(
      {this.id,
      this.title,
      this.classId,
      this.topicId,
      this.controlId,
      this.rating,
      this.studentId,
      this.date});

  @override
  List<Object> get props =>
      [id, title, classId, topicId, controlId, rating, studentId,date];

  @override
  String toString() => 'AddStudent { student: $title }';
}
