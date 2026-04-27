enum TransactionPeriod { day, week, month, year, all, interval }

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
    DateTime? intervalStart,
    DateTime? intervalEnd,
  }) {
    final DateTime candidate = _dateOnly(date);
    final TransactionDateRange range = getPeriodRange(
      period,
      referenceDate: now,
      intervalStart: intervalStart,
      intervalEnd: intervalEnd,
    );
    return !candidate.isBefore(_dateOnly(range.start)) &&
        !candidate.isAfter(_dateOnly(range.end));
  }

  static TransactionDateRange getPeriodRange(
    TransactionPeriod period, {
    DateTime? referenceDate,
    DateTime? intervalStart,
    DateTime? intervalEnd,
  }) {
    final DateTime now = referenceDate ?? DateTime.now();
    return switch (period) {
      TransactionPeriod.day => TransactionDateRange(
          start: DateTime(now.year, now.month, now.day, 0, 0, 0),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        ),
      TransactionPeriod.week => TransactionDateRange(
          start: DateTime(
            now.year,
            now.month,
            now.day - (now.weekday - 1),
            0,
            0,
            0,
          ),
          end: DateTime(
            now.year,
            now.month,
            now.day + (7 - now.weekday),
            23,
            59,
            59,
          ),
        ),
      TransactionPeriod.month => TransactionDateRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        ),
      TransactionPeriod.year => TransactionDateRange(
          start: DateTime(now.year, 1, 1, 0, 0, 0),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        ),
      TransactionPeriod.all => TransactionDateRange(
          start: DateTime(2000, 1, 1),
          end: DateTime(2100, 12, 31),
        ),
      TransactionPeriod.interval => TransactionDateRange(
          start: intervalStart ?? DateTime(now.year, now.month, 1),
          end: intervalEnd ?? now,
        ),
    };
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
