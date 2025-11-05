import 'package:flutter/material.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/domain/entities/child.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';

class ChildInfoScreen extends StatelessWidget {
  final Child child;

  const ChildInfoScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text("Datos: ${child.name}", style: AppTextstyles.appBarText),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: child.isFemale == true
                        ? const AssetImage('assets/img/niña.png') as ImageProvider
                        : const AssetImage('assets/img/niño.png') as ImageProvider,
                    ),
                    const SizedBox(height: 15),
                    Text("${child.name} ${child.lastName}", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                    Text(child.getAge() <= 0
                      ? child.getAge() == 0
                        ? 'Recién nacido'
                        : '${child.getAge().abs()} meses'
                      : '${child.getAge()} años',
                    style: const TextStyle(color: AppColors.grey, fontSize: 14)),
                    const SizedBox(height: 5),
                    _infoSection("Sexo:", child.isFemale ? "Mujer" : "Hombre"),
                    _multipleInfoSection(
                      "Discapacidades:",
                      [
                        if (child.hearingDisability) "Auditiva",
                        if (child.physicalDisability) "Física",
                        if (child.visualDisability) "Visual",
                      ],
                    ),
                    if (child.otherDisabilities != null && child.otherDisabilities!.isNotEmpty) ...[
                      _infoSection("Otras discapacidades:", child.otherDisabilities!),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
          ],
        ),
      ),
    );
  }

  SizedBox _infoSection(String title, String value) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("\n$title", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("- $value"),
        ],
      ),
    );
  }

  SizedBox _multipleInfoSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("\n$title", style: const TextStyle(fontWeight: FontWeight.bold)),
          ...items.map((item) => Text("- $item")),
        ],
      ),
    );
  }
}
