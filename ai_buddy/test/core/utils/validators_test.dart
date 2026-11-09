import 'package:flutter_test/flutter_test.dart';

import 'package:ai_buddy/core/utils/validators.dart';

void main() {
  group('name', () {
    test('accepts a normal name and ignores surrounding spaces', () {
      expect(Validators.name('Ada'), isNull);
      expect(Validators.name('  Al  '), isNull);
    });

    test('rejects empty, too short and too long names', () {
      expect(Validators.name(''), 'Name is required.');
      expect(Validators.name('   '), 'Name is required.');
      expect(Validators.name('A'), 'Name must be at least 2 characters.');
      expect(Validators.name('x' * 51), 'Name must be at most 50 characters.');
    });
  });

  group('email', () {
    test('accepts valid addresses', () {
      expect(Validators.email('ada@example.com'), isNull);
      expect(Validators.email('  ADA@Example.co.in '), isNull);
    });

    test('rejects missing or malformed addresses', () {
      expect(Validators.email(''), 'Email is required.');
      expect(Validators.email(null), 'Email is required.');
      for (final bad in ['ada', 'ada@', 'ada@example', '@example.com', 'a b@c.com']) {
        expect(Validators.email(bad), 'Enter a valid email address.', reason: bad);
      }
    });
  });

  group('loginPassword', () {
    test('only requires a value', () {
      expect(Validators.loginPassword('x'), isNull);
      expect(Validators.loginPassword(''), 'Password is required.');
    });
  });

  group('newPassword', () {
    test('accepts 8+ characters with a letter and a number', () {
      expect(Validators.newPassword('secret123'), isNull);
      expect(Validators.newPassword('pässwörd1'), isNull);
    });

    test('enforces the backend rules', () {
      expect(Validators.newPassword(''), 'Password is required.');
      expect(
        Validators.newPassword('abc1'),
        'Password must be at least 8 characters.',
      );
      expect(
        Validators.newPassword('onlyletters'),
        'Password must contain at least one letter and one number.',
      );
      expect(
        Validators.newPassword('12345678'),
        'Password must contain at least one letter and one number.',
      );
    });

    test('limits by bytes, like bcrypt (é is 2 bytes)', () {
      expect(Validators.newPassword('a1${'é' * 35}'), isNull); // 72 bytes
      expect(
        Validators.newPassword('a1${'é' * 36}'), // 74 bytes
        'Password must be at most 72 characters.',
      );
    });
  });

  group('confirmPassword', () {
    test('must match the original', () {
      final validate = Validators.confirmPassword(() => 'secret123');

      expect(validate('secret123'), isNull);
      expect(validate('secret124'), 'Passwords do not match.');
      expect(validate(''), 'Please confirm your password.');
    });
  });
}
