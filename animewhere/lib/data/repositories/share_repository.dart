import 'package:animewhere/core/models/share_target.dart';
import 'package:animewhere/core/models/title.dart';

class ShareRepository {
  ShareRepository({this.webHost = defaultWebHost});

  static const String defaultWebHost = 'https://animewhere.app';
  static const String appName = 'AW - AnimeWhere';
  static const String _appImagePath = 'assets/icons/animeWhere.png';

  final String webHost;

  ShareTarget targetFor(Title title) {
    return ShareTarget(
      source: title.source,
      id: title.id,
      shareUrl: '$webHost/title/${title.source.name}/${title.id}',
      appName: appName,
      appImageUrl: '$webHost/$_appImagePath',
      downloadUrl: '$webHost/download',
    );
  }
}
