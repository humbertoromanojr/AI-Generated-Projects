import 'package:flutter/foundation.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_page.dart';
import 'package:animewhere/core/utils/result.dart';
import 'package:animewhere/data/repositories/catalog_repository.dart';

class InfiniteRowState {
  InfiniteRowState({
    required this.id,
    required this.label,
    required this.titles,
    this.nextPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.loadFailed = false,
  });

  final String id;
  final String label;
  final List<Title> titles;
  final int nextPage;
  bool hasMore;
  bool isLoadingMore;
  bool loadFailed;

  InfiniteRowState copyWith({
    String? id,
    String? label,
    List<Title>? titles,
    int? nextPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadFailed,
  }) {
    return InfiniteRowState(
      id: id ?? this.id,
      label: label ?? this.label,
      titles: titles ?? this.titles,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadFailed: loadFailed ?? this.loadFailed,
    );
  }
}

class SectionState {
  SectionState({
    required this.id,
    required this.label,
    required this.carousel,
    required this.rows,
  });

  final String id;
  final String label;
  final Result<TitlePage> carousel;
  final List<InfiniteRowState> rows;

  SectionState copyWith({
    String? id,
    String? label,
    Result<TitlePage>? carousel,
    List<InfiniteRowState>? rows,
  }) {
    return SectionState(
      id: id ?? this.id,
      label: label ?? this.label,
      carousel: carousel ?? this.carousel,
      rows: rows ?? this.rows,
    );
  }
}

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this.repository}) {
    _initializeSections();
  }

  final CatalogRepository repository;

  List<SectionState> sections = [];
  bool _isInitialLoading = true;

  bool get isInitialLoading => _isInitialLoading;

  void _initializeSections() {
    sections = [
      SectionState(
        id: 'jikan',
        label: 'Jikan',
        carousel: const Loading<TitlePage>(),
        rows: [
          InfiniteRowState(id: 'seasonal', label: 'Seasonal', titles: []),
          InfiniteRowState(id: 'upcoming', label: 'Upcoming', titles: []),
        ],
      ),
      SectionState(
        id: 'anilist',
        label: 'AniList',
        carousel: const Loading<TitlePage>(),
        rows: [
          InfiniteRowState(id: 'popular', label: 'Popular', titles: []),
          InfiniteRowState(id: 'topRated', label: 'Top Rated', titles: []),
        ],
      ),
      SectionState(
        id: 'kitsu',
        label: 'Kitsu',
        carousel: const Loading<TitlePage>(),
        rows: [
          InfiniteRowState(id: 'manga', label: 'Manga', titles: []),
          InfiniteRowState(id: 'anime', label: 'Anime', titles: []),
        ],
      ),
    ];
  }

  Future<void> load() async {
    _isInitialLoading = true;
    notifyListeners();
    await _fetchAll(keepPrevious: false);
    _isInitialLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _fetchAll(keepPrevious: true);

  Future<void> loadMore(String sectionId, String rowId) async {
    final sectionIdx = sections.indexWhere((s) => s.id == sectionId);
    if (sectionIdx < 0) return;
    final section = sections[sectionIdx];
    final rowIdx = section.rows.indexWhere((r) => r.id == rowId);
    if (rowIdx < 0) return;
    final row = section.rows[rowIdx];
    if (row.isLoadingMore || !row.hasMore) return;

    final updatedRow = row.copyWith(isLoadingMore: true);
    final updatedRows = List<InfiniteRowState>.from(section.rows);
    updatedRows[rowIdx] = updatedRow;
    sections[sectionIdx] = section.copyWith(rows: updatedRows);
    notifyListeners();

    late Future<Result<TitlePage>> pageResult;
    switch (sectionId) {
      case 'jikan':
        if (rowId == 'seasonal') {
          pageResult = repository.jikanSeasonal(row.nextPage);
        } else {
          pageResult = repository.jikanUpcoming(row.nextPage);
        }
        break;
      case 'anilist':
        if (rowId == 'popular') {
          pageResult = repository.anilistPopular(row.nextPage);
        } else {
          pageResult = repository.anilistTopRated(row.nextPage);
        }
        break;
      case 'kitsu':
        if (rowId == 'manga') {
          pageResult = repository.kitsuManga(row.nextPage);
        } else {
          pageResult = repository.kitsuAnime(row.nextPage);
        }
        break;
    }

    final result = await pageResult;
    final failed = result is Failure<TitlePage>;

    final titles = [...row.titles];
    if (!failed) {
      for (final t in _extractTitles(result)) {
        if (!titles.any((e) => e.source == t.source && e.id == t.id)) {
          titles.add(t);
        }
      }
    }

    final finalRow = row.copyWith(
      titles: titles,
      nextPage: failed ? row.nextPage : row.nextPage + 1,
      hasMore: failed ? row.hasMore : _extractHasMore(result, true),
      isLoadingMore: false,
      loadFailed: failed,
    );
    final finalRows = List<InfiniteRowState>.from(section.rows);
    finalRows[rowIdx] = finalRow;
    sections[sectionIdx] = section.copyWith(rows: finalRows);
    notifyListeners();
  }

  Future<void> _fetchAll({required bool keepPrevious}) async {
    final carousel0 = repository.jikanCarousel();
    final row1_0 = repository.jikanSeasonal(1);
    final row2_0 = repository.jikanUpcoming(1);
    final carousel1 = repository.anilistCarousel();
    final row1_1 = repository.anilistPopular(1);
    final row2_1 = repository.anilistTopRated(1);
    final carousel2 = repository.kitsuCarousel();
    final row1_2 = repository.kitsuManga(1);
    final row2_2 = repository.kitsuAnime(1);

    await Future.wait([
      _loadSection(
        sectionIdx: 0,
        carouselResult: carousel0,
        row1Result: row1_0,
        row2Result: row2_0,
        keepPrevious: keepPrevious,
      ),
      _loadSection(
        sectionIdx: 1,
        carouselResult: carousel1,
        row1Result: row1_1,
        row2Result: row2_1,
        keepPrevious: keepPrevious,
      ),
      _loadSection(
        sectionIdx: 2,
        carouselResult: carousel2,
        row1Result: row1_2,
        row2Result: row2_2,
        keepPrevious: keepPrevious,
      ),
    ]);
    notifyListeners();
  }

  Future<void> _loadSection({
    required int sectionIdx,
    required Future<Result<TitlePage>> carouselResult,
    required Future<Result<TitlePage>> row1Result,
    required Future<Result<TitlePage>> row2Result,
    required bool keepPrevious,
  }) async {
    final section = sections[sectionIdx];

    final carousel = await carouselResult;
    final row1 = await row1Result;
    final row2 = await row2Result;

    final updatedRows = <InfiniteRowState>[];
    for (int i = 0; i < section.rows.length; i++) {
      final row = section.rows[i];
      final result = i == 0 ? row1 : row2;
      final updatedRow = row.copyWith(
        titles: _extractTitles(result),
        nextPage: _extractNextPage(result),
        hasMore: _extractHasMore(result, i == section.rows.length - 1),
        isLoadingMore: false,
        loadFailed: false,
      );
      updatedRows.add(updatedRow);
    }

    final updatedSection = section.copyWith(
      carousel: carousel,
      rows: updatedRows,
    );
    sections[sectionIdx] = updatedSection;
    notifyListeners();
  }

  List<Title> _extractTitles(Result<TitlePage> result) {
    if (result is Data<TitlePage>) {
      return result.value.titles;
    }
    return [];
  }

  int _extractNextPage(Result<TitlePage> result) {
    if (result is Data<TitlePage>) {
      return result.value.titles.length == 10 ? 2 : 1;
    }
    return 1;
  }

  bool _extractHasMore(Result<TitlePage> result, bool isLastRow) {
    if (result is Data<TitlePage>) {
      return result.value.titles.length == 10;
    }
    return false;
  }
}
