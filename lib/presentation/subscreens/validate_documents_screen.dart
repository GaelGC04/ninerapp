import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/repositories/ibabysitter_repository.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';

class ValidateDocumentsScreen extends StatefulWidget {
  final Babysitter babysitter;
  final VoidCallback onDocumentsValidated;

  const ValidateDocumentsScreen({
    super.key,
    required this.babysitter,
    required this.onDocumentsValidated,
  });

  @override
  State<ValidateDocumentsScreen> createState() => _ValidateDocumentsScreenState();
}

class _ValidateDocumentsScreenState extends State<ValidateDocumentsScreen> {
  final IBabysitterRepository _babysitterRepository = getIt<IBabysitterRepository>();
  bool identificationSelected = false;
  bool studySelected = false;
  bool domicileSelected = false;

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
            if (widget.babysitter.isIdentificationSent == true) ...[
              showIdentifierUploadDone(),
            ] else ...[
              showIdentifierDocSection(),
            ],

            if (widget.babysitter.isStudySent == true) ...[
              showStudyUploadDone(),
            ] else ...[
              showStudyDocSection(),
            ],

            if (widget.babysitter.isDomicileSent == true) ...[
              showDomicileUploadDone(),
            ] else ...[
              showDomicileDocSection(),
            ],

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

  Column showIdentifierUploadDone() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Identificación oficial subida",
            style: AppTextstyles.bodyText.copyWith(
              color: AppColors.fontColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Column showStudyUploadDone() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Comprobante de estudios subido",
            style: AppTextstyles.bodyText.copyWith(
              color: AppColors.fontColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Column showDomicileUploadDone() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Comprobante de domicilio subido",
            style: AppTextstyles.bodyText.copyWith(
              color: AppColors.fontColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Future<void> _pickFile(String documentType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        switch (documentType) {
          case "identification":
            identificationSelected = true;
            break;
          case "study":
            studySelected = true;
            break;
          case "domicile":
            domicileSelected = true;
            break;
        }
      });
    }
  }

  void validateBabysitterIdentificationDoc() async {
    bool result = await _babysitterRepository.updateBabysitterDocuments(widget.babysitter, "identification");
    if (result == false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No fue posible subir la identificación oficial, intentar más tarde', style: TextStyle(color: AppColors.white)),
            backgroundColor: AppColors.red,
          ),
        );
      }
      return;
    }
    setState(() {
      widget.babysitter.isIdentificationSent = true;
    });
    if (mounted) {
      if (widget.babysitter.isIdentificationSent == true
        && widget.babysitter.isStudySent == true
        && widget.babysitter.isDomicileSent == true) {
        widget.onDocumentsValidated();
        Navigator.pop(context);
      }
    }
  }

  void validateBabysitterStudyDoc() async {
    bool result = await _babysitterRepository.updateBabysitterDocuments(widget.babysitter, "study");
    if (result == false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No fue posible subir el comprobante de estudios, intentar más tarde', style: TextStyle(color: AppColors.white)),
            backgroundColor: AppColors.red,
          ),
        );
      }
      return;
    }
    setState(() {
      widget.babysitter.isStudySent = true;
    });
    if (mounted) {
      if (widget.babysitter.isIdentificationSent == true
        && widget.babysitter.isStudySent == true
        && widget.babysitter.isDomicileSent == true) {
        widget.onDocumentsValidated();
        Navigator.pop(context);
      }
    }
  }

  void validateBabysitterDomicileDoc() async {
    bool result = await _babysitterRepository.updateBabysitterDocuments(widget.babysitter, "domicile");
    if (result == false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No fue posible subir el comprobante de domicilio, intentar más tarde', style: TextStyle(color: AppColors.white)),
            backgroundColor: AppColors.red,
          ),
        );
      }
      return;
    }
    setState(() {
      widget.babysitter.isDomicileSent = true;
    });
    if (mounted) {
      if (widget.babysitter.isIdentificationSent == true
        && widget.babysitter.isStudySent == true
        && widget.babysitter.isDomicileSent == true) {
        widget.onDocumentsValidated();
        Navigator.pop(context);
      }
    }
  }

  Column showDomicileDocSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: AppButton(
            onPressed: () => _pickFile("domicile"),
            backgroundColor: AppColors.lightGrey,
            textColor: AppColors.fontColor,
            text: domicileSelected == false ? "Adjuntar comprobante de domicilio" : "Comprobante de domicilio seleccionado",
            icon: null,
            coloredBorder: false
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          onPressed: validateBabysitterDomicileDoc,
          backgroundColor: AppColors.currentSectionColor,
          textColor: AppColors.lightGrey,
          text: "Subir comprobante de domicilio",
          icon: null,
          coloredBorder: true,
          isLocked: domicileSelected == false,
        ),
      ],
    );
  }

  Column showStudyDocSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: AppButton(
            onPressed: () => _pickFile("study"),
            backgroundColor: AppColors.lightGrey,
            textColor: AppColors.fontColor,
            text: studySelected == false ? "Adjuntar comprobante de estudios" : "Comprobante de estudios seleccionado",
            icon: null,
            coloredBorder: false
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          onPressed: validateBabysitterStudyDoc,
          backgroundColor: AppColors.currentSectionColor,
          textColor: AppColors.lightGrey,
          text: "Subir comprobante de estudios",
          icon: null,
          coloredBorder: true,
          isLocked: studySelected == false,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Column showIdentifierDocSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: AppButton(
            onPressed: () => _pickFile("identification"),
            backgroundColor: AppColors.lightGrey,
            textColor: AppColors.fontColor,
            text: identificationSelected == false ? "Adjuntar identificación oficial" : "Identificación oficial seleccionada",
            icon: null,
            coloredBorder: false
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          onPressed: validateBabysitterIdentificationDoc,
          backgroundColor: AppColors.currentSectionColor,
          textColor: AppColors.lightGrey,
          text: "Subir identificación oficial",
          icon: null,
          coloredBorder: true,
          isLocked: identificationSelected == false,
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}