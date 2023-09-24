import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:docu_diary/models/models.dart';
import 'package:formz/formz.dart';
import 'package:meta/meta.dart';
import 'package:docu_diary/repositories/repositories.dart';

part 'event.dart';
part 'state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterState());
  final _repository = UserRepository();
  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is NameChanged) {
      final name = Name.dirty(event.name.toString());
      yield state.copyWith(
        name: name,
        //!
        // status: Formz.validate(
        //   [name, state.email, state.password, state.confirmPassword],
        // ),
      );
    } else if (event is EmailChanged) {
      final email = Email.dirty(event.email.toString());
      yield state.copyWith(
        email: email,
        //!
        // status: Formz.validate(
        //   [state.name, email, state.password, state.confirmPassword],
        // ),
      );
    } else if (event is PasswordChanged) {
      final password = Password.dirty(event.password.toString());
      yield state.copyWith(
        password: password,
        //!
        // status: Formz.validate(
        //   [state.name, state.email, password, state.confirmPassword],
        // ),
      );
    } else if (event is ConfirmPasswordChanged) {
      final confirmPassword =
          ConfirmPassword.dirty(event.confirmPassword.toString());

      yield state.copyWith(
        confirmPassword: confirmPassword,
        // status: Formz.validate(
        //   [state.name, state.email, state.password, confirmPassword],
        // ),
      );
    } else if (event is FormSubmitted) {
      if (state.status.isSuccess) {
        yield state.copyWith(status: FormzSubmissionStatus.inProgress);

        try {
          final UserData data = await this._repository.register(
                name: state.name.value,
                email: state.email.value,
                password: state.password.value,
                confirmPassword: state.confirmPassword.value,
              );
          yield state.copyWith(
            status: FormzSubmissionStatus.success,
            userData: data,
          );
        } catch (error) {
          yield state.copyWith(status: FormzSubmissionStatus.failure);
        }
      }
    }
  }
}
