import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/loan.dart';
import '../models/user.dart';
import '../utils/notifier.dart';

class BookCatalogScreen extends StatefulWidget {
  final User user;

  const BookCatalogScreen({
    super.key,
    required this.user,
  });

  @override
  State<BookCatalogScreen> createState() => _BookCatalogScreenState();
}

class _BookCatalogScreenState extends State<BookCatalogScreen> {
  Future<void> _openDetail(Book book) async {
    await Navigator.pushNamed(
      context,
      '/detail',
      arguments: {'book': book, 'user': widget.user},
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openHistory() async {
    await Navigator.pushNamed(context, '/history', arguments: widget.user);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _confirmLogout() async {
    final setuju = await showConfirm(
      context,
      'Konfirmasi Logout',
      'Apakah Anda yakin ingin keluar dari akun?',
      teksSetuju: 'Logout',
    );
    if (!mounted || !setuju) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _triggerUnknownRoute() {
    Navigator.pushNamed(context, '/tidak-ada');
  }

  @override
  Widget build(BuildContext context) {
    final dueSoonCount = activeLoans.where((loan) => loan.isDueSoon).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${widget.user.name}'),
        actions: [
          IconButton(
            tooltip: 'Riwayat Peminjaman',
            onPressed: _openHistory,
            icon: Badge(
              isLabelVisible: activeLoans.isNotEmpty,
              label: Text('${activeLoans.length}'),
              child: const Icon(Icons.history),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.user.name),
              accountEmail: Text('NIM: ${widget.user.nim}'),
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Katalog Buku'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Peminjaman'),
              onTap: () {
                Navigator.pop(context);
                _openHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _confirmLogout();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Test Route Tidak Dikenal'),
              onTap: () {
                Navigator.pop(context);
                _triggerUnknownRoute();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (dueSoonCount > 0)
            MaterialBanner(
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              content: Text(
                'Pengingat: Terdapat $dueSoonCount buku yang jatuh tempo dalam ≤ 2 hari.',
              ),
              actions: [
                TextButton(
                  onPressed: _openHistory,
                  child: const Text('Lihat Riwayat'),
                ),
              ],
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: catalogBooks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final book = catalogBooks[index];
                final isAvailable = book.status == BookStatus.tersedia;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(book.title),
                    subtitle: Text('Penulis: ${book.author}'),
                    trailing: Chip(
                      label: Text(book.statusLabel),
                      backgroundColor: isAvailable
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                    ),
                    onTap: () => _openDetail(book),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'Debug Unknown Route',
        onPressed: _triggerUnknownRoute,
        child: const Icon(Icons.help_outline),
      ),
    );
  }
}