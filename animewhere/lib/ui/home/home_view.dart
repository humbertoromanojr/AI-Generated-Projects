import 'package:flutter/material.dart' hide Title;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:animewhere/app/theme/app_text_theme.dart';
import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/ui/home/home_view_model.dart';
import 'package:animewhere/ui/home/widgets/title_carousel.dart';
import 'package:animewhere/ui/home/widgets/title_row.dart';
import 'package:animewhere/ui/share/share_service.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, this.viewModel});

  final HomeViewModel? viewModel;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel ?? context.watch<HomeViewModel>();

    return Scaffold(
      body: AnimatedBuilder(
        animation: vm,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: vm.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: AppDimens.spacingStackMd),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spacingMarginMobile,
                  ),
                  child: Text(
                    'AnimeWhere',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: AppDimens.spacingStackMd),
                TitleCarousel(
                  result: vm.carousel,
                  onTitleTap: (title) => _openTitle(context, title),
                  onTitleShare: (title) => _shareTitle(context, title),
                  onRetry: vm.refresh,
                ),
                const SizedBox(height: AppDimens.spacingStackLg),
                for (final row in vm.rows)
                  TitleRow(
                    label: row.label,
                    result: row.result,
                    onTitleTap: (title) => _openTitle(context, title),
                    onTitleShare: (title) => _shareTitle(context, title),
                    onRetry: vm.refresh,
                  ),
                const SizedBox(height: AppDimens.spacingStackLg),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openTitle(BuildContext context, Title title) {
    context.push('/title/${title.source.name}/${title.id}');
  }

  Future<void> _shareTitle(BuildContext context, Title title) async {
    await context.read<ShareService>().shareTitle(title);
  }
}
