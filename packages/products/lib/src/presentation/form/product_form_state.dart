import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:products/src/domain/entities/category.dart';
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/domain/entities/product_draft.dart';

sealed class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => const [];
}

final class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

final class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded(this.categories);

  final List<Category> categories;

  @override
  List<Object?> get props => [categories];
}

final class CategoriesFailed extends CategoriesState {
  const CategoriesFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

sealed class SubmitStatus extends Equatable {
  const SubmitStatus();

  @override
  List<Object?> get props => const [];
}

final class SubmitIdle extends SubmitStatus {
  const SubmitIdle();
}

final class SubmitInProgress extends SubmitStatus {
  const SubmitInProgress();
}

final class SubmitFailed extends SubmitStatus {
  const SubmitFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// The create/edit form. Field errors are derived from the values, and only
/// shown after the first submit attempt.
class ProductFormState extends Equatable {
  const ProductFormState({
    this.editingId,
    this.title = '',
    this.price = '',
    this.description = '',
    this.categoryId,
    this.images = const [],
    this.imageUrlError,
    this.showErrors = false,
    this.categories = const CategoriesLoading(),
    this.submit = const SubmitIdle(),
    this.isUploadingImage = false,
    this.imageUploadFailure,
  });

  /// A form pre-filled from an existing product.
  factory ProductFormState.editing(Product product) => ProductFormState(
    editingId: product.id,
    title: product.title,
    price: _priceText(product.price),
    description: product.description,
    categoryId: product.category?.id,
    images: product.images,
  );

  /// Null when creating.
  final int? editingId;
  final String title;
  final String price;
  final String description;
  final int? categoryId;
  final List<String> images;

  /// Why the URL typed into the "add image" field was rejected.
  final FieldError? imageUrlError;
  final bool showErrors;
  final CategoriesState categories;
  final SubmitStatus submit;

  /// A photo is being uploaded to become one of the product's images.
  final bool isUploadingImage;
  final Failure? imageUploadFailure;

  bool get isEditing => editingId != null;
  bool get isSubmitting => submit is SubmitInProgress;
  Failure? get submitFailure => switch (submit) {
    SubmitFailed(:final failure) => failure,
    _ => null,
  };

  /// There is at least one category to put the product in.
  bool get hasCategories => switch (categories) {
    CategoriesLoaded(:final categories) => categories.isNotEmpty,
    _ => false,
  };

  FieldError? get titleError => showErrors ? Validators.required(title) : null;
  FieldError? get priceError => showErrors ? Validators.price(price) : null;
  FieldError? get descriptionError =>
      showErrors ? Validators.required(description) : null;
  FieldError? get categoryError =>
      showErrors && categoryId == null ? FieldError.required : null;
  FieldError? get imagesError =>
      showErrors && images.isEmpty ? FieldError.required : null;

  bool get isValid =>
      Validators.required(title) == null &&
      Validators.price(price) == null &&
      Validators.required(description) == null &&
      categoryId != null &&
      images.isNotEmpty;

  /// The product to send. Only call when [isValid].
  ProductDraft get draft => ProductDraft(
    title: title.trim(),
    price: double.parse(price.trim()),
    description: description.trim(),
    categoryId: categoryId!,
    images: images,
  );

  ProductFormState copyWith({
    String? title,
    String? price,
    String? description,
    Object? categoryId = keep,
    List<String>? images,
    Object? imageUrlError = keep,
    bool? showErrors,
    CategoriesState? categories,
    SubmitStatus? submit,
    bool? isUploadingImage,
    Object? imageUploadFailure = keep,
  }) => ProductFormState(
    editingId: editingId,
    title: title ?? this.title,
    price: price ?? this.price,
    description: description ?? this.description,
    categoryId: valueOrKeep(categoryId, this.categoryId),
    images: images ?? this.images,
    imageUrlError: valueOrKeep(imageUrlError, this.imageUrlError),
    showErrors: showErrors ?? this.showErrors,
    categories: categories ?? this.categories,
    submit: submit ?? this.submit,
    isUploadingImage: isUploadingImage ?? this.isUploadingImage,
    imageUploadFailure: valueOrKeep(
      imageUploadFailure,
      this.imageUploadFailure,
    ),
  );

  static String _priceText(double price) =>
      price % 1 == 0 ? price.toInt().toString() : price.toString();

  @override
  List<Object?> get props => [
    editingId,
    title,
    price,
    description,
    categoryId,
    images,
    imageUrlError,
    showErrors,
    categories,
    submit,
    isUploadingImage,
    imageUploadFailure,
  ];
}
