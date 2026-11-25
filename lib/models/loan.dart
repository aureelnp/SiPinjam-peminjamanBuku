import 'book.dart';

class Loan {
  final String id;
  final Book book;
  final String borrowerName;
  final DateTime startDate;
  int durationDays;
  DateTime dueDate;
  bool hasExtended;

  Loan({
    required this.id,
    required this.book,
    required this.borrowerName,
    required this.startDate,
    required this.durationDays,
    required this.dueDate,
    this.hasExtended = false,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  bool get isDueSoon => daysRemaining <= 2;
}

final List<Loan> activeLoans = [];

String formatDateIndo(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}