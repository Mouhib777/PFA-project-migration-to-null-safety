part of 'forgetPassword_bloc.dart';

abstract class ForgetPasswordEvent extends Equatable {
  const ForgetPasswordEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class EmailChanged extends ForgetPasswordEvent {
  final String email;

  const EmailChanged({required this.email});

  @override
  List<Object> get props => [email];
}

class FormSubmitted extends ForgetPasswordEvent {}
