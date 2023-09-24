part of 'bloc.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object> get props => [];
}

class LoadReport extends ReportEvent {}

class UpdateClass extends ReportEvent {
  final Class newClass;
  const UpdateClass(this.newClass);

  @override
  List<Object> get props => [newClass];

  @override
  String toString() => 'UpdateClass { : , newClass: $newClass }';
}

class LoadStudent extends ReportEvent {
  final String? id;
  const LoadStudent({this.id});

  @override
  List<Object> get props => [id!];

  @override
  String toString() => 'UpdateClass { oldClass: $id }';
}

class DeleteSpontaneousObservation extends ReportEvent {
  final String observationId;
  const DeleteSpontaneousObservation(this.observationId);

  @override
  List<Object> get props => [observationId];

  @override
  String toString() => 'UpdateClass { oldClass: $observationId, newClass: }';
}

class DeleteStructuredObservation extends ReportEvent {
  final String? observationId;
  final String? studentId;
  const DeleteStructuredObservation({this.observationId, this.studentId});

  @override
  List<Object> get props => [observationId!, studentId!];

  @override
  String toString() =>
      'UpdateClass { oldClass: $observationId, newClass: $studentId }';
}

class FilterObservation extends ReportEvent {
  final String text;

  const FilterObservation(this.text);

  @override
  List<Object> get props => [text];

  @override
  String toString() => 'FilterStudents {  text: $text }';
}

class GetPuplisReport extends ReportEvent {
  final String? studentId;
  final bool? visibility;
  final int? observationNbr;
  final int? index;

  const GetPuplisReport(
      {this.studentId, this.visibility, this.observationNbr, this.index});

  @override
  List<Object> get props => [studentId!, visibility!, observationNbr!, index!];

  @override
  String toString() => 'FilterStudents {  text: $studentId }';
}

class FilterReport extends ReportEvent {
  final String text;

  const FilterReport(this.text);

  @override
  List<Object> get props => [text];

  @override
  String toString() => 'FilterStudents {  text: $text }';
}

class FilterReportByTopics extends ReportEvent {
  final List topics;

  const FilterReportByTopics(this.topics);

  @override
  List<Object> get props => [topics];

  @override
  String toString() => 'FilterStudents {  text: $topics }';
}

class EditObservation extends ReportEvent {
  final String? id;
  final String? title;
  final String? classId;
  final String? topicId;
  final String? controlId;
  final int? rating;
  final String? studentId;

  const EditObservation(
      {this.id,
      this.title,
      this.classId,
      this.topicId,
      this.controlId,
      this.rating,
      this.studentId});

  @override
  List<Object> get props =>
      [id!, title!, classId!, topicId!, controlId!, rating!, studentId!];

  @override
  String toString() => 'AddStudent { student: $title }';
}
