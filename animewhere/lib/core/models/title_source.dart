enum TitleSource { jikan, anilist, kitsu }

TitleSource? titleSourceFromName(String? name) {
  for (final source in TitleSource.values) {
    if (source.name == name) {
      return source;
    }
  }
  return null;
}
