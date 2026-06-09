import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';

class AuthInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? errorText;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  late bool obscureText;

  @override
  void initState() {
    super.initState();
    obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final borderColor = colorScheme.outline.withValues(alpha: 0.65);
    final textColor = colorScheme.onSurface;
    final hintColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.90);
    final iconColor = colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: R.size(context, 72),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(R.size(context, 17)),
            border: Border.all(color: borderColor, width: R.size(context, 1.3)),
            color: Colors.transparent,
          ),
          child: Row(
            children: [
              SizedBox(width: R.size(context, 16)),

              Icon(
                widget.prefixIcon,
                size: R.size(context, 27),
                color: iconColor,
              ),

              SizedBox(width: R.size(context, 14)),

              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: obscureText,
                  keyboardType: widget.keyboardType,
                  style: TextStyle(
                    color: textColor,
                    fontSize: R.sp(context, 20),
                    fontWeight: FontWeight.w500,
                  ),
                  cursorColor: colorScheme.primary,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: hintColor,
                      fontSize: R.sp(context, 20),
                      fontWeight: FontWeight.w500,
                    ),
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              if (widget.isPassword)
                IconButton(
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: R.size(context, 28),
                    color: iconColor,
                  ),
                )
              else
                SizedBox(width: R.size(context, 12)),
            ],
          ),
        ),

        if (widget.errorText != null) ...[
          SizedBox(height: R.size(context, 7)),
          Padding(
            padding: EdgeInsetsDirectional.only(start: R.size(context, 8)),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: R.sp(context, 13),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
