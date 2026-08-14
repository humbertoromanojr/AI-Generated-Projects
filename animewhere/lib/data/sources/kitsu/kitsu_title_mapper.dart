import 'dart:convert';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/network/network_error.dart';

class KitsuTitleMapper {
  List<Title> mapList(String body) {
    final decoded = _decode(body);
    final data = decoded['data'];
    if (data is! List) {
      throw const ParseError('Kitsu response missing "data" list');
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
      throw const ParseError('Kitsu detail response missing "data"');
    }
    return _mapItem(data);
  }

  Title? _mapItem(Map<String, dynamic> item) {
    final id = item['id'];
    final attributes = item['attributes'];
    if (id is! String || id.isEmpty) return null;
    if (attributes is! Map<String, dynamic>) return null;

    final canonicalTitle = attributes['canonicalTitle'];
    if (canonicalTitle is! String || canonicalTitle.isEmpty) return null;

    final imageUrl = _posterImageUrl(attributes['posterImage']);
    if (imageUrl == null || imageUrl.isEmpty) return null;

    final rating = attributes['averageRating'];
    return Title(
      id: id,
      source: TitleSource.kitsu,
      kind: item['type'] == 'anime' ? TitleKind.anime : TitleKind.manga,
      title: canonicalTitle,
      imageUrl: imageUrl,
      description: attributes['synopsis'] as String?,
      score: rating is String ? double.tryParse(rating) : null,
      format: attributes['subtype'] as String?,
    );
  }

  String? _posterImageUrl(Object? posterImage) {
    if (posterImage is! Map<String, dynamic>) return null;
    final url = posterImage['original'];
    return url is String ? url : null;
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const ParseError('Kitsu response is not a JSON object');
      }
      return decoded;
    } on FormatException {
      throw const ParseError('Kitsu response is not valid JSON');
    }
  }
}
