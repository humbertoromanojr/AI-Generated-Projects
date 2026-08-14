import 'package:flutter/material.dart';

import 'package:animewhere/app/theme/app_text_theme.dart';
import 'package:animewhere/app/theme/app_theme.dart';
import 'package:animewhere/core/network/network_error.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, required this.onRetry});

  final AppException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingStackMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, color: AppTheme.outline, size: 28),
            const SizedBox(height: AppDimens.spacingStackSm),
            Text(
              friendlyMessageFor(error),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimens.spacingStackSm),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

String friendlyMessageFor(AppException error) {
  return switch (error) {
    NetworkError() => 'No connection. Check your network and try again.',
    RateLimitError() => 'Too many requests. Please wait a moment and retry.',
    HttpError() => 'Something went wrong on our side. Please retry.',
    ParseError() => 'Unexpected data from the service. Please retry.',
  };
}
