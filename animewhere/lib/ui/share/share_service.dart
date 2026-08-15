import 'package:share_plus/share_plus.dart';

import 'package:animewhere/core/models/share_target.dart';
import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/data/repositories/share_repository.dart';
import 'package:animewhere/data/share/share_image_attachment.dart';

class ShareService {
  ShareService({required this.repository, ShareImageAttachment? attachment})
    : _attachment = attachment ?? ShareImageAttachment();

  final ShareRepository repository;
  final ShareImageAttachment _attachment;

  Future<void> shareTitle(Title title) async {
    final target = repository.targetFor(title);
    final image = await _attachment.attach(target.imageUrl);
    final files = image == null ? null : [image];
    await SharePlus.instance.share(
      ShareParams(text: shareText(target), files: files),
    );
  }

  String shareText(ShareTarget target) {
    return '${target.titleName}\n${target.shareUrl}\n\n'
        'Download the app from the Google Play Store -> ${target.appName}\n'
        '${target.downloadUrl}';
  }
}
