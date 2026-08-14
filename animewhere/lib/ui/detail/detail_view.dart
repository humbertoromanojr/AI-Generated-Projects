import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Title;
import 'package:provider/provider.dart';

import 'package:animewhere/app/theme/app_text_theme.dart';
import 'package:animewhere/app/theme/app_theme.dart';
import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/network/http_client.dart';
import 'package:animewhere/core/utils/result.dart';
import 'package:animewhere/data/sources/anilist/anilist_api.dart';
import 'package:animewhere/data/sources/jikan/jikan_api.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_api.dart';
import 'package:animewhere/ui/detail/detail_view_model.dart';
import 'package:animewhere/ui/share/share_service.dart';
import 'package:animewhere/ui/widgets/error_view.dart';

class DetailView extends StatefulWidget {
  const DetailView({
    super.key,
    required this.source,
    required this.id,
    this.viewModel,
  });

  final TitleSource source;
  final String id;
  final DetailViewModel? viewModel;

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  late final DetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? _defaultViewModel();
    _viewModel.load(widget.source, widget.id);
  }

  DetailViewModel _defaultViewModel() {
    final httpClient = context.read<AppHttpClient>();
    return DetailViewModel(
      jikanApi: JikanApi(httpClient: httpClient),
      anilistApi: AniListApi(httpClient: httpClient),
      kitsuApi: KitsuApi(httpClient: httpClient),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          return switch (_viewModel.result) {
            Loading() => const Center(child: CircularProgressIndicator()),
            Failure(error: final error) => ErrorView(
              error: error,
              onRetry: () => _viewModel.load(widget.source, widget.id),
            ),
            Data(value: final title) => _DetailContent(
              title: title,
              onShare: () => context.read<ShareService>().shareTitle(title),
            ),
            Empty() => const Center(child: Text('Nothing here yet')),
          };
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.title, required this.onShare});

  final Title title;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.spacingStackMd),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: CachedNetworkImage(
                imageUrl: title.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    const ColoredBox(color: AppTheme.surfaceContainerHigh),
                errorWidget: (_, _, _) => const ColoredBox(
                  color: AppTheme.surfaceContainerHigh,
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.spacingStackMd),
        Text(
          title.title,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface),
        ),
        const SizedBox(height: AppDimens.spacingStackSm),
        Wrap(
          spacing: AppDimens.spacingStackSm,
          runSpacing: AppDimens.spacingStackXs,
          children: [
            if (title.format != null) _MetaChip(label: title.format!),
            if (title.seasonYear != null)
              _MetaChip(label: '${title.seasonYear}'),
            if (title.score != null)
              _MetaChip(label: 'Score ${title.score!.toStringAsFixed(1)}'),
          ],
        ),
        if (title.description != null) ...[
          const SizedBox(height: AppDimens.spacingStackMd),
          Text(
            title.description!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: AppDimens.spacingStackLg),
        FilledButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.share_outlined),
          label: const Text('Share'),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.spacingStackSm,
        vertical: AppDimens.spacingStackXs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant),
      ),
    );
  }
}
