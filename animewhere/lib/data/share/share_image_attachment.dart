import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareImageAttachment {
  ShareImageAttachment({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<XFile?> attach(String imageUrl) async {
    if (imageUrl.isEmpty) return null;
    try {
      final response = await _client.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) return null;
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/share_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(response.bodyBytes, flush: true);
      return XFile(file.path);
    } on Exception {
      return null;
    }
  }
}
