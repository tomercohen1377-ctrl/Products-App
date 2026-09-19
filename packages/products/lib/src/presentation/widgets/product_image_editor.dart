import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:products/testing.dart';

/// The image list of the product form: thumbnails with a remove button, and
/// an "add by URL" field. The typed text is local UI state; it clears itself
/// when an image was actually added.
class ProductImageEditor extends StatefulWidget {
  const ProductImageEditor({
    required this.images,
    required this.onAdd,
    required this.onRemove,
    this.onUpload,
    this.isUploading = false,
    this.uploadFailure,
    this.urlError,
    this.showRequiredError = false,
    this.enabled = true,
    super.key,
  });

  final List<String> images;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  /// Choose a photo and upload it; null hides the button.
  final VoidCallback? onUpload;
  final bool isUploading;
  final Failure? uploadFailure;

  /// Why the typed URL was rejected.
  final FieldError? urlError;

  /// The list is empty and the form insists on at least one image.
  final bool showRequiredError;
  final bool enabled;

  @override
  State<ProductImageEditor> createState() => _ProductImageEditorState();
}

class _ProductImageEditorState extends State<ProductImageEditor> {
  final TextEditingController _controller = TextEditingController();

  @override
  void didUpdateWidget(ProductImageEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images.length > oldWidget.images.length) _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.dsColors;
    final typography = context.dsTypography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DSSpacing.s,
      children: [
        Text(l10n.productImagesTitle, style: typography.bodyStrong()),
        if (widget.images.isNotEmpty)
          SizedBox(
            height: DSDimensions.thumbnail + DSSpacing.xs,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: widget.images.length,
              separatorBuilder: (_, _) => const SizedBox(width: DSSpacing.s),
              itemBuilder: (context, index) => _Thumbnail(
                url: widget.images[index],
                enabled: widget.enabled,
                onRemove: () => widget.onRemove(widget.images[index]),
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DSSpacing.xs,
          children: [
            Expanded(
              child: AppTextField(
                label: l10n.productImageUrlLabel,
                controller: _controller,
                enabled: widget.enabled,
                errorText: widget.urlError?.localized(l10n),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onSubmitted: widget.onAdd,
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(top: DSSpacing.xxs),
              child: IconButton.filled(
                tooltip: l10n.productImageAdd,
                icon: const Icon(Icons.add_rounded),
                onPressed: widget.enabled
                    ? () => widget.onAdd(_controller.text)
                    : null,
              ),
            ),
          ],
        ),
        if (widget.onUpload != null)
          AppButton(
            label: l10n.productImageUpload,
            icon: Icons.photo_library_outlined,
            variant: AppButtonVariant.secondary,
            expand: false,
            isLoading: widget.isUploading,
            onPressed: widget.enabled ? widget.onUpload : null,
          ),
        if (widget.uploadFailure != null)
          AppBanner(
            message: widget.uploadFailure!.localized(l10n),
            tone: AppBannerTone.error,
          ),
        if (widget.showRequiredError)
          Text(
            l10n.productImagesRequired,
            style: typography.caption(color: colors.error),
          ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.url,
    required this.enabled,
    required this.onRemove,
  });

  final String url;
  final bool enabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.dsColors;
    return SizedBox.square(
      dimension: DSDimensions.thumbnail,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          AppNetworkImage(url: url, borderRadius: DSCornerRadius.mAll),
          PositionedDirectional(
            top: -DSSpacing.xs,
            end: -DSSpacing.xs,
            child: IconButton.filled(
              tooltip: context.l10n.productImageRemove,
              iconSize: DSDimensions.iconS,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                backgroundColor: colors.txtPrimary,
                foregroundColor: colors.bgSecondary,
              ),
              icon: const Icon(Icons.close_rounded),
              onPressed: enabled ? onRemove : null,
            ),
          ),
        ],
      ),
    );
  }
}

@AppPreviews('ProductImageEditor')
Widget productImageEditorPreview() => Column(
  spacing: DSSpacing.l,
  children: [
    ProductImageEditor(
      images: productFixture.images,
      onAdd: (_) {},
      onRemove: (_) {},
    ),
    ProductImageEditor(
      images: const [],
      showRequiredError: true,
      onAdd: (_) {},
      onRemove: (_) {},
    ),
    ProductImageEditor(
      images: const [],
      urlError: FieldError.invalidUrl,
      onAdd: (_) {},
      onRemove: (_) {},
    ),
    ProductImageEditor(
      images: productFixture.images,
      isUploading: true,
      onUpload: () {},
      onAdd: (_) {},
      onRemove: (_) {},
    ),
    ProductImageEditor(
      images: const [],
      onUpload: () {},
      uploadFailure: const NetworkFailure(),
      onAdd: (_) {},
      onRemove: (_) {},
    ),
  ],
);
