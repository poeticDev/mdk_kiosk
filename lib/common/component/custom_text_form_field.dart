import 'package:flutter/material.dart';
import 'package:mdk_kiosk/common/const/colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String? title;
  final String? initialValue;
  final bool isReadOnly;
  final TextInputType textInputType;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String> onChanged;

  const CustomTextFormField({
    super.key,
    this.title,
    this.initialValue,
    this.isReadOnly = false,
    this.textInputType = TextInputType.text,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.autofocus = false,
    required this.onChanged,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant CustomTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Text(widget.title!,
              style: TextStyle(
                  color: TEXT_COLOR,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600)),
        if (widget.title != null) SizedBox(height: 6.0),
        TextFormField(
          controller: _controller,
          readOnly: widget.isReadOnly,
          keyboardType: widget.textInputType,
          cursorColor: TEXT_COLOR,
          obscureText: widget.obscureText,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(16),
            hintText: widget.hintText,
            errorText: widget.errorText,
            hintStyle: TextStyle(
              color: BODY_TEXT_COLOR,
              fontSize: 14.0,
            ),
            fillColor: INPUT_BG_COLOR,
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: INPUT_BORDER_COLOR,
                width: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

