import 'package:familyapp/design/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:familyapp/design/colors.dart';
import 'package:familyapp/design/spacing.dart';

enum SearchbarType{
  primary,
  secondary,
  inverse
}

class AppSearchbar extends StatelessWidget {
 final String hintText;
 final TextEditingController controller;
 final ValueChanged<String>? onChanged;
 final VoidCallback? onTap;
 final SearchbarType type;

 const AppSearchbar({
   super.key,
   this.hintText = "Search...",
   required this.controller,
   this.onChanged,
   this.onTap,
   this.type = SearchbarType.primary,
});

 @override
  Widget build(BuildContext context) {
   Color backgroundColor;
   Color textColor;
   TextStyle textStyle;

   switch(type){
     case SearchbarType.secondary:
       backgroundColor = Colors.white;
       textColor = AppColors.textPrimary;
       textStyle = AppTextStyles.body;
       break;
     default:
       backgroundColor = AppColors.primary;
       textColor = Colors.white;
       textStyle = AppTextStyles.body;
       break;

   }

    return SearchBar(
      hintText: hintText,
      controller: controller,
      onTap: onTap,
      onChanged: onChanged,
      padding: const WidgetStatePropertyAll<EdgeInsets>(
        EdgeInsets.symmetric(horizontal: AppSpacing.m),
      ),
      leading: Icon(Icons.search, color: textColor),
      backgroundColor: WidgetStatePropertyAll(backgroundColor),
      textStyle: WidgetStatePropertyAll(textStyle.copyWith(color: textColor)),
      side: const WidgetStatePropertyAll(BorderSide(color: Colors.transparent),),
      elevation: const WidgetStatePropertyAll(2),
      shadowColor: const WidgetStatePropertyAll(AppColors.shadow),

    );
  }

}