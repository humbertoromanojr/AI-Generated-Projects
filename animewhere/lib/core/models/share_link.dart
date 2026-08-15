import 'title.dart';
import 'title_source.dart';

String canonicalShareLink({
  required TitleSource source,
  required TitleKind kind,
  required String id,
}) {
  if (id.isEmpty) {
    throw ArgumentError.value(id, 'id', 'must not be empty');
  }

  final host = switch (source) {
    TitleSource.jikan => 'myanimelist.net',
    TitleSource.anilist => 'anilist.co',
    TitleSource.kitsu => 'kitsu.io',
  };
  final segment = switch (kind) {
    TitleKind.anime => 'anime',
    TitleKind.manga => 'manga',
  };
  return 'https://$host/$segment/$id';
}
