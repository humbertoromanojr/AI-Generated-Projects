class AniListQueries {
  AniListQueries._();

  static const String pageQuery = r'''
query ($perPage: Int, $sort: [MediaSort]) {
  Page(perPage: $perPage) {
    media(type: ANIME, sort: $sort) {
      id
      title {
        romaji
        english
      }
      coverImage {
        large
      }
      description
      averageScore
      format
      seasonYear
    }
  }
}
''';

  static const String mediaQuery = r'''
query ($id: Int) {
  Media(id: $id) {
    id
    title {
      romaji
      english
    }
    coverImage {
      large
    }
    description
    averageScore
    format
    seasonYear
  }
}
''';
}
