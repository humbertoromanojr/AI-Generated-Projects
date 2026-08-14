import 'package:flutter/foundation.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/utils/result.dart';
import 'package:animewhere/data/repositories/catalog_repository.dart';

class RowState {
  RowState({required this.id, required this.label, required this.result});

  final String id;
  final String label;
  Result<List<Title>> result;
}

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this.repository}) {
    rows = [
      RowState(id: 'trending', label: 'Trending', result: const Loading()),
      RowState(id: 'popular', label: 'Popular', result: const Loading()),
      RowState(id: 'latest', label: 'Latest', result: const Loading()),
      RowState(id: 'manga', label: 'Manga', result: const Loading()),
    ];
  }

  final CatalogRepository repository;

  Result<List<Title>> carousel = const Loading();
  late final List<RowState> rows;
  bool _isInitialLoading = true;

  bool get isInitialLoading => _isInitialLoading;

  Future<void> load() async {
    _isInitialLoading = true;
    notifyListeners();
    await _fetchAll(keepPrevious: false);
    _isInitialLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _fetchAll(keepPrevious: true);

  Future<void> _fetchAll({required bool keepPrevious}) async {
    await Future.wait([
      _loadSection(
        assign: (result) => carousel = result,
        current: carousel,
        request: repository.carousel,
        keepPrevious: keepPrevious,
      ),
      _loadRow(rows[0], repository.trending, keepPrevious: keepPrevious),
      _loadRow(rows[1], repository.popular, keepPrevious: keepPrevious),
      _loadRow(rows[2], repository.latest, keepPrevious: keepPrevious),
      _loadRow(rows[3], repository.manga, keepPrevious: keepPrevious),
    ]);
    notifyListeners();
  }

  Future<void> _loadRow(
    RowState row,
    Future<Result<List<Title>>> Function() request, {
    required bool keepPrevious,
  }) {
    return _loadSection(
      assign: (result) => row.result = result,
      current: row.result,
      request: request,
      keepPrevious: keepPrevious,
    );
  }

  Future<void> _loadSection({
    required void Function(Result<List<Title>>) assign,
    required Result<List<Title>> current,
    required Future<Result<List<Title>>> Function() request,
    required bool keepPrevious,
  }) async {
    final result = await request();
    if (keepPrevious &&
        result is Failure<List<Title>> &&
        current is Data<List<Title>>) {
      return;
    }
    assign(result);
  }
}
