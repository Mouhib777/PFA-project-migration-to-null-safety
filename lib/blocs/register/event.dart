part of 'bloc.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class NameChanged extends RegisterEvent {
  final String name;

  const NameChanged({@required this.name});

  @override
  List<Object> get props => [name];
}

class EmailChanged extends RegisterEvent {
  final String email;

  const EmailChanged({@required this.email});

  @override
  List<Object> get props => [email];
}

class PasswordChanged extends RegisterEvent {
  final String password;

  const PasswordChanged({@required this.password});

  @override
  List<Object> get props => [password];
}

class ConfirmPasswordChanged extends RegisterEvent {
  final String confirmPassword;

  const ConfirmPasswordChanged({@required this.confirmPassword});

  @override
  List<Object> get props => [confirmPassword];
}

class FormSubmitted extends RegisterEvent {}
