import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/notifier.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const String validUsername = 'Aurel';
  static const String validPassword = '607012500034';
  static const int maxAttempts = 3;

  int _failedAttempts = 0;
  bool _isLocked = false;
  int _remainingSeconds = 0;
  Timer? _lockTimer;

  @override
  void dispose() {
    _lockTimer?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startLockCountdown() {
    _lockTimer?.cancel();
    setState(() {
      _isLocked = true;
      _remainingSeconds = 30;
    });

    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _isLocked = false;
          _remainingSeconds = 0;
          _failedAttempts = 0;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  Future<void> _showLockedDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Akun terkunci sementara'),
        content: const Text(
          'Terlalu banyak percobaan login yang gagal. Silakan tunggu 30 detik sebelum mencoba kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitLogin() async {
    if (_isLocked) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty && password.isEmpty) {
      showError(context, 'Field Username dan Password tidak boleh kosong.');
      return;
    }
    if (username.isEmpty) {
      showError(context, 'Field Username tidak boleh kosong.');
      return;
    }
    if (password.isEmpty) {
      showError(context, 'Field Password tidak boleh kosong.');
      return;
    }

    if (username == validUsername && password == validPassword) {
      _failedAttempts = 0;
      final user = User(name: username, nim: password);
      Navigator.pushReplacementNamed(context, '/home', arguments: user);
      return;
    }

    _failedAttempts++;
    final sisa = maxAttempts - _failedAttempts;

    if (_failedAttempts >= maxAttempts) {
      _startLockCountdown();
      await _showLockedDialog();
    } else {
      showError(
        context,
        'Username atau password salah. Sisa kesempatan: $sisa kali.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SiPinjam - Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.menu_book, size: 64),
                const SizedBox(height: 12),
                Text(
                  'Masuk ke SiPinjam',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _usernameController,
                  enabled: !_isLocked,
                  decoration: const InputDecoration(
                    labelText: 'Username (Nama)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  enabled: !_isLocked,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password (NIM)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isLocked ? null : _submitLogin,
                  child: Text(
                    _isLocked
                        ? 'Terkunci ($_remainingSeconds dtk)'
                        : 'Masuk',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}