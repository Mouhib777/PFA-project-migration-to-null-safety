part of 'bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserLoadInProgress extends UserState {}

class UserLoadSuccess extends UserState {
  final User user;

  const UserLoadSuccess(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'UserLoadSuccess { User: $user }';
}

class UserLoadFailure extends UserState {}
