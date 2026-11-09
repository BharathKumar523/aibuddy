import 'package:flutter_test/flutter_test.dart';

import 'package:ai_buddy/core/utils/date_labels.dart';

void main() {
  final now = DateTime(2026, 11, 9, 15, 30); // Monday

  test('today shows the time', () {
    expect(relativeDateLabel(DateTime(2026, 11, 9, 9, 5), now: now), contains('9:05'));
  });

  test('yesterday', () {
    expect(relativeDateLabel(DateTime(2026, 11, 8, 23, 59), now: now), 'Yesterday');
  });

  test('within a week shows the weekday', () {
    expect(relativeDateLabel(DateTime(2026, 11, 5, 12), now: now), 'Thursday');
  });

  test('earlier this year shows month and day', () {
    expect(relativeDateLabel(DateTime(2026, 3, 14), now: now), 'Mar 14');
  });

  test('previous years include the year', () {
    expect(relativeDateLabel(DateTime(2025, 12, 31), now: now), 'Dec 31, 2025');
  });
}
