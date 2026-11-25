import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/loan.dart';
import '../models/user.dart';
import '../utils/notifier.dart';

class LoanFormScreen extends StatefulWidget {
  final Book book;
  final User user;

  const LoanFormScreen({
    super.key,
    required this.book,
    required this.user,
  });

  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  DateTime? _startDate;
  int? _durationDays;

  bool get _hasPartialInput => _startDate != null || _durationDays != null;

  DateTime? get _dueDate {
    if (_startDate == null || _durationDays == null) return null;
    return _startDate!.add(Duration(days: _durationDays!));
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _startDate = picked;
    });
  }

  Future<void> _pickDurationBottomSheet() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pilih Durasi Peminjaman',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            for (final days in [3, 7, 14])
              ListTile(
                title: Text('$days hari'),
                trailing: _durationDays == days ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(sheetContext, days),
              ),
          ],
        ),
      ),
    );

    if (!mounted || selected == null) return;
    setState(() {
      _durationDays = selected;
    });
  }

  Future<void> _submitLoan() async {
    if (_startDate == null || _durationDays == null || _dueDate == null) {
      showError(context, 'Lengkapi tanggal mulai dan durasi peminjaman terlebih dahulu.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ringkasan Peminjaman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Judul Buku: ${widget.book.title}'),
            const SizedBox(height: 6),
            Text('Peminjam: ${widget.user.name}'),
            const SizedBox(height: 6),
            Text('Tanggal Mulai: ${formatDateIndo(_startDate!)}'),
            const SizedBox(height: 6),
            Text('Tanggal Jatuh Tempo: ${formatDateIndo(_dueDate!)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ajukan'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    final loan = Loan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      book: widget.book,
      borrowerName: widget.user.name,
      startDate: _startDate!,
      durationDays: _durationDays!,
      dueDate: _dueDate!,
    );

    Navigator.pop(context, loan);
  }

  Future<void> _handlePopInvoked(bool didPop) async {
    if (didPop) return;
    final discard = await showConfirm(
      context,
      'Buang perubahan?',
      'Data form yang sudah diisi akan hilang jika Anda kembali.',
      teksBatal: 'Lanjut Mengisi',
      teksSetuju: 'Buang',
    );
    if (!mounted || !discard) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasPartialInput,
      onPopInvokedWithResult: (didPop, _) async {
        await _handlePopInvoked(didPop);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Form Peminjaman'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.book.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: const Icon(Icons.calendar_today),
                title: const Text('Tanggal Mulai'),
                subtitle: Text(
                  _startDate != null ? formatDateIndo(_startDate!) : 'Belum dipilih',
                ),
                onTap: _pickStartDate,
              ),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: const Icon(Icons.timelapse),
                title: const Text('Durasi Peminjaman'),
                subtitle: Text(
                  _durationDays != null ? '$_durationDays hari' : 'Pilih 3, 7, atau 14 hari',
                ),
                onTap: _pickDurationBottomSheet,
              ),
              if (_dueDate != null) ...[
                const SizedBox(height: 16),
                Text('Perkiraan Jatuh Tempo: ${formatDateIndo(_dueDate!)}'),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _submitLoan,
                child: const Text('Ajukan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}