import 'title_source.dart';

enum TitleKind { anime, manga }

class Title {
  const Title({
    required this.id,
    required this.source,
    required this.kind,
    required this.title,
    required this.imageUrl,
    this.description,
    this.score,
    this.seasonYear,
    this.format,
    this.providerUrl,
  });

  final String id;
  final TitleSource source;
  final TitleKind kind;
  final String title;
  final String imageUrl;
  final String? description;
  final double? score;
  final int? seasonYear;
  final String? format;
  final String? providerUrl;

  bool get isValid => id.isNotEmpty && title.isNotEmpty && imageUrl.isNotEmpty;

  Title copyWith({
    String? id,
    TitleSource? source,
    TitleKind? kind,
    String? title,
    String? imageUrl,
    String? description,
    double? score,
    int? seasonYear,
    String? format,
    String? providerUrl,
  }) {
    return Title(
      id: id ?? this.id,
      source: source ?? this.source,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      score: score ?? this.score,
      seasonYear: seasonYear ?? this.seasonYear,
      format: format ?? this.format,
      providerUrl: providerUrl ?? this.providerUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Title &&
      other.id == id &&
      other.source == source &&
      other.kind == kind &&
      other.title == title &&
      other.imageUrl == imageUrl &&
      other.description == description &&
      other.score == score &&
      other.seasonYear == seasonYear &&
      other.format == format &&
      other.providerUrl == providerUrl;

  @override
  int get hashCode => Object.hash(
    id,
    source,
    kind,
    title,
    imageUrl,
    description,
    score,
    seasonYear,
    format,
    providerUrl,
  );
}
