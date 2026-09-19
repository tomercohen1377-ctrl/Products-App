import 'package:core/core.dart';
import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/widgets/app_loader.dart';
import 'package:design_system/src/widgets/empty_view.dart';
import 'package:design_system/src/widgets/error_view.dart';
import 'package:flutter/widgets.dart';

enum _Phase { failure, loading, empty, content }

/// Switches between failure, loading, empty and content with a short
/// cross-fade. Precedence: failure, then loading, then empty, then [child].
///
/// Callers derive the flags from their bloc state (e.g. only pass a
/// [failure] when there is no content to keep showing).
class AsyncContent extends StatelessWidget {
  const AsyncContent({
    required this.child,
    this.isLoading = false,
    this.failure,
    this.isEmpty = false,
    this.onRetry,
    this.empty,
    super.key,
  });

  final Widget child;
  final bool isLoading;
  final Failure? failure;
  final bool isEmpty;
  final VoidCallback? onRetry;

  /// Replaces the default [EmptyView].
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    final failure = this.failure;
    final (phase, view) = switch ((failure, isLoading, isEmpty)) {
      (final Failure f, _, _) => (
        _Phase.failure,
        ErrorView(failure: f, onRetry: onRetry),
      ),
      (_, true, _) => (_Phase.loading, const AppLoader()),
      (_, _, true) => (_Phase.empty, empty ?? const EmptyView()),
      _ => (_Phase.content, child),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: KeyedSubtree(key: ValueKey(phase), child: view),
    );
  }
}

@AppPreviews('AsyncContent')
Widget asyncContentPreview() => const SizedBox(
  height: 220,
  child: AsyncContent(isLoading: true, child: Text('content')),
);
