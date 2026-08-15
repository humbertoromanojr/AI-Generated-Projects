import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:flutter/services.dart';

import 'package:animewhere/app/theme/app_text_theme.dart';
import 'package:animewhere/app/theme/app_theme.dart';
import 'package:animewhere/core/models/title.dart' as model;
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/utils/result.dart';
import 'package:animewhere/data/repositories/share_repository.dart';
import 'package:animewhere/data/sources/anilist/anilist_api.dart';
import 'package:animewhere/data/sources/jikan/jikan_api.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_api.dart';
import 'package:animewhere/ui/web/share_preview/share_preview_view_model.dart';
import 'package:animewhere/ui/widgets/error_view.dart';

class SharePreviewView extends StatefulWidget {
  const SharePreviewView({
    super.key,
    required this.source,
    required this.id,
    this.viewModel,
  });

  final TitleSource source;
  final String id;
  final SharePreviewViewModel? viewModel;

  @override
  State<SharePreviewView> createState() => _SharePreviewViewState();
}

class _SharePreviewViewState extends State<SharePreviewView> {
  late final SharePreviewViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel =
        widget.viewModel ??
        SharePreviewViewModel(
          jikanApi: JikanApi(),
          anilistApi: AniListApi(),
          kitsuApi: KitsuApi(),
        );
    _viewModel.load(widget.source, widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          final result = _viewModel.result;
          if (result is Data<model.Title>) {
            final target = ShareRepository().targetFor(result.value);
            return _PosterPreview(
              imageUrl: result.value.imageUrl,
              appImageUrl: target.appImageUrl,
              appName: target.appName,
              downloadUrl: target.downloadUrl,
            );
          }
          return switch (result) {
            Loading() => const Center(child: CircularProgressIndicator()),
            Failure(error: final error) => ErrorView(
              error: error,
              onRetry: () => _viewModel.load(widget.source, widget.id),
            ),
            Empty() => const Center(child: Text('Nothing here yet')),
            Data() => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _PosterPreview extends StatelessWidget {
  const _PosterPreview({
    required this.imageUrl,
    required this.appImageUrl,
    required this.appName,
    required this.downloadUrl,
  });

  final String imageUrl;
  final String appImageUrl;
  final String appName;
  final String downloadUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.spacingStackMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const ColoredBox(color: AppTheme.surfaceContainerLow),
                  errorWidget: (_, _, _) => const ColoredBox(
                    color: AppTheme.surfaceContainerLow,
                    child: Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.spacingStackLg),
            CachedNetworkImage(
              key: const Key('app-branding-image'),
              imageUrl: appImageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => const Icon(Icons.ondemand_video),
            ),
            const SizedBox(height: AppDimens.spacingStackSm),
            Text(
              appName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.onSurface),
            ),
            const SizedBox(height: AppDimens.spacingStackSm),
            TextButton.icon(
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: downloadUrl)),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Download the app'),
            ),
          ],
        ),
      ),
    );
  }
}
