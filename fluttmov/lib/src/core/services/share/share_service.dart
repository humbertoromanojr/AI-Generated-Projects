import 'package:share_plus/share_plus.dart';

import '../../../domain/repositories/share_repository.dart';

class ShareService implements ShareRepository {
  @override
  Future<void> shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }
}
