import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/loan.dart';
import '../models/user.dart';
import '../utils/notifier.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  final User user;

  const BookDetailScreen({
    super.key,
    required this.book,
    required this.user,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Future<void> _openLoanForm() async {
    final result = await Navigator.pushNamed(
      context,
      '/loan-form',
      arguments: {'book': widget.book, 'user': widget.user},
    );
    if (!mounted || result is! Loan) return;

    setState(() {
      widget.book.status = BookStatus.dipinjam;
      activeLoans.add(result);
    });

    showSuccess(
      context,
      'Buku ${widget.book.title} berhasil dipinjam hingga ${formatDateIndo(result.dueDate)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.book.status == BookStatus.tersedia;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.menu_book_rounded, size: 72),
            const SizedBox(height: 16),
            Text(
              widget.book.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Penulis: ${widget.book.author}'),
            const SizedBox(height: 8),
            Text('Status: ${widget.book.statusLabel}'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isAvailable ? _openLoanForm : null,
                icon: const Icon(Icons.assignment_turned_in),
                label: Text(isAvailable ? 'Pinjam' : 'Sedang Dipinjam'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}