import 'package:flutter/material.dart';
import 'package:familyapp/design/colors.dart';
import 'package:familyapp/design/spacing.dart';
import 'package:familyapp/design/text_styles.dart';
enum ButtonType{
  primary,
  secondary,
  inverse,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    double width;
    double height;
    TextStyle textStyle;

    switch(type){
      case ButtonType.inverse:
        backgroundColor = AppColors.bgLightGray;
        textColor = AppColors.primary;
        width = 350;
        height = 60;
        textStyle = AppTextStyles.headline2;
        break;
      case ButtonType.secondary:
        backgroundColor = Colors.white;
        textColor = AppColors.textPrimary;
        width = 150;
        height = 60;
        textStyle = AppTextStyles.headline3;
        break;
      default:
        backgroundColor = AppColors.primary;
        textColor = Colors.white;
        width = 350;
        height = 60;
        textStyle = AppTextStyles.headline2;
        break;
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.m,
          horizontal: AppSpacing.s
        ),
        minimumSize: Size(width, height),
      ),
        onPressed: onPressed,
        child: Text(
            text,
            style: textStyle.copyWith(color: textColor),
        ),
    );
  }
}
