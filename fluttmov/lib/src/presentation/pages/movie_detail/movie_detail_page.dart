import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/injections/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/image_url_builder.dart';
import '../../../core/utils/rating_formatter.dart';
import '../../../domain/entities/crew_member.dart';
import '../../../domain/entities/movie_details.dart';
import '../../components/cast_list.dart';
import '../../components/error_state_widget.dart';
import '../../components/movie_image.dart';
import '../../components/shimmer_loading.dart';
import '../../viewmodels/movie_detail_viewmodel.dart';

class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({super.key, required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MovieDetailCubit>(param1: movieId)..load(),
      child: const MovieDetailView(),
    );
  }
}

class MovieDetailView extends StatelessWidget {
  const MovieDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieDetailCubit, MovieDetailState>(
      builder: (context, state) {
        switch (state.status) {
          case MovieDetailStatus.initial:
          case MovieDetailStatus.loading:
            return const _DetailLoading();
          case MovieDetailStatus.error:
            return _DetailError(message: state.errorMessage ?? 'Erro ao carregar o filme.');
          case MovieDetailStatus.loaded:
            final details = state.details;
            if (details == null) {
              return _DetailError(message: 'Dados indisponíveis.');
            }
            return _DetailLoaded(details: details, isFavorite: state.isFavorite);
        }
      },
    );
  }
}

class _DetailLoaded extends StatelessWidget {
  const _DetailLoaded({required this.details, required this.isFavorite});

  final MovieDetails details;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MovieDetailCubit>();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailHero(
                    details: details,
                    isFavorite: isFavorite,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.marginMain,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RatingSummary(details: details),
                        _DetailSection(
                          title: 'Sinopse',
                          child: Text(
                            details.movie.overview.isEmpty
                                ? 'Sem sinopse disponível.'
                                : details.movie.overview,
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ),
                        if (cubit.state.credits?.cast.isNotEmpty ?? false)
                          _DetailSection(
                            title: 'Elenco',
                            child: CastList(
                              castMembers: cubit.state.credits!.cast,
                            ),
                          ),
                        if (cubit.state.credits?.director != null)
                          _DetailSection(
                            title: 'Diretor',
                            child: _DirectorRow(
                              director: cubit.state.credits!.director!,
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.marginMain),
                child: _BackButton(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _WatchNowBar(),
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.details, required this.isFavorite});

  final MovieDetails details;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final movie = details.movie;
    final genreNames = details.genres.map((genre) => genre.name).join(', ');
    final year = DateFormatter.year(movie.releaseDate);
    final duration = DateFormatter.duration(details.runtime);

    return SizedBox(
      height: AppConstants.detailHeroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MovieImage(imageUrl: ImageUrlBuilder.backdrop(movie.backdropPath)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
                colors: [
                  AppColors.background.withValues(alpha: 0.0),
                  AppColors.background.withValues(alpha: 0.6),
                  AppColors.background,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.marginMain,
              0,
              AppConstants.marginMain,
              20,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          movie.title,
                          style: AppTypography.headlineLgMobile,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          [
                            if (year.isNotEmpty) year,
                            if (genreNames.isNotEmpty) genreNames,
                            if (duration.isNotEmpty) duration,
                          ].join('  •  '),
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _HeroActions(isFavorite: isFavorite),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({required this.isFavorite});

  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MovieDetailCubit>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: cubit.share,
          icon: const Icon(AppIcons.share, color: AppColors.textPrimary),
        ),
        IconButton(
          onPressed: cubit.toggleFavorite,
          icon: Icon(
            isFavorite ? AppIcons.favorite : AppIcons.favoriteBorder,
            color: isFavorite ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.details});

  final MovieDetails details;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.stackMd),
      child: Row(
        children: [
          const Icon(AppIcons.star, color: AppColors.accent, size: 22),
          const SizedBox(width: 8),
          Text(
            RatingFormatter.label(details.movie.voteAverage),
            style: AppTypography.titleMd,
          ),
          const SizedBox(width: 6),
          Text(
            'Nota TMDB',
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          Container(
            width: 1,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: AppColors.surfaceContainerHigh,
          ),
          const Icon(AppIcons.schedule, color: AppColors.accent, size: 20),
          const SizedBox(width: 8),
          Text(
            DateFormatter.duration(details.runtime),
            style: AppTypography.titleMd,
          ),
          const SizedBox(width: 6),
          Text(
            'Duração',
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.stackMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMd),
          const SizedBox(height: AppConstants.stackSm),
          child,
        ],
      ),
    );
  }
}

class _DirectorRow extends StatelessWidget {
  const _DirectorRow({required this.director});

  final CrewMember director;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(director.name);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: Text(
            initials,
            style: AppTypography.titleMd.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        Text(director.name, style: AppTypography.bodyMd),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: const Icon(AppIcons.back, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _WatchNowBar extends StatelessWidget {
  const _WatchNowBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0),
            AppColors.background,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.marginMain,
        8,
        AppConstants.marginMain,
        20,
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reprodução em breve!')),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AppIcons.play, color: AppColors.onAccent, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Assistir Agora',
                  style: AppTypography.titleMd.copyWith(
                    color: AppColors.onAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: SingleChildScrollView(child: DetailSkeleton()),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.marginMain),
                child: _BackButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ErrorStateWidget(
              message: message,
              onRetry: () => context.read<MovieDetailCubit>().load(),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.marginMain),
                child: _BackButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
