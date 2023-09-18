import 'package:formz/formz.dart';

enum ConfirmCodeValidationError { invalid }

class ConfirmCode extends FormzInput<String, ConfirmCodeValidationError> {
  const ConfirmCode.pure() : super.pure('');
  const ConfirmCode.dirty([String value = '']) : super.dirty(value);

  static final _confirmcodeRegex = RegExp(r"(\w+).{4,}");

  @override
  ConfirmCodeValidationError validator(String value) {
    return _confirmcodeRegex.hasMatch(value)
        ? null
        : ConfirmCodeValidationError.invalid;
  }
}
