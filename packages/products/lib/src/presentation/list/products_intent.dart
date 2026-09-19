import 'package:design_system/design_system.dart' show SwipeDirection;
import 'package:equatable/equatable.dart';
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/domain/entities/product_change.dart';
import 'package:products/src/presentation/list/products_state.dart';

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

/// The user tapped a product.
final class ProductSelected extends ProductsIntent {
  const ProductSelected(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

/// The user wants to create a product.
final class AddProductRequested extends ProductsIntent {
  const AddProductRequested();
}

final class ProductsViewModeChanged extends ProductsIntent {
  const ProductsViewModeChanged(this.mode);

  final ProductsViewMode mode;

  @override
  List<Object?> get props => [mode];
}

/// A deck card was thrown: right likes the product, either way dismisses it.
final class ProductSwiped extends ProductsIntent {
  const ProductSwiped(this.product, this.direction);

  final Product product;
  final SwipeDirection direction;

  @override
  List<Object?> get props => [product, direction];
}

/// Bring the dismissed cards back to go through the deck again.
final class ProductsDeckRestarted extends ProductsIntent {
  const ProductsDeckRestarted();
}
