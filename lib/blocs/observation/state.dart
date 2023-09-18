part of 'bloc.dart';

abstract class ObservationState extends Equatable {
  const ObservationState();

  @override
  List<Object> get props => [];
}

class ObservationLoadInProgress extends ObservationState {}

class ObservationFailure extends ObservationState {}
