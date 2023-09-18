part of 'resetPassword_bloc.dart';

class ResetPasswordState extends Equatable {
  final ConfirmCode code;
  final Password password;
  final ConfirmPassword confirmPassword;
  final FormzStatus status;

  const ResetPasswordState({
    this.code = const ConfirmCode.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
    this.status = FormzStatus.pure,
  });

  ResetPasswordState copyWith({
    ConfirmCode code,
    Password password,
    ConfirmPassword confirmPassword,
    FormzStatus status,
  }) {
    return ResetPasswordState(
      code: code ?? this.code,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [code, password, confirmPassword, status];

  @override
  bool get stringify => true;
}
