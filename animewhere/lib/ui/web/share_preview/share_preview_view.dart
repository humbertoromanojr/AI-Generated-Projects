import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Title;

import 'package:animewhere/app/theme/app_text_theme.dart';
import 'package:animewhere/app/theme/app_theme.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/utils/result.dart';
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
          return switch (_viewModel.result) {
            Loading() => const Center(child: CircularProgressIndicator()),
            Failure(error: final error) => ErrorView(
              error: error,
              onRetry: () => _viewModel.load(widget.source, widget.id),
            ),
            Data(value: final title) => _PosterPreview(
              imageUrl: title.imageUrl,
            ),
            Empty() => const Center(child: Text('Nothing here yet')),
          };
        },
      ),
    );
  }
}

class _PosterPreview extends StatelessWidget {
  const _PosterPreview({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
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
          Text(
            'AnimeWhere',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.onSurface),
          ),
        ],
      ),
    );
  }
}
