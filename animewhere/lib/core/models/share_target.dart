import 'title_source.dart';

class ShareTarget {
  const ShareTarget({
    required this.source,
    required this.id,
    required this.shareUrl,
  });

  final TitleSource source;
  final String id;
  final String shareUrl;
}
