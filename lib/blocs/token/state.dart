part of 'bloc.dart';

abstract class TokenState extends Equatable {
  const TokenState();

  @override
  List<Object> get props => [];
}

class TokenLoadInProgress extends TokenState {}

class TokenLoadSuccess extends TokenState {
  final Token token;

  const TokenLoadSuccess({@required this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'TokenLoadSuccess { Token: $token }';
}

class TokenLoadFailure extends TokenState {}
