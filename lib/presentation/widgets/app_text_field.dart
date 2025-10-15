import 'package:flutter/material.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_shadows.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback validation;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.validation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [AppShadows.inputShadow],
      ),
      child: TextField(
        controller: controller,
        style: AppTextstyles.bodyText,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintText: hintText,
          hintStyle: AppTextstyles.bodyText.copyWith(color: AppColors.grey),
        ),
        onChanged: (value) {
          validation();
        }
      ),
    );
  }
}