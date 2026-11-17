import 'package:flutter_test/flutter_test.dart';
import 'package:oxygenclub/core/network/api_exception.dart';

void main() {
  group('friendlyErrorMessage', () {
    test('returns display-ready messages from typed exceptions', () {
      const exception = NetworkException();

      expect(
        friendlyErrorMessage(exception),
        'No internet connection. Please check your network.',
      );
    });

    test('does not leak raw exception details', () {
      final error = StateError('secret internal detail');

      expect(
        friendlyErrorMessage(error),
        'Something went wrong. Please try again.',
      );
    });
  });
}
