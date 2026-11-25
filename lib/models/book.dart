enum BookStatus {
  tersedia,
  dipinjam,
}

class Book {
  final String id;
  final String title;
  final String author;
  BookStatus status;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.status = BookStatus.tersedia,
  });

  String get statusLabel =>
      status == BookStatus.tersedia ? 'Tersedia' : 'Dipinjam';
}

final List<Book> catalogBooks = [
  Book(
    id: 'B01',
    title: 'Rekayasa Perangkat Lunak',
    author: 'Ian Sommerville',
  ),
  Book(
    id: 'B02',
    title: 'Struktur Data dan Algoritma',
    author: 'Thomas H. Cormen',
  ),
  Book(
    id: 'B03',
    title: 'Pemrograman Flutter Modern',
    author: 'Budi Raharjo',
  ),
  Book(
    id: 'B04',
    title: 'Sistem Basis Data',
    author: 'Ramez Elmasri',
  ),
  Book(
    id: 'B05',
    title: 'Jaringan Komputer',
    author: 'Andrew S. Tanenbaum',
  ),
  Book(
    id: 'B06',
    title: 'Analisis dan Perancangan Sistem',
    author: 'Kendall & Kendall',
  ),
  Book(
    id: 'B07',
    title: 'Interaksi Manusia dan Komputer',
    author: 'Alan Dix',
  ),
  Book(
    id: 'B08',
    title: 'Manajemen Proyek TI',
    author: 'Kathy Schwalbe',
  ),
];