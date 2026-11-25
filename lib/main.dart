import 'package:flutter/material.dart';
import 'models/book.dart';
import 'models/user.dart';
import 'screens/book_catalog_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/loan_form_screen.dart';
import 'screens/loan_history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/not_found_screen.dart';

void main() {
  runApp(const SiPinjamApp());
}

class SiPinjamApp extends StatelessWidget {
  const SiPinjamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiPinjam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const LoginScreen(),
            );
          case '/home':
            final args = settings.arguments;
            if (args is! User) {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const LoginScreen(),
              );
            }
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => BookCatalogScreen(user: args),
            );
          case '/detail':
            final args = settings.arguments as Map<String, dynamic>;
            final book = args['book'] as Book;
            final user = args['user'] as User;
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => BookDetailScreen(book: book, user: user),
            );
          case '/loan-form':
            final args = settings.arguments as Map<String, dynamic>;
            final book = args['book'] as Book;
            final user = args['user'] as User;
            return MaterialPageRoute<dynamic>(
              settings: settings,
              builder: (_) => LoanFormScreen(book: book, user: user),
            );
          case '/history':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const LoanHistoryScreen(),
            );
          default:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => NotFoundScreen(routeName: settings.name),
            );
        }
      },
    );
  }
}