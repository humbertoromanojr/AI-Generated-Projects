import 'package:share_plus/share_plus.dart';

import 'package:animewhere/core/models/share_target.dart';
import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/data/repositories/share_repository.dart';

class ShareService {
  ShareService({required this.repository});

  final ShareRepository repository;

  Future<void> shareTitle(Title title) async {
    final target = repository.targetFor(title);
    await SharePlus.instance.share(ShareParams(text: shareText(target)));
  }

  String shareText(ShareTarget target) {
    return '${target.shareUrl}\n\n${target.appName}\n'
        'Download the app: ${target.downloadUrl}';
  }
}
