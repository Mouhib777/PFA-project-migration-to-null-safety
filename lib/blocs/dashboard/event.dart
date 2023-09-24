part of 'bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadClasses extends DashboardEvent {}

class LoadLocalClasses extends DashboardEvent {}

class UpdateClass extends DashboardEvent {
  final Class? oldClass;
  final Class ?newClass;
  const UpdateClass({this.oldClass, this.newClass});

  @override
  List<Object> get props => [oldClass!, newClass!];

  @override
  String toString() =>
      'UpdateClass { oldClass: $oldClass, newClass: $newClass }';
}

class LoadYears extends DashboardEvent {}

class LoadLocalYears extends DashboardEvent {}

class UpdateYear extends DashboardEvent {
  final PaidYears year;
  const UpdateYear(this.year);

  @override
  List<Object> get props => [ year];

  @override
  String toString() =>
      'UpdateYear { year: $year }';
}

class LoadControls extends DashboardEvent {
  final String? classId;
  final String? topicId;
  final bool? selected;
  const LoadControls({this.classId, this.topicId, this.selected});

  @override
  List<Object> get props => [classId!, topicId!, selected!];

  @override
  String toString() =>
      'LoadControls { classId: $classId, topicId: $topicId, selected: $selected }';
}

class UpdateTopicsClass extends DashboardEvent {
  final Class cls;

  const UpdateTopicsClass(this.cls);

  @override
  List<Object> get props => [cls];

  @override
  String toString() => 'UpdateTopicsClass { class: $cls }';
}

class LoadStudentsClass extends DashboardEvent {
  final Class cls;

  const LoadStudentsClass(this.cls);

  @override
  List<Object> get props => [cls];

  @override
  String toString() => 'LoadStudentsClass { class: $cls }';
}

class LoadObservation extends DashboardEvent {
  final String? classId;
  final String? topicId;
  final String? controlId;
  final bool? selected;

  const LoadObservation(
      {this.classId, this.topicId, this.controlId, this.selected});

  @override
  List<Object> get props => [classId!, topicId!, controlId!, selected!];

  @override
  String toString() =>
      'LoadObservation { classId: $classId, topicId: $topicId, controlId: $controlId, selected: $selected }';
}

class CreateStructureObservation extends DashboardEvent {
  final String? classId;
  final String? topicId;
  final String? controlId;
  final String? name;

  const CreateStructureObservation(
      {this.classId, this.topicId, this.controlId, this.name});

  @override
  List<Object> get props => [classId!, topicId!, controlId!, name!];

  @override
  String toString() =>
      'CreateStructureObservation { classId: $classId, topicId: $topicId, controlId: $controlId, name: $name  }';
}

class EditObservationName extends DashboardEvent {
  final Class? cls;
  final Observation? observation;

  const EditObservationName({this.cls, this.observation});

  @override
  List<Object> get props => [cls!, observation!];

  @override
  String toString() =>
      'EditObservationName { class: $cls, observation: $observation }';
}

class CompleteObservation extends DashboardEvent {
  final Class? cls;

  const CompleteObservation({this.cls});

  @override
  List<Object> get props => [cls!];

  @override
  String toString() => 'CompleteObservation { class: $cls }';
}

class DeleteObservation extends DashboardEvent {
  final Class? cls;

  const DeleteObservation({this.cls});

  @override
  List<Object> get props => [cls!];

  @override
  String toString() => 'DeleteObservation { class: $cls }';
}

class UpdateRating extends DashboardEvent {
  final String? classId;
  final String? observationId;
  final String? studentId;
  final int? rating;

  const UpdateRating(
      {this.classId, this.observationId, this.studentId, this.rating});

  @override
  List<Object> get props => [classId!, observationId!, studentId!, rating!];

  @override
  String toString() =>
      'UpdateRating { classId: $classId, observationId: $observationId, studentId: $studentId, rating: $rating }';
}

class UpdateFavorite extends DashboardEvent {
  final String? classId;
  final String? observationId;
  final String? studentId;
  final bool? isFavorite;

  const UpdateFavorite(
      {this.classId, this.observationId, this.studentId, this.isFavorite});

  @override
  List<Object> get props => [classId!, observationId!, studentId!, isFavorite!];

  @override
  String toString() =>
      'UpdateFavorite {  classId: $classId, observationId: $observationId, studentId: $studentId, isFavorite: $isFavorite }';
}

class FilterStudents extends DashboardEvent {
  final Class? cls;
  final String? text;

  const FilterStudents({this.cls, this.text});

  @override
  List<Object> get props => [cls!, text!];

  @override
  String toString() => 'FilterStudents {  class: $cls, text: $text }';
}

class Synchronize extends DashboardEvent {}

class UpdateConnectionStatus extends DashboardEvent {
  final bool isOnline;
  const UpdateConnectionStatus(this.isOnline);

  @override
  List<Object> get props => [isOnline];

  @override
  String toString() => 'UpdateConnectionStatus { isOnline: $isOnline }';
}
