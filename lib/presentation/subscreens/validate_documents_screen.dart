import 'package:flutter/material.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';

class ValidateDocumentsScreen extends StatefulWidget {
  final Babysitter babysitter;

  const ValidateDocumentsScreen({
    super.key,
    required this.babysitter,
  });

  @override
  State<ValidateDocumentsScreen> createState() => _ValidateDocumentsScreenState();
}

class _ValidateDocumentsScreenState extends State<ValidateDocumentsScreen> {
  String identificationTextButton = "Adjuntar identificación oficial";
  String studyTextButton = "Adjuntar comprobante de estudios";
  String domicileTextButton = "Adjuntar comprobante de domicilio";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Subir documentos", style: AppTextstyles.appBarText),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: AppButton(
                onPressed: (){},
                backgroundColor: AppColors.lightGrey,
                textColor: AppColors.fontColor,
                text: identificationTextButton,
                icon: null,
                coloredBorder: false
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              onPressed: (){},
              backgroundColor: AppColors.currentSectionColor,
              textColor: AppColors.lightGrey,
              text: "Subir identificación oficial",
              icon: null,
              coloredBorder: true
            ),
            const SizedBox(height: 30),


            SizedBox(
              width: double.infinity,
              child: AppButton(
                onPressed: (){},
                backgroundColor: AppColors.lightGrey,
                textColor: AppColors.fontColor,
                text: studyTextButton,
                icon: null,
                coloredBorder: false
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              onPressed: (){},
              backgroundColor: AppColors.currentSectionColor,
              textColor: AppColors.lightGrey,
              text: "Subir comprobante de estudios",
              icon: null,
              coloredBorder: true
            ),
            const SizedBox(height: 30),


            SizedBox(
              width: double.infinity,
              child: AppButton(
                onPressed: (){},
                backgroundColor: AppColors.lightGrey,
                textColor: AppColors.fontColor,
                text: domicileTextButton,
                icon: null,
                coloredBorder: false
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              onPressed: (){},
              backgroundColor: AppColors.currentSectionColor,
              textColor: AppColors.lightGrey,
              text: "Subir comprobante de domicilio",
              icon: null,
              coloredBorder: true
            ),

            const Spacer(),

            AppButton(
              onPressed: () => Navigator.pop(context),
              backgroundColor: AppColors.currentSectionColor,
              textColor: AppColors.white,
              text: "Volver",
              icon: null,
              coloredBorder: true
            ),
          ],
        ),
      ),
    );
  }
}