part of 'forgetPassword_bloc.dart';

class ForgetPasswordState extends Equatable {
  final Email email;

  final FormzStatus status;

  const ForgetPasswordState({
    this.email = const Email.pure(),
    this.status = FormzStatus.pure,
  });

  ForgetPasswordState copyWith({
    Email email,
    FormzStatus status,
  }) {
    return ForgetPasswordState(
      email: email ?? this.email,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [email, status];

  @override
  bool get stringify => true;
}
