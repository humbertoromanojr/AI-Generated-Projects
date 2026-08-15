import 'title_source.dart';

class ShareTarget {
  const ShareTarget({
    required this.source,
    required this.id,
    required this.shareUrl,
    required this.titleName,
    required this.imageUrl,
    required this.appName,
    required this.appImageUrl,
    required this.downloadUrl,
  });

  final TitleSource source;
  final String id;
  final String shareUrl;
  final String titleName;
  final String imageUrl;
  final String appName;
  final String appImageUrl;
  final String downloadUrl;
}
