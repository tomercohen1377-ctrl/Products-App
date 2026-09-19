import 'package:equatable/equatable.dart';
import 'package:products/src/domain/entities/product_change.dart';

sealed class ProductsIntent extends Equatable {
  const ProductsIntent();

  @override
  List<Object?> get props => const [];
}

/// First load, or a retry after the first load failed.
final class ProductsStarted extends ProductsIntent {
  const ProductsStarted();
}

/// Pull-to-refresh: reload from the first page, keeping the list on screen.
final class ProductsRefreshed extends ProductsIntent {
  const ProductsRefreshed();
}

/// The user is near the end of the list.
final class ProductsNextPageRequested extends ProductsIntent {
  const ProductsNextPageRequested();
}

/// A create, update or delete elsewhere in the app.
final class ProductsChangeReceived extends ProductsIntent {
  const ProductsChangeReceived(this.change);

  final ProductChange change;

  @override
  List<Object?> get props => [change];
}
