import 'package:flutter/material.dart';
import 'package:animewhere/core/models/title.dart' as model;
import 'package:animewhere/ui/widgets/title_card.dart';

class InfiniteTitleRow extends StatefulWidget {
  const InfiniteTitleRow({
    super.key,
    required this.titles,
    required this.label,
    required this.hasMore,
    required this.isLoadingMore,
    required this.loadFailed,
    required this.onLoadMore,
    required this.onTitleTap,
    required this.onTitleShare,
    required this.onRetry,
  });

  final List<model.Title> titles;
  final String label;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadFailed;
  final VoidCallback onLoadMore;
  final void Function(model.Title title)? onTitleTap;
  final void Function(model.Title title)? onTitleShare;
  final VoidCallback onRetry;

  @override
  State<InfiniteTitleRow> createState() => _InfiniteTitleRowState();
}

class _InfiniteTitleRowState extends State<InfiniteTitleRow> {
  static const double _loadThreshold = 200;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (!widget.hasMore || widget.isLoadingMore || widget.loadFailed) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;
    if (position.pixels >= position.maxScrollExtent - _loadThreshold) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.titles.isEmpty && !widget.isLoadingMore && !widget.loadFailed) {
      return _buildEmptyState(context, widget.label);
    }

    if (widget.titles.isEmpty && widget.isLoadingMore) {
      return _buildLoadingRow(context, widget.label);
    }

    if (widget.titles.isEmpty && widget.loadFailed) {
      return _buildErrorRow(context, widget.label);
    }

    return _buildTitleList(context);
  }

  Widget _buildEmptyState(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'No titles',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingRow(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Expanded(child: LinearProgressIndicator()),
              SizedBox(width: 8),
              Text(
                'Loading more',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorRow(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: widget.onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleList(BuildContext context) {
    final trailing = _buildTrailing(context);
    final itemCount = widget.titles.length + (trailing == null ? 0 : 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            widget.label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(
          height: _rowHeight,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= widget.titles.length) {
                return trailing!;
              }
              final title = widget.titles[index];
              return TitleCard(
                title: title,
                width: 120,
                onTap: () => widget.onTitleTap?.call(title),
                onShare: widget.onTitleShare == null
                    ? null
                    : () => widget.onTitleShare!(title),
              );
            },
          ),
        ),
      ],
    );
  }

  static const double _rowHeight = 220;

  Widget? _buildTrailing(BuildContext context) {
    if (widget.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 70),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    if (widget.loadFailed) {
      return Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 70),
            child: FilledButton.tonal(
              onPressed: widget.onLoadMore,
              child: const Text('Retry'),
            ),
          ),
        ),
      );
    }

    if (!widget.hasMore) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 90, left: 8),
          child: Text(
            'End of catalog',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return null;
  }
}
