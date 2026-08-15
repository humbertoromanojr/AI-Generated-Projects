import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:animewhere/data/share/share_image_attachment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  const channel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('animewhere_share_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getTemporaryDirectory') return tempDir.path;
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('returns an XFile for a successful image download', () async {
    final attachment = ShareImageAttachment(
      client: MockClient(
        (request) async => http.Response.bytes([1, 2, 3, 4], 200),
      ),
    );

    final file = await attachment.attach('https://cdn.example.com/poster.jpg');

    expect(file, isNotNull);
    expect(await file!.readAsBytes(), [1, 2, 3, 4]);
    expect(File(file.path).existsSync(), isTrue);
  });

  test('returns null on a non-200 response', () async {
    final attachment = ShareImageAttachment(
      client: MockClient((request) async => http.Response('Not Found', 404)),
    );

    expect(
      await attachment.attach('https://cdn.example.com/poster.jpg'),
      isNull,
    );
  });

  test('returns null when the download throws', () async {
    final attachment = ShareImageAttachment(
      client: MockClient((request) async => throw http.ClientException('boom')),
    );

    expect(
      await attachment.attach('https://cdn.example.com/poster.jpg'),
      isNull,
    );
  });

  test('returns null for an empty image URL', () async {
    final attachment = ShareImageAttachment(
      client: MockClient((request) async => http.Response.bytes([1], 200)),
    );

    expect(await attachment.attach(''), isNull);
  });
}
