import 'package:flutter/foundation.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/core/utils/result.dart';
import 'package:animewhere/data/sources/anilist/anilist_api.dart';
import 'package:animewhere/data/sources/jikan/jikan_api.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_api.dart';

class SharePreviewViewModel extends ChangeNotifier {
  SharePreviewViewModel({
    required this._jikanApi,
    required this._anilistApi,
    required this._kitsuApi,
  });

  final JikanApi _jikanApi;
  final AniListApi _anilistApi;
  final KitsuApi _kitsuApi;

  Result<Title> result = const Loading();

  Future<void> load(TitleSource source, String id) async {
    result = const Loading();
    notifyListeners();

    final Title title;
    try {
      title = switch (source) {
        TitleSource.jikan => await _jikanApi.detail(int.parse(id)),
        TitleSource.anilist => await _anilistApi.detail(int.parse(id)),
        TitleSource.kitsu => await _kitsuApi.detail(id),
      };
    } catch (error) {
      result = Failure<Title>(_toAppException(error));
      notifyListeners();
      return;
    }

    result = Data(title);
    notifyListeners();
  }

  AppException _toAppException(Object error) {
    if (error is AppException) return error;
    return const ParseError('Unexpected error while loading the title');
  }
}
