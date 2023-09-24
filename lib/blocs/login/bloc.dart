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
  LoginBloc() : super( LoginState());
  final _repository = UserRepository();
  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is EmailChanged) {
      final email = Email.dirty(event.email.trim());
      yield state.copyWith(
        email: email,
        status: FormzSubmissionStatus.initial,
      );
    } else if (event is PasswordChanged) {
      final password = Password.dirty(event.password);
      yield state.copyWith(
        password: password,
        status: FormzSubmissionStatus.initial
      );
    } else if (event is FormSubmitted) {
      if (state.status.isInProgress) {
        yield state.copyWith(status: FormzSubmissionStatus.inProgress);
        try {
          final UserData data = await this
              ._repository
              .login(email: state.email.value, password: state.password.value);

          yield state.copyWith(
              status: FormzSubmissionStatus.success, userData: data);
        } catch (error) {
          yield state.copyWith(status: FormzSubmissionStatus.failure);
        }
      }
    }
  }
}
