import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:l10n/l10n.dart';
import 'package:products/src/presentation/form/product_form_intent.dart';
import 'package:products/src/presentation/form/product_form_state.dart';
import 'package:products/src/presentation/widgets/product_image_editor.dart';
import 'package:products/testing.dart';

/// The create/edit form. Pure: renders [state] and reports [onIntent].
class ProductFormContent extends StatelessWidget {
  const ProductFormContent({
    required this.state,
    required this.onIntent,
    super.key,
  });

  final ProductFormState state;
  final void Function(ProductFormIntent intent) onIntent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final enabled = !state.isSubmitting;
    final failure = state.submitFailure;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: DSPadding.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DSSpacing.m,
        children: [
          if (failure != null)
            AppBanner(
              message: failure.localized(l10n),
              tone: AppBannerTone.error,
            ),
          AppTextField(
            label: l10n.productFieldTitle,
            initialValue: state.title,
            enabled: enabled,
            errorText: state.titleError?.localized(l10n),
            textInputAction: TextInputAction.next,
            onChanged: (value) => onIntent(ProductFormTitleChanged(value)),
          ),
          AppTextField(
            label: l10n.productFieldPrice,
            initialValue: state.price,
            enabled: enabled,
            errorText: state.priceError?.localized(l10n),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
            ],
            textInputAction: TextInputAction.next,
            onChanged: (value) => onIntent(ProductFormPriceChanged(value)),
          ),
          _CategoryField(state: state, onIntent: onIntent),
          AppTextField(
            label: l10n.productFieldDescription,
            initialValue: state.description,
            enabled: enabled,
            errorText: state.descriptionError?.localized(l10n),
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            onChanged: (value) =>
                onIntent(ProductFormDescriptionChanged(value)),
          ),
          ProductImageEditor(
            images: state.images,
            urlError: state.imageUrlError,
            showRequiredError: state.imagesError != null,
            enabled: enabled,
            onAdd: (url) => onIntent(ProductFormImageAdded(url)),
            onRemove: (url) => onIntent(ProductFormImageRemoved(url)),
          ),
          AppButton(
            label: state.isEditing
                ? l10n.productSubmitSave
                : l10n.productSubmitCreate,
            isLoading: state.isSubmitting,
            onPressed: state.hasCategories
                ? () => onIntent(const ProductFormSubmitted())
                : null,
          ),
        ],
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({required this.state, required this.onIntent});

  final ProductFormState state;
  final void Function(ProductFormIntent intent) onIntent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (state.categories) {
      CategoriesLoading() => const Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: DSSpacing.m),
        child: Center(child: AppLoader.small()),
      ),
      CategoriesFailed(:final failure) => ErrorView(
        failure: failure,
        compact: true,
        onRetry: () => onIntent(const ProductFormStarted()),
      ),
      CategoriesLoaded(:final categories) when categories.isEmpty => AppBanner(
        message: l10n.productCategoriesEmpty,
        tone: AppBannerTone.error,
      ),
      CategoriesLoaded(:final categories) => AppDropdown<int>(
        label: l10n.productFieldCategory,
        value: state.categoryId,
        enabled: !state.isSubmitting,
        errorText: state.categoryError?.localized(l10n),
        items: [
          for (final category in categories)
            AppDropdownItem(value: category.id, label: category.name),
        ],
        onChanged: (id) => onIntent(ProductFormCategorySelected(id)),
      ),
    };
  }
}

const _categories = CategoriesLoaded(categoryFixtures);

Widget _form(ProductFormState state) => SizedBox(
  height: 900,
  child: ProductFormContent(state: state, onIntent: (_) {}),
);

@AppPreviews('ProductFormContent: new')
Widget productFormContentNewPreview() =>
    _form(const ProductFormState(categories: _categories));

@AppPreviews('ProductFormContent: editing')
Widget productFormContentEditingPreview() => _form(
  ProductFormState.editing(productFixture).copyWith(categories: _categories),
);

@AppPreviews('ProductFormContent: validation errors')
Widget productFormContentErrorsPreview() => _form(
  const ProductFormState(
    price: 'abc',
    showErrors: true,
    categories: _categories,
  ),
);

@AppPreviews('ProductFormContent: saving')
Widget productFormContentSavingPreview() => _form(
  ProductFormState.editing(productFixture)
      .copyWith(categories: _categories, submit: const SubmitInProgress()),
);

@AppPreviews('ProductFormContent: server rejected')
Widget productFormContentRejectedPreview() => _form(
  ProductFormState.editing(productFixture).copyWith(
    categories: _categories,
    submit: const SubmitFailed(
      ValidationFailure(messages: ['images must be URLs']),
    ),
  ),
);

@AppPreviews('ProductFormContent: categories loading')
Widget productFormContentCategoriesLoadingPreview() =>
    _form(const ProductFormState());

@AppPreviews('ProductFormContent: categories failed')
Widget productFormContentCategoriesFailedPreview() => _form(
  const ProductFormState(categories: CategoriesFailed(NetworkFailure())),
);

@AppPreviews('ProductFormContent: no categories')
Widget productFormContentNoCategoriesPreview() =>
    _form(const ProductFormState(categories: CategoriesLoaded([])));
