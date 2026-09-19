import 'package:design_system/src/previews/app_previews.dart';
import 'package:design_system/src/tokens/ds_spacing.dart';
import 'package:flutter/material.dart';

class AppDropdownItem<T> {
  const AppDropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}

/// The app's only select field. Like [AppTextField], state lives in the bloc:
/// pass the selected [value] and report changes through [onChanged].
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final String label;
  final List<AppDropdownItem<T>> items;

  /// Null when nothing is selected, or when the selection is not in [items].
  final T? value;
  final ValueChanged<T> onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final selectable = items.any((item) => item.value == value);
    return DropdownButtonFormField<T>(
      initialValue: selectable ? value : null,
      isExpanded: true,
      onChanged: enabled
          ? (selected) {
              if (selected != null) onChanged(selected);
            }
          : null,
      items: [
        for (final item in items)
          DropdownMenuItem<T>(
            value: item.value,
            child: Text(item.label, overflow: TextOverflow.ellipsis),
          ),
      ],
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        errorMaxLines: 3,
      ),
    );
  }
}

@AppPreviews('AppDropdown')
Widget appDropdownPreview() => Column(
  spacing: DSSpacing.m,
  children: [
    AppDropdown<int>(
      label: 'Category',
      value: 2,
      items: const [
        AppDropdownItem(value: 1, label: 'Clothes'),
        AppDropdownItem(value: 2, label: 'Electronics'),
      ],
      onChanged: (_) {},
    ),
    AppDropdown<int>(
      label: 'Category',
      value: null,
      errorText: 'This field is required',
      items: const [AppDropdownItem(value: 1, label: 'Clothes')],
      onChanged: (_) {},
    ),
  ],
);
