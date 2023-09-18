part of 'bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUser extends UserEvent {}

class UserAdded extends UserEvent {
  final User user;

  const UserAdded(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'UserAdded { user: $user }';
}
