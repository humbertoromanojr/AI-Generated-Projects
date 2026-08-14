import 'dart:convert';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/network/network_error.dart';

class JikanTitleMapper {
  List<Title> mapList(String body) {
    final decoded = _decode(body);
    final data = decoded['data'];
    if (data is! List) {
      throw const ParseError('Jikan response missing "data" list');
    }

    final titles = <Title>[];
    for (final item in data) {
      final title = item is Map<String, dynamic> ? _mapItem(item) : null;
      if (title != null) titles.add(title);
    }
    return titles;
  }

  Title? mapDetail(String body) {
    final decoded = _decode(body);
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseError('Jikan detail response missing "data"');
    }
    return _mapItem(data);
  }

  Title? _mapItem(Map<String, dynamic> item) {
    final malId = item['mal_id'];
    final title = item['title'];
    final imageUrl = _largeImageUrl(item['images']);

    if (malId is! int || malId <= 0) return null;
    if (title is! String || title.isEmpty) return null;
    if (imageUrl == null || imageUrl.isEmpty) return null;

    final score = item['score'];
    return Title(
      id: '$malId',
      source: TitleSource.jikan,
      kind: TitleKind.anime,
      title: title,
      imageUrl: imageUrl,
      description: item['synopsis'] as String?,
      score: score is num ? score.toDouble() * 10 : null,
      seasonYear: (item['year'] as num?)?.toInt(),
      format: item['type'] as String?,
      providerUrl: item['url'] as String?,
    );
  }

  String? _largeImageUrl(Object? images) {
    if (images is! Map<String, dynamic>) return null;
    final jpg = images['jpg'];
    if (jpg is! Map<String, dynamic>) return null;
    final url = jpg['large_image_url'];
    return url is String ? url : null;
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const ParseError('Jikan response is not a JSON object');
      }
      return decoded;
    } on FormatException {
      throw const ParseError('Jikan response is not valid JSON');
    }
  }
}
