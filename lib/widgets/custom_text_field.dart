import 'package:flutter/material.dart';
import 'package:project_resendis/styles/app_colors.dart';
import 'package:project_resendis/styles/dimensions.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool enableSuggestions;
  final bool autocorrect;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.enableSuggestions = true,
    this.autocorrect = true,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: _isFocused ? [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText && !_showPassword,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        enableSuggestions: widget.enableSuggestions,
        autocorrect: widget.autocorrect,
        onTap: () => setState(() => _isFocused = true),
        onFieldSubmitted: (_) => setState(() => _isFocused = false),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon != null 
              ? Icon(widget.prefixIcon, color: _isFocused 
                  ? AppColors.primaryColor 
                  : isDark ? Colors.white70 : Colors.black54) 
              : null,
          suffixIcon: widget.obscureText 
              ? IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ) 
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            borderSide: BorderSide(
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            borderSide: BorderSide(
              color: AppColors.primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: isDark 
              ? Colors.grey[800] 
              : Colors.grey[50],
        ),
      ),
    );
  }
}