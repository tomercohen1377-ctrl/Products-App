import 'package:equatable/equatable.dart';
import 'package:products/src/domain/entities/product_change.dart';

sealed class ProductDetailIntent extends Equatable {
  const ProductDetailIntent();

  @override
  List<Object?> get props => const [];
}

/// Load (or retry loading) the product from the server.
final class ProductDetailStarted extends ProductDetailIntent {
  const ProductDetailStarted();
}

final class ProductDetailEditTapped extends ProductDetailIntent {
  const ProductDetailEditTapped();
}

final class ProductDetailDeleteTapped extends ProductDetailIntent {
  const ProductDetailDeleteTapped();
}

/// The user confirmed the deletion dialog.
final class ProductDetailDeleteConfirmed extends ProductDetailIntent {
  const ProductDetailDeleteConfirmed();
}

final class ProductDetailChangeReceived extends ProductDetailIntent {
  const ProductDetailChangeReceived(this.change);

  final ProductChange change;

  @override
  List<Object?> get props => [change];
}
