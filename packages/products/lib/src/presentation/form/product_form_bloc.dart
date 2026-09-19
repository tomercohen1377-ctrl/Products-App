import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show Emitter;
import 'package:products/src/domain/entities/product.dart';
import 'package:products/src/domain/repositories/products_repository.dart';
import 'package:products/src/domain/services/photo_picker.dart';
import 'package:products/src/presentation/form/product_form_effect.dart';
import 'package:products/src/presentation/form/product_form_intent.dart';
import 'package:products/src/presentation/form/product_form_state.dart';

/// Creates a product, or edits [editing] when given.
class ProductFormBloc
    extends MviBloc<ProductFormIntent, ProductFormState, ProductFormEffect> {
  ProductFormBloc(this._repository, this._photoPicker, {Product? editing})
    : super(
        editing == null
            ? const ProductFormState()
            : ProductFormState.editing(editing),
      ) {
    on<ProductFormStarted>(_onStarted, transformer: droppable());
    on<ProductFormTitleChanged>(
      (intent, emit) => emit(_edited(title: intent.title)),
    );
    on<ProductFormPriceChanged>(
      (intent, emit) => emit(_edited(price: intent.price)),
    );
    on<ProductFormDescriptionChanged>(
      (intent, emit) => emit(_edited(description: intent.description)),
    );
    on<ProductFormCategorySelected>(
      (intent, emit) => emit(_edited(categoryId: intent.categoryId)),
    );
    on<ProductFormImageAdded>(_onImageAdded);
    on<ProductFormImageRemoved>(
      (intent, emit) => emit(
        _edited(
          images: [
            for (final url in state.images)
              if (url != intent.url) url,
          ],
        ),
      ),
    );
    // Droppable: a second tap while the picker or upload is busy is ignored.
    on<ProductFormPhotoUploadRequested>(
      _onPhotoUploadRequested,
      transformer: droppable(),
    );
    // Droppable: a double tap must not create the product twice.
    on<ProductFormSubmitted>(_onSubmitted, transformer: droppable());
  }

  final ProductsRepository _repository;
  final PhotoPicker _photoPicker;

  /// A field edit: applies it and hides a previous submit failure.
  ProductFormState _edited({
    String? title,
    String? price,
    String? description,
    int? categoryId,
    List<String>? images,
  }) => state.copyWith(
    title: title,
    price: price,
    description: description,
    categoryId: categoryId ?? keep,
    images: images,
    submit: const SubmitIdle(),
  );

  Future<void> _onStarted(
    ProductFormStarted intent,
    Emitter<ProductFormState> emit,
  ) async {
    emit(state.copyWith(categories: const CategoriesLoading()));
    final result = await _repository.getCategories();
    emit(
      state.copyWith(
        categories: switch (result) {
          Success(:final value) => CategoriesLoaded(value),
          Failed(:final failure) => CategoriesFailed(failure),
        },
      ),
    );
  }

  void _onImageAdded(
    ProductFormImageAdded intent,
    Emitter<ProductFormState> emit,
  ) {
    final url = intent.url.trim();
    final error = Validators.httpUrl(url);
    if (error != null) {
      emit(state.copyWith(imageUrlError: error));
      return;
    }
    if (state.images.contains(url)) {
      emit(state.copyWith(imageUrlError: null));
      return;
    }
    emit(_edited(images: [...state.images, url]).copyWith(imageUrlError: null));
  }

  Future<void> _onPhotoUploadRequested(
    ProductFormPhotoUploadRequested intent,
    Emitter<ProductFormState> emit,
  ) async {
    final photo = await _photoPicker.pickFromGallery();
    if (photo == null) return;

    emit(state.copyWith(isUploadingImage: true, imageUploadFailure: null));
    final result = await _repository.uploadImage(photo);
    switch (result) {
      case Success(:final value):
        emit(
          _edited(
            images: [...state.images, if (!state.images.contains(value)) value],
          ).copyWith(isUploadingImage: false),
        );
      case Failed(:final failure):
        emit(
          state.copyWith(isUploadingImage: false, imageUploadFailure: failure),
        );
    }
  }

  Future<void> _onSubmitted(
    ProductFormSubmitted intent,
    Emitter<ProductFormState> emit,
  ) async {
    if (!state.hasCategories) return;
    if (!state.isValid) {
      emit(state.copyWith(showErrors: true));
      return;
    }

    emit(state.copyWith(showErrors: true, submit: const SubmitInProgress()));
    final draft = state.draft;
    final editingId = state.editingId;
    final result = editingId == null
        ? await _repository.createProduct(draft)
        : await _repository.updateProduct(editingId, draft);

    switch (result) {
      case Success(:final value):
        emit(state.copyWith(submit: const SubmitIdle()));
        emitEffect(ProductSaved(value));
      case Failed(:final failure):
        emit(state.copyWith(submit: SubmitFailed(failure)));
    }
  }
}
