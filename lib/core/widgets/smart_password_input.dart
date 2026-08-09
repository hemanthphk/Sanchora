import 'package:flutter/material.dart';

class PasswordValidator {
  /// Validates the password and returns a helpful suggestion or error message.
  /// Returns null if the password meets all criteria.
  static String? validate(String? value) {
    final pass = value ?? '';
    if (pass.isEmpty) {
      return 'Password is required';
    }
    if (pass.length < 8) {
      return 'Use at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(pass)) {
      return 'Add at least 1 uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(pass)) {
      return 'Add at least 1 lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(pass)) {
      return 'Include a number';
    }
    // Matches any character that is not alphanumeric and not a whitespace
    if (!RegExp(r'[^a-zA-Z0-9\s]').hasMatch(pass)) {
      return 'Add a special character';
    }
    return null;
  }
}

class SmartPasswordInput extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final InputDecoration? decoration;

  const SmartPasswordInput({
    super.key,
    this.controller,
    this.onChanged,
    this.onFieldSubmitted,
    this.onSaved,
    this.textInputAction,
    this.focusNode,
    this.decoration,
  });

  @override
  State<SmartPasswordInput> createState() => _SmartPasswordInputState();
}

class _SmartPasswordInputState extends State<SmartPasswordInput> {
  bool _obscureText = true;
  late TextEditingController _controller;
  String _currentValue = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _currentValue = _controller.text;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (_currentValue != _controller.text) {
      setState(() {
        _currentValue = _controller.text;
      });
      if (widget.onChanged != null) {
        widget.onChanged!(_currentValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = PasswordValidator.validate(_currentValue);

    return TextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      onSaved: widget.onSaved,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: PasswordValidator.validate,
      autovalidateMode: AutovalidateMode.disabled,
      decoration: (widget.decoration ?? const InputDecoration()).copyWith(
        labelText: 'Password',
        helperText: suggestion,
        helperMaxLines: 2,
        errorMaxLines: 2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}
