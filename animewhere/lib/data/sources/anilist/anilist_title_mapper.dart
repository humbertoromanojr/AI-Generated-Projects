import 'dart:convert';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/network/network_error.dart';

class AniListTitleMapper {
  List<Title> mapPage(String body) {
    final decoded = _decode(body);
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseError('AniList response missing "data"');
    }

    final page = data['Page'];
    if (page is! Map<String, dynamic>) {
      throw const ParseError('AniList response missing "data.Page"');
    }

    final media = page['media'];
    if (media is! List) {
      throw const ParseError('AniList response missing "data.Page.media"');
    }

    final titles = <Title>[];
    for (final item in media) {
      final title = item is Map<String, dynamic> ? _mapItem(item) : null;
      if (title != null) titles.add(title);
    }
    return titles;
  }

  Title? mapDetail(String body) {
    final decoded = _decode(body);
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseError('AniList response missing "data"');
    }

    final media = data['Media'];
    if (media is! Map<String, dynamic>) {
      throw const ParseError('AniList response missing "data.Media"');
    }
    return _mapItem(media);
  }

  Title? _mapItem(Map<String, dynamic> item) {
    final id = item['id'];
    final title = _canonicalTitle(item['title']);
    final imageUrl = _largeImageUrl(item['coverImage']);

    if (id is! int) return null;
    if (title == null || title.isEmpty) return null;
    if (imageUrl == null || imageUrl.isEmpty) return null;

    final averageScore = item['averageScore'];
    return Title(
      id: '$id',
      source: TitleSource.anilist,
      kind: TitleKind.anime,
      title: title,
      imageUrl: imageUrl,
      description: item['description'] as String?,
      score: averageScore is num ? averageScore.toDouble() : null,
      seasonYear: (item['seasonYear'] as num?)?.toInt(),
      format: item['format'] as String?,
    );
  }

  String? _canonicalTitle(Object? title) {
    if (title is! Map<String, dynamic>) return null;
    final romaji = title['romaji'];
    final english = title['english'];
    return romaji is String && romaji.isNotEmpty
        ? romaji
        : english is String
        ? english
        : null;
  }

  String? _largeImageUrl(Object? coverImage) {
    if (coverImage is! Map<String, dynamic>) return null;
    final url = coverImage['large'];
    return url is String ? url : null;
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const ParseError('AniList response is not a JSON object');
      }
      return decoded;
    } on FormatException {
      throw const ParseError('AniList response is not valid JSON');
    }
  }
}
