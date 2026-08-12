import 'package:share_plus/share_plus.dart';

import '../config/api_config.dart';

class ShareService {
  Future<void> shareMovie({
    required int movieId,
    required String title,
  }) async {
    final message =
        'Olha esse filme que encontrei no FLUTTMOV: $title - '
        '${ApiConfig.moviePageUrl}$movieId '
        'Baixe o app: ${ApiConfig.appDownloadUrl}';
    await SharePlus.instance.share(ShareParams(text: message));
  }
}
