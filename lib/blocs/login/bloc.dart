import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:docu_diary/repositories/repositories.dart';
import 'package:equatable/equatable.dart';
import 'package:docu_diary/models/models.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';

part 'event.dart';
part 'state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState());
  final _repository = UserRepository();
  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is EmailChanged) {
      final email = Email.dirty(event.email.trim());
      yield state.copyWith(
        email: email,
        status: Formz.validate([email, state.password]),
      );
    } else if (event is PasswordChanged) {
      final password = Password.dirty(event.password);
      yield state.copyWith(
        password: password,
        status: Formz.validate([state.email, password]),
      );
    } else if (event is FormSubmitted) {
      if (state.status.isValidated) {
        yield state.copyWith(status: FormzStatus.submissionInProgress);
        try {
          final UserData data = await this
              ._repository
              .login(email: state.email.value, password: state.password.value);

          yield state.copyWith(
              status: FormzStatus.submissionSuccess, userData: data);
        } catch (error) {
          yield state.copyWith(status: FormzStatus.submissionFailure);
        }
      }
    }
  }
}
