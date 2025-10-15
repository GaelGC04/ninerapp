import 'package:flutter/material.dart';
import 'package:ninerapp/core/constants/app_colors.dart';

class AppShadows {
  static const BoxShadow indexBoxShadow = BoxShadow(
    color: AppColors.shadowColor,
    spreadRadius: 0.5,
    blurRadius: 4,
    offset: Offset(0, 5)
  );

  static const BoxShadow inputShadow = BoxShadow(
    color: AppColors.shadowColor,
    spreadRadius: 0.1,
    blurRadius: 2,
    offset: Offset(0, 3)
  );
}