import 'title.dart';

class Collection {
  const Collection({
    required this.id,
    required this.label,
    this.titles = const [],
  });

  final String id;
  final String label;
  final List<Title> titles;
}

class HomeCatalog {
  const HomeCatalog({required this.carousel, this.rows = const []});

  final Collection carousel;
  final List<Collection> rows;
}
