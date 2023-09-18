import 'package:formz/formz.dart';

enum ConfirmPasswordValidationError { invalid }

class ConfirmPassword
    extends FormzInput<String, ConfirmPasswordValidationError> {
  const ConfirmPassword.pure() : super.pure('');
  const ConfirmPassword.dirty([String value = '']) : super.dirty(value);

  static final _confirmpasswordRegex = RegExp(r"(\w+).{5,}");

  @override
  ConfirmPasswordValidationError validator(String value) {
    return _confirmpasswordRegex.hasMatch(value)
        ? null
        : ConfirmPasswordValidationError.invalid;
  }
}
