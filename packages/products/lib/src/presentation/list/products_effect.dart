import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

sealed class ProductsEffect extends Equatable {
  const ProductsEffect();

  @override
  List<Object?> get props => const [];
}

/// A pull-to-refresh failed; the list stays as it was.
final class ProductsRefreshFailed extends ProductsEffect {
  const ProductsRefreshFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
