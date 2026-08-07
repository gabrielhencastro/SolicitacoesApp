import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helpers/theme_extensions.dart';

class MyTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;

  final String? Function(String?)? validator;
  final Function(String?)? onChanged;

  const MyTextInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.readOnly,
    this.inputFormatters,
    this.maxLength,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: context.colors.primary.withValues(alpha: 0.5)
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: readOnly? context.colors.primary.withValues(alpha: 0.1) : context.colors.primary.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: readOnly? context.colors.primary.withValues(alpha: 0.1) : context.colors.primary.withValues(alpha: 0.5)),
        ),
        errorMaxLines: 3,
        errorStyle: TextStyle()
      ),
    );
  }
}