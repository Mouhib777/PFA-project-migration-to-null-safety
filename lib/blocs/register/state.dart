part of 'bloc.dart';

class RegisterState extends Equatable {
  final Name name;
  final Email email;
  final Password password;
  final ConfirmPassword confirmPassword;
  final FormzStatus status;
  final UserData userData;

  const RegisterState({
    this.name = const Name.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const ConfirmPassword.pure(),
    this.status = FormzStatus.pure,
    this.userData,
  });

  RegisterState copyWith(
      {Name name,
      Email email,
      Password password,
      ConfirmPassword confirmPassword,
      FormzStatus status,
      UserData userData}) {
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
      [name, email, password, confirmPassword, status, userData];

  @override
  bool get stringify => true;
}
