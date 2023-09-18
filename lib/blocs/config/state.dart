part of 'bloc.dart';

abstract class ConfigState extends Equatable {
  const ConfigState();

  @override
  List<Object> get props => [];
}

class ConfigLoadInProgress extends ConfigState {}

class ConfigFailure extends ConfigState {}

class ConfigLoadClassSuccess extends ConfigState {
  final List<Class> classes;

  const ConfigLoadClassSuccess([this.classes = const []]);

  @override
  List<Object> get props => [classes];

  @override
  String toString() => 'ClassLoadSuccess { Class: $classes }';
}

class ConfigLoadTopicsSuccess extends ConfigState {
  final Class cls;

  const ConfigLoadTopicsSuccess(this.cls);

  @override
  List<Object> get props => [cls];

  @override
  String toString() => 'TopicsLoadSuccess { Class: $cls }';
}

class ConnectionStatus extends ConfigState {
  final bool isConnected;

  const ConnectionStatus(this.isConnected);

  @override
  List<Object> get props => [isConnected];

  @override
  String toString() => 'ConnectionStatus { isOnline: $isConnected }';
}

class SynchronizeStart extends ConfigState {}

class SynchronizeEnd extends ConfigState {}

class SynchronizeError extends ConfigState {}
