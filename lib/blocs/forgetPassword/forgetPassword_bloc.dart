import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:docu_diary/models/models.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';
import 'package:docu_diary/repositories/repositories.dart';
part 'forgetPassword_event.dart';
part 'forgetPassword_state.dart';

class ForgetPasswordBloc
    extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  ForgetPasswordBloc() : super(const ForgetPasswordState());
  final _repository = UserRepository();
  @override
  Stream<ForgetPasswordState> mapEventToState(
    ForgetPasswordEvent event,
  ) async* {
    if (event is EmailChanged) {
      final email = Email.dirty(event.email);
      yield state.copyWith(
        email: email,
        // status: Formz.validate([email]),
      );
    } else if (event is FormSubmitted) {
      if (state.status.isSuccess) {
        yield state.copyWith(status: FormzSubmissionStatus.inProgress);

        try {
          await this._repository.forgetPassword(
                email: state.email.value,
              );
          yield state.copyWith(status: FormzSubmissionStatus.success);
        } catch (error) {
          yield state.copyWith(status: FormzSubmissionStatus.failure);
        }
      }
    }
  }
}
