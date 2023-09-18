import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:docu_diary/models/models.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';
import 'package:docu_diary/repositories/repositories.dart';
part 'resetPassword_event.dart';
part 'resetPassword_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc() : super(const ResetPasswordState());
  final _repository = UserRepository();
  @override
  Stream<ResetPasswordState> mapEventToState(
    ResetPasswordEvent event,
  ) async* {
    if (event is CodeChanged) {
      final code = ConfirmCode.dirty(event.code);
      yield state.copyWith(
        code: code,
        status: Formz.validate([code, state.password, state.confirmPassword]),
      );
    } else if (event is PasswordChanged) {
      final password = Password.dirty(event.password);
      yield state.copyWith(
        password: password,
        status: Formz.validate([state.code, password, state.confirmPassword]),
      );
    } else if (event is ConfirmPasswordChanged) {
      final confirmPassword = ConfirmPassword.dirty(event.confirmPassword);

      yield state.copyWith(
        confirmPassword: confirmPassword,
        status: Formz.validate([state.code, state.password, confirmPassword]),
      );
    } else if (event is FormSubmitted) {
      if (state.status.isValidated) {
        yield state.copyWith(status: FormzStatus.submissionInProgress);
        try {
          await this._repository.resetPassword(
              code: state.code.value, password: state.password.value);
          yield state.copyWith(status: FormzStatus.submissionSuccess);
        } catch (error) {
          yield state.copyWith(status: FormzStatus.submissionFailure);
        }
      }
    }
  }
}
