import 'package:animewhere/core/config/share_config.dart';
import 'package:animewhere/core/models/share_link.dart';
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
      shareUrl: canonicalShareLink(
        source: title.source,
        kind: title.kind,
        id: title.id,
      ),
      titleName: title.title,
      imageUrl: title.imageUrl,
      appName: appName,
      appImageUrl: '$webHost/$_appImagePath',
      downloadUrl: ShareConfig.playStoreDownloadUrl(),
    );
  }
}
