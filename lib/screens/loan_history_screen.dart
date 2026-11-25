import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/loan.dart';

class LoanHistoryScreen extends StatefulWidget {
  const LoanHistoryScreen({super.key});

  @override
  State<LoanHistoryScreen> createState() => _LoanHistoryScreenState();
}

class _LoanHistoryScreenState extends State<LoanHistoryScreen> {
  void _returnBook(int index, Loan loan) {
    setState(() {
      activeLoans.removeAt(index);
      loan.book.status = BookStatus.tersedia;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Buku "${loan.book.title}" telah dikembalikan.'),
          action: SnackBarAction(
            label: 'BATALKAN',
            onPressed: () {
              setState(() {
                final insertIndex =
                    index <= activeLoans.length ? index : activeLoans.length;
                activeLoans.insert(insertIndex, loan);
                loan.book.status = BookStatus.dipinjam;
              });
            },
          ),
        ),
      );
  }

  Future<void> _showLoanSheet(Loan loan) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (innerContext, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loan.book.title,
                  style: Theme.of(innerContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Penulis: ${loan.book.author}'),
                Text('Peminjam: ${loan.borrowerName}'),
                Text('Tanggal Mulai: ${formatDateIndo(loan.startDate)}'),
                Text('Jatuh Tempo: ${formatDateIndo(loan.dueDate)}'),
                Text(
                  'Status Perpanjangan: ${loan.hasExtended ? "Sudah diperpanjang" : "Belum diperpanjang"}',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    if (loan.hasExtended) {
                      showDialog<void>(
                        context: innerContext,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Peringatan Perpanjangan'),
                          content: const Text(
                            'Perpanjangan hanya boleh dilakukan 1 kali untuk setiap peminjaman.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Tutup'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    setState(() {
                      loan.durationDays += 7;
                      loan.dueDate = loan.dueDate.add(const Duration(days: 7));
                      loan.hasExtended = true;
                    });
                    setSheetState(() {});
                  },
                  icon: const Icon(Icons.update),
                  label: const Text('Perpanjang 7 hari'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Peminjaman'),
      ),
      body: activeLoans.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 64),
                  SizedBox(height: 12),
                  Text('Belum ada peminjaman buku aktif.'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: activeLoans.length,
              itemBuilder: (context, index) {
                final loan = activeLoans[index];
                return Dismissible(
                  key: ValueKey(loan.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.assignment_return, color: Colors.white),
                  ),
                  onDismissed: (_) => _returnBook(index, loan),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.bookmark_added),
                      title: Text(loan.book.title),
                      subtitle: Text('Jatuh tempo: ${formatDateIndo(loan.dueDate)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showLoanSheet(loan),
                    ),
                  ),
                );
              },
            ),
    );
  }
}