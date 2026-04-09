import 'package:flutter/material.dart';
import 'package:familyapp/design/colors.dart';
import 'package:familyapp/design/text_styles.dart';


class AppBarStyles{

  static AppBar auth({
    required String title,
  }){
    return AppBar(
      backgroundColor: AppColors.primary,
        centerTitle: true,
      title: Text(
          title,
      style:
        AppTextStyles.headline1.copyWith(color: Colors.white),),
      elevation:2,
    );
  }

  static AppBar subpage ({
    required String title,
    required VoidCallback onBack
}){
    return AppBar(
      backgroundColor: AppColors.bgLightGray,
      leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary,)
      ),
      centerTitle: true,
      title:Text(
        title,
        style:
          AppTextStyles.headline1.copyWith(color: AppColors.textPrimary),
      ),
      elevation: 2,
    );
  }

  static AppBar dashboard ({
    required String title,
    required VoidCallback onProfile,
  }){
    return AppBar(
      backgroundColor: AppColors.primary,
      leading: IconButton(
        onPressed: onProfile,
        icon: const Icon(Icons.settings, color: AppColors.textPrimary,),
      ),
      centerTitle: true,
      title:Text(
        title,
        style:
        AppTextStyles.headline1.copyWith(color: AppColors.textPrimary),
      ),
      elevation: 2,
    );
  }

  static AppBar functions ({
    required String title,
    required VoidCallback onBack
  }){
    return AppBar(
      backgroundColor: AppColors.primary,
      leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary,)
      ),
      centerTitle: true,
      title:Text(
        title,
        style:
        AppTextStyles.headline1.copyWith(color: AppColors.textPrimary),
      ),
      elevation: 2,
    );
  }

  static AppBar functionsNewEdit ({
    required String title,
    required VoidCallback onBack,
    List<Widget>? actions
  }){
    return AppBar(
      backgroundColor: AppColors.primary,
      actions: actions,
      leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary,)
      ),
      centerTitle: true,
      title:Text(
        title,
        style:
        AppTextStyles.headline1.copyWith(color: AppColors.textPrimary),
      ),
      elevation: 2,
    );
  }
}