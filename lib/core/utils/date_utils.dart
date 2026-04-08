enum TransactionPeriod { day, week, month }

class TransactionDateRange {
  const TransactionDateRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;
}

class AppDateUtils {
  AppDateUtils._();

  static bool matchesPeriod(
    DateTime date,
    TransactionPeriod period, {
    DateTime? now,
  }) {
    final DateTime reference = _dateOnly(now ?? DateTime.now());
    final DateTime candidate = _dateOnly(date);

    switch (period) {
      case TransactionPeriod.day:
        return candidate == reference;
      case TransactionPeriod.week:
        final DateTime weekStart = _startOfWeek(reference);
        final DateTime weekEnd = weekStart.add(const Duration(days: 7));
        return !candidate.isBefore(weekStart) && candidate.isBefore(weekEnd);
      case TransactionPeriod.month:
        return candidate.year == reference.year &&
            candidate.month == reference.month;
    }
  }

  static TransactionDateRange getPeriodRange(
    TransactionPeriod period, {
    DateTime? now,
  }) {
    final DateTime reference = now ?? DateTime.now();

    switch (period) {
      case TransactionPeriod.day:
        return TransactionDateRange(
          start: DateTime(reference.year, reference.month, reference.day),
          end: DateTime(
            reference.year,
            reference.month,
            reference.day,
            23,
            59,
            59,
          ),
        );
      case TransactionPeriod.week:
        final DateTime start = _startOfWeek(_dateOnly(reference));
        return TransactionDateRange(
          start: start,
          end: DateTime(
            reference.year,
            reference.month,
            reference.day,
            23,
            59,
            59,
          ),
        );
      case TransactionPeriod.month:
        return TransactionDateRange(
          start: DateTime(reference.year, reference.month, 1),
          end: DateTime(
            reference.year,
            reference.month,
            reference.day,
            23,
            59,
            59,
          ),
        );
    }
  }

  static DateTime _startOfWeek(DateTime value) {
    return value.subtract(Duration(days: value.weekday - 1));
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
