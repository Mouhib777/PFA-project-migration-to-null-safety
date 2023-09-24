part of 'bloc.dart';

class RegisterState extends Equatable {
  final Name name;
  final Email email;
  final Password password;
  final ConfirmPassword confirmPassword;
  final FormzSubmissionStatus status;
  final UserData? userData;

  const RegisterState({
    this.name = const Name.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
    this.status = FormzSubmissionStatus.initial,
     this.userData,
  });

  RegisterState copyWith(
      { Name? name,
      Email? email,
      Password? password,
      ConfirmPassword? confirmPassword,
      FormzSubmissionStatus? status,
      UserData? userData}) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      userData: userData ?? this.userData,
    );
  }

  @override
  List<Object> get props =>
      [name, email, password, confirmPassword, status, userData!];

  @override
  bool get stringify => true;
}
