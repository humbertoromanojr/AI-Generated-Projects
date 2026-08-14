import 'package:animewhere/core/models/share_target.dart';
import 'package:animewhere/core/models/title.dart';

class ShareRepository {
  ShareRepository({this.webHost = defaultWebHost});

  static const String defaultWebHost = 'https://animewhere.app';

  final String webHost;

  ShareTarget targetFor(Title title) {
    return ShareTarget(
      source: title.source,
      id: title.id,
      shareUrl: '$webHost/title/${title.source.name}/${title.id}',
    );
  }
}
