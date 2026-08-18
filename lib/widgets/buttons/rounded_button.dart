// File: lib/widgets/buttons/rounded_button.dart
// Purpose: Highly customizable button supporting solid, gradient, outline styles, and loading indicator.

import 'package:flutter/material.dart';
import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../containers/container_corner.dart';
import '../loaders/app_loader.dart';

enum ButtonVariant { solid, gradient, outline }

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? color;
  final List<Color>? gradientColors;
  final Color? borderColor;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final double iconSpacing;

  const RoundedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.solid,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 48.0,
    this.borderRadius = 8.0,
    this.color,
    this.gradientColors,
    this.borderColor,
    this.textStyle,
    this.padding,
    this.iconSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectivelyDisabled =
        isDisabled || isLoading || onPressed == null;

    // Resolve colors based on status and variants
    Color resolvedColor = Colors.transparent;
    List<Color> resolvedGradient = [Colors.transparent, Colors.transparent];
    Color resolvedBorder = Colors.transparent;
    TextStyle resolvedTextStyle = textStyle ?? AppTextStyles.button;

    if (effectivelyDisabled) {
      resolvedColor = AppColors.border;
      resolvedTextStyle = resolvedTextStyle.copyWith(
        color: AppColors.textSecondary,
      );
    } else {
      switch (variant) {
        case ButtonVariant.gradient:
          resolvedGradient = gradientColors ?? AppColors.primaryGradient;
          resolvedTextStyle = resolvedTextStyle.copyWith(
            color: AppColors.surface,
          );
          break;
        case ButtonVariant.outline:
          resolvedColor = Colors.transparent;
          resolvedBorder = borderColor ?? AppColors.primary;
          resolvedTextStyle = resolvedTextStyle.copyWith(
            color: textStyle?.color ?? (borderColor ?? AppColors.primary),
          );
          break;
        case ButtonVariant.solid:
          resolvedColor = color ?? AppColors.primary;
          resolvedTextStyle = resolvedTextStyle.copyWith(
            color: AppColors.surface,
          );
          break;
      }
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          AppLoader(
            size: 20.0,
            color: resolvedTextStyle.color,
          ),
          SizedBox(width: iconSpacing),
        ] else if (icon != null) ...[
          icon!,
          SizedBox(width: iconSpacing),
        ],
        Text(text, style: resolvedTextStyle),
      ],
    );

    return ContainerCorner(
      width: width,
      height: height,
      color: variant == ButtonVariant.gradient && !effectivelyDisabled
          ? null
          : resolvedColor,
      colors: variant == ButtonVariant.gradient && !effectivelyDisabled
          ? resolvedGradient
          : [Colors.transparent, Colors.transparent],
      borderColor: resolvedBorder,
      borderWidth: 1.5,
      borderRadius: borderRadius,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10.0),
      alignment: Alignment.center,
      onTap: effectivelyDisabled ? null : onPressed,
      child: content,
    );
  }
}
