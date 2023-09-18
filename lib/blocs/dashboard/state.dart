part of 'bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardLoadInProgress extends DashboardState {}

class DashboardYearsLoadInProgress extends DashboardState {}

class DashboardHasNoConfig extends DashboardState {
  final List<PaidYears> years;
  const DashboardHasNoConfig([this.years = const []]);

  @override
  List<Object> get props => [years];

  @override
  String toString() => 'DashboardHasNoConfig { years: $years }';
}

class DashboardLoadClassSuccess extends DashboardState {
  final List<PaidYears> years;
  final List<Class> classes;

  const DashboardLoadClassSuccess(
      {this.years = const [], this.classes = const []});

  @override
  List<Object> get props => [classes];

  @override
  String toString() => 'ClassLoadSuccess { years: $years, classes: $classes }';
}

class DashboardFailure extends DashboardState {}

class DashboardLoadControlsInProgress extends DashboardState {}

class DashboardLoadStudentsSuccess extends DashboardState {
  final List<Class> classes;

  const DashboardLoadStudentsSuccess([this.classes = const []]);

  @override
  List<Object> get props => [classes];

  @override
  String toString() => 'StudentsLoadSuccess { Class: $classes }';
}

class ConnectionStatus extends DashboardState {
  final bool isConnected;

  const ConnectionStatus(this.isConnected);

  @override
  List<Object> get props => [isConnected];

  @override
  String toString() => 'ConnectionStatus { isOnline: $isConnected }';
}

class SynchronizeStart extends DashboardState {}

class SynchronizeEnd extends DashboardState {}

class SynchronizeError extends DashboardState {}
