import 'package:flutter/material.dart';
import 'package:familyapp/design/colors.dart';
import 'package:familyapp/design/text_styles.dart';
import 'package:familyapp/design/spacing.dart';


class AppCardStyles {

  static Card noteList({
    required String title,
    required VoidCallback onTap
}){
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: AppSpacing.m),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: AppTextStyles.headline3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      ),
    );
  }

  static Card contactList({
    required String name,
    required VoidCallback onTap
  }){
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: AppSpacing.m),
      child: ListTile(
        onTap: onTap,
        title: Text(
          name,
          style: AppTextStyles.headline3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

}