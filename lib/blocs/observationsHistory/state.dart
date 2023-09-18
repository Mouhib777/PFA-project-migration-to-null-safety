part of 'bloc.dart';

abstract class ObservationsState extends Equatable {
  const ObservationsState();

  @override
  List<Object> get props => [];
}

class ObservationsLoadInProgress extends ObservationsState {}

class ObservationsFailure extends ObservationsState {}

class ObservationsAddFailure extends ObservationsState {}

class ObservationsAddSucces extends ObservationsState {}

class ObservationsEditSucces extends ObservationsState {}

class ObservationsDeleteSucces extends ObservationsState {}

class ObservationsUpdatePictureSucces extends ObservationsState {}

class ObservationsDeletePictureSucces extends ObservationsState {}

class ObservationsUpdatePictureError extends ObservationsState {}

class ObservationsDeletePictureError extends ObservationsState {}

class ObservationsLoadSuccess extends ObservationsState {
  final List<Observation> listObservations;
  final String defaultSelectValue;
  final String selectedYear;
  final List<Class> classes;

  const ObservationsLoadSuccess({
    this.listObservations,
    this.defaultSelectValue,
    this.selectedYear,
    this.classes,
  });

  @override
  List<Object> get props => [
        {
          listObservations,
          defaultSelectValue,
          selectedYear,
          classes,
        }
      ];

  @override
  String toString() => 'ClassLoadSuccess { Class: $listObservations }';
}

class ObservationsFilterLoadSuccess extends ObservationsState {
  final List<Observation> listObservations;

  const ObservationsFilterLoadSuccess(
    this.listObservations,
  );

  @override
  List<Object> get props => [
        {listObservations}
      ];

  @override
  String toString() => 'ClassLoadSuccess { Class: $listObservations }';
}
