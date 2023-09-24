part of 'bloc.dart';

abstract class StudentsEvent extends Equatable {
  const StudentsEvent();

  @override
  List<Object> get props => [];
}

class LoadStudents extends StudentsEvent {
  final Map argument;

  const LoadStudents(this.argument);

  @override
  List<Object> get props => [argument];

  @override
  String toString() => 'AddClass { class: $argument }';
}

class AddStudent extends StudentsEvent {
  final String? firstName;
  final String? lastName;
  final String? birthdayDate;
  final String? emergencyNumber;

  const AddStudent(
      {this.firstName, this.lastName, this.birthdayDate, this.emergencyNumber});

  @override
  List<Object> get props =>
      [firstName!, lastName!, birthdayDate!, emergencyNumber!];

  @override
  String toString() => 'AddStudent { student: $firstName }';
}

class EditStudent extends StudentsEvent {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? birthdayDate;
  const EditStudent(
      {this.id, this.firstName, this.lastName, this.birthdayDate});

  @override
  List<Object> get props => [id!, firstName!, lastName!, birthdayDate!];

  @override
  String toString() => 'EditStudent { student: $firstName }';
}

class DeleteStudent extends StudentsEvent {
  final String id;

  const DeleteStudent(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'DeleteStudent { class: $id }';
}

class GetPicture extends StudentsEvent {
  final String name;

  const GetPicture(this.name);

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'GetPicture { class: $name }';
}

class UploadPicture extends StudentsEvent {
  final String? studentId;
  final String? galleryFile;

  const UploadPicture({this.studentId, this.galleryFile});

  @override
  List<Object> get props => [studentId!, galleryFile!];

  @override
  String toString() => 'UploadPicture { class:  }';
}

class DeletePicture extends StudentsEvent {
  final String id;

  const DeletePicture(this.id);

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'DeletePicture { class: $id }';
}
