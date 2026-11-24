import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/core/utils/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    test('requires non-empty values and accepts trimmed content', () {
      expect(AuthValidators.required(null, 'Name'), 'Name is required.');
      expect(AuthValidators.required('  ', 'Name'), 'Name is required.');
      expect(AuthValidators.required(' Asha ', 'Name'), isNull);
    });

    test('validates email addresses after trimming whitespace', () {
      expect(AuthValidators.email(''), 'Email is required.');
      expect(AuthValidators.email('not-an-email'), 'Enter a valid email address.');
      expect(AuthValidators.email(' person@example.com '), isNull);
    });

    test('validates password length and confirmation', () {
      expect(AuthValidators.password(''), 'Password is required.');
      expect(AuthValidators.password('short'), 'Use at least 8 characters.');
      expect(AuthValidators.password('long-enough'), isNull);
      expect(AuthValidators.confirmPassword('different', 'long-enough'), 'Passwords do not match.');
      expect(AuthValidators.confirmPassword('long-enough', 'long-enough'), isNull);
    });
  });
}
