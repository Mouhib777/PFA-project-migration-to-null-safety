part of 'bloc.dart';

abstract class StudentsState extends Equatable {
  const StudentsState();

  @override
  List<Object> get props => [];
}

class StudentsLoadInProgress extends StudentsState {}

class StudentsFailure extends StudentsState {}

class StudentsClassFailure extends StudentsState {}

class StudentsAddFailure extends StudentsState {}

class StudentsAddSucces extends StudentsState {}

class StudentsEditSucces extends StudentsState {}

class StudentsDeleteSucces extends StudentsState {}

class StudentsUpdatePictureSucces extends StudentsState {}

class StudentsDeletePictureSucces extends StudentsState {}

class StudentsUpdatePictureError extends StudentsState {}

class StudentsDeletePictureError extends StudentsState {}

class StudentsLoadClassSuccess extends StudentsState {
  final String selectedYear;
  final String selectedClassName;
  final List selectData;
  final String classeId;
  final String studentId;
  final String urlPicture;
  final bool checked;

  const StudentsLoadClassSuccess(
      {this.selectedYear,
      this.selectedClassName,
      this.selectData,
      this.classeId,
      this.studentId,
      this.urlPicture,
      this.checked});

  @override
  List<Object> get props => [
        {
          selectedYear,
          selectedClassName,
          selectData,
          classeId,
          studentId,
          urlPicture,
          checked
        }
      ];

  @override
  String toString() => 'ClassLoadSuccess { Class: $selectedYear }';
}
