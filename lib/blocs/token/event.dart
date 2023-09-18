part of 'bloc.dart';

abstract class TokenEvent extends Equatable {
  const TokenEvent();

  @override
  List<Object> get props => [];
}

class LoadToken extends TokenEvent {}

class TokenAdded extends TokenEvent {
  final Token token;

  const TokenAdded(this.token);

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'TokenAdded { token: $token }';
}

class Tokenpdated extends TokenEvent {
  final Token token;

  const Tokenpdated(this.token);

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'TokenUpdated { updatedToken: $token }';
}

class UserLogout extends TokenEvent {}
