import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/widgets/state_views.dart';

/// Renders the 4 mandatory states: loading · error · empty · data (CLAUDE.md 3.4).
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.data,
    this.onRetry,
    this.isEmpty,
    this.emptyMessage,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    // Riverpod 3 retries failed providers and reports "loading" meanwhile; show the
    // error as soon as there is one and no data, instead of spinning through retries.
    if (value.hasValue) {
      final v = value.requireValue;
      if (isEmpty?.call(v) ?? false) return EmptyView(message: emptyMessage ?? '');
      return data(v);
    }
    final error = value.error;
    if (error != null) return ErrorView(error: error, onRetry: onRetry);
    return const LoadingView();
  }
}
