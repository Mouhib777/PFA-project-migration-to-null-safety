part of 'bloc.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object> get props => [];
}

class ReportLoadInProgress extends ReportState {}

class ReportFailure extends ReportState {}

class ReportAddFailure extends ReportState {}

class ReportAddSucces extends ReportState {}

class ReportEditSucces extends ReportState {}

class ReportDeleteSucces extends ReportState {}

class ReportUpdatePictureSucces extends ReportState {}

class ReportDeletePictureSucces extends ReportState {}

class ReportUpdatePictureError extends ReportState {}

class ReportDeletePictureError extends ReportState {}

class ReportLoadSuccess extends ReportState {
  final String selectedYear;
  final List<Class> classes;
  final List<PupilsModel> listPeoples;
  final List<PuplisReport> listReports;

  final bool visibility;
  final int position;
  final List<String> filteredTopics;

  const ReportLoadSuccess(
      {this.selectedYear,
      this.classes,
      this.listPeoples,
      this.listReports,
      this.visibility,
      this.position,
      this.filteredTopics});

  @override
  List<Object> get props => [
        {
          selectedYear,
          classes,
          listPeoples,
          listReports,
          visibility,
          position,
          filteredTopics
        }
      ];

  @override
  String toString() => 'ClassLoadSuccess { Class: $listPeoples }';
}

class ReportStudentLoadSuccess extends ReportState {
  final List<PuplisReport> listPeoples;

  const ReportStudentLoadSuccess({
    this.listPeoples,
  });

  @override
  List<Object> get props => [listPeoples];

  @override
  String toString() => 'ClassLoadSuccess { Class: $listPeoples }';
}

class ReportFilterLoadSuccess extends ReportState {
  final List<Observation> listReport;

  const ReportFilterLoadSuccess(
    this.listReport,
  );

  @override
  List<Object> get props => [
        {listReport}
      ];

  @override
  String toString() => 'ClassLoadSuccess { Class: $listReport }';
}
