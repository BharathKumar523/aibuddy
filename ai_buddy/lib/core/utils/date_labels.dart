import 'package:intl/intl.dart';

/// Short, human labels for list timestamps:
/// today → "3:41 PM", yesterday → "Yesterday", this week → "Monday",
/// this year → "Nov 2", older → "Nov 2, 2025".
String relativeDateLabel(DateTime time, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final local = time.toLocal();
  final today = DateTime(current.year, current.month, current.day);
  final day = DateTime(local.year, local.month, local.day);
  // Rounded hours, so 23- or 25-hour days around DST changes still count as 1.
  final daysAgo = (today.difference(day).inHours / 24).round();

  if (daysAgo <= 0) return DateFormat.jm().format(local);
  if (daysAgo == 1) return 'Yesterday';
  if (daysAgo < 7) return DateFormat.EEEE().format(local);
  if (local.year == current.year) return DateFormat.MMMd().format(local);
  return DateFormat.yMMMd().format(local);
}
