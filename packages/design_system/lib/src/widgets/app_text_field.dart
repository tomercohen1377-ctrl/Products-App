import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/tokens/ds_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:l10n/l10n.dart';

/// The app's only text input. State lives in the bloc: pass the current
/// validation message as [errorText] and report edits through [onChanged].
///
/// [initialValue] seeds an internally owned controller (edit forms); pass
/// [controller] instead when the parent needs to clear or set the text.
class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.label,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.prefixIcon,
    super.key,
  }) : assert(
         initialValue == null || controller == null,
         'Provide initialValue or controller, not both.',
       );

  final String label;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;

  /// Hides the text and adds a show/hide toggle.
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final IconData? prefixIcon;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController(text: widget.initialValue);
  late bool _obscured = widget.obscureText;

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      obscureText: _obscured,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        errorMaxLines: 3,
        prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _obscured ? l10n.showPassword : l10n.hidePassword,
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}

@AppPreviews('AppTextField')
Widget appTextFieldPreview() => const Column(
  spacing: DSSpacing.m,
  children: [
    AppTextField(label: 'Email', prefixIcon: Icons.mail_outline),
    AppTextField(label: 'Title', initialValue: 'Classic Red Pullover Hoodie'),
    AppTextField(
      label: 'Password',
      obscureText: true,
      initialValue: 'changeme',
    ),
    AppTextField(
      label: 'Price',
      initialValue: 'abc',
      errorText: 'Enter a valid number',
    ),
    AppTextField(label: 'Disabled', enabled: false, initialValue: 'Read only'),
  ],
);
