part of 'resetPassword_bloc.dart';

abstract class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class CodeChanged extends ResetPasswordEvent {
  final String? code;

  const CodeChanged({@required this.code});

  @override
  List<Object> get props => [code!];
}

class PasswordChanged extends ResetPasswordEvent {
  final String? password;

  const PasswordChanged({@required this.password});

  @override
  List<Object> get props => [password!];
}

class ConfirmPasswordChanged extends ResetPasswordEvent {
  final String? confirmPassword;

  const ConfirmPasswordChanged({@required this.confirmPassword});

  @override
  List<Object> get props => [confirmPassword!];
}

class FormSubmitted extends ResetPasswordEvent {}
