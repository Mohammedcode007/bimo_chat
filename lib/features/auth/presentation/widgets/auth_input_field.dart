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

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final borderColor = hasError
        ? colorScheme.error
        : colorScheme.outline.withValues(alpha: 0.65);

    final textColor = colorScheme.onSurface;
    final hintColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.90);
    final iconColor = hasError ? colorScheme.error : colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: R.size(context, 82),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(R.size(context, 20)),
            border: Border.all(
              color: borderColor,
              width: R.size(context, 1.4),
            ),
            color: Colors.transparent,
          ),
          child: Row(
            children: [
              SizedBox(width: R.size(context, 20)),

              Icon(
                widget.prefixIcon,
                size: R.size(context, 31),
                color: iconColor,
              ),

              SizedBox(width: R.size(context, 17)),

              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: obscureText,
                  keyboardType: widget.keyboardType,
                  style: TextStyle(
                    color: textColor,
                    fontSize: R.sp(context, 22),
                    fontWeight: FontWeight.w500,
                    height: 1.15,
                  ),
                  cursorColor: colorScheme.primary,
                  cursorHeight: R.size(context, 26),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: hintColor,
                      fontSize: R.sp(context, 22),
                      fontWeight: FontWeight.w500,
                      height: 1.15,
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
                Padding(
                  padding: EdgeInsetsDirectional.only(end: R.size(context, 8)),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: R.size(context, 31),
                      color: iconColor,
                    ),
                  ),
                )
              else
                SizedBox(width: R.size(context, 18)),
            ],
          ),
        ),

        if (hasError) ...[
          SizedBox(height: R.size(context, 8)),
          Padding(
            padding: EdgeInsetsDirectional.only(start: R.size(context, 10)),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: R.sp(context, 14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}