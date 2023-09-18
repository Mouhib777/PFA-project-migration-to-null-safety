part of 'bloc.dart';

class LoginState extends Equatable {
  final Email email;
  final Password password;
  final FormzStatus status;
  final UserData userData;

  const LoginState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzStatus.pure,
    this.userData,
  });

  LoginState copyWith(
      {Email email, Password password, FormzStatus status, UserData userData}) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      userData: userData ?? this.userData,
    );
  }

  @override
  List<Object> get props => [email, password, status, userData];

  @override
  bool get stringify => true;
}
