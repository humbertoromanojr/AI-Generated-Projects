import 'package:provider/provider.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/share_repository.dart';
import '../../data/sources/anilist/anilist_api.dart';
import '../../data/sources/jikan/jikan_api.dart';
import '../../data/sources/kitsu/kitsu_api.dart';
import '../../ui/home/home_view_model.dart';
import '../../ui/share/share_service.dart';
import '../network/http_client.dart';

final appHttpClientProvider = Provider<AppHttpClient>(
  create: (_) => AppHttpClient(),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  create: (context) => CatalogRepository(
    jikanApi: JikanApi(httpClient: context.read<AppHttpClient>()),
    anilistApi: AniListApi(httpClient: context.read<AppHttpClient>()),
    kitsuApi: KitsuApi(httpClient: context.read<AppHttpClient>()),
  ),
);

final homeViewModelProvider = ChangeNotifierProvider<HomeViewModel>(
  create: (context) {
    final viewModel = HomeViewModel(
      repository: context.read<CatalogRepository>(),
    );
    viewModel.load();
    return viewModel;
  },
);

final shareRepositoryProvider = Provider<ShareRepository>(
  create: (_) => ShareRepository(),
);

final shareServiceProvider = Provider<ShareService>(
  create: (context) =>
      ShareService(repository: context.read<ShareRepository>()),
);
