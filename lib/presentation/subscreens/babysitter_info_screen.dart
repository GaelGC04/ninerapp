import 'package:flutter/material.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/presentation/subscreens/request_babysitter.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';

class BabysitterInfoScreen extends StatelessWidget {
  final Babysitter babysitter;
  final Parent parent;

  const BabysitterInfoScreen({
    super.key,
    required this.babysitter,
    required this.parent,
  });

  @override
  Widget build(BuildContext context) {
    final experienceYears = babysitter.getExperienceYears();
    final distance = babysitter.distanceMeters ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Info niñero", style: AppTextstyles.appBarText),
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
                      backgroundImage: babysitter.profileImageUrl != null
                        ? NetworkImage(babysitter.profileImageUrl!)
                        : const AssetImage('assets/img/babysitter.png') as ImageProvider,
                    ),
                    const SizedBox(height: 15),
                    Text("${babysitter.name} ${babysitter.lastName}", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                    Text("${babysitter.getAge()} años", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 5),

                    _infoSection("Sexo:", babysitter.isFemale ? "Mujer" : "Hombre"),
                    _infoSection("Experiencia:", "$experienceYears años de experiencia"),
                    _infoSection("Distancia:", "A menos de ${distance.toStringAsFixed(0)} metros"),
                    _infoSection("Cobro por hora:", "\$${babysitter.pricePerHour.toStringAsFixed(2)} mxn por hora"),
                    _multipleInfoSection(
                      "Experiencia en las siguientes discapacidades:",
                      [
                        if (babysitter.expHearingDisability) "Auditiva",
                        if (babysitter.expPhysicalDisability) "Física",
                        if (babysitter.expVisualDisability) "Visual",
                      ],
                    ),

                    _multipleInfoSection(
                      "Otras:",
                      babysitter.expOtherDisabilities != null &&
                              babysitter.expOtherDisabilities!.isNotEmpty
                          ? [babysitter.expOtherDisabilities!]
                          : [],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RequestBabysitterScreen(
                            babysitter: babysitter,
                            parent: parent,
                            onRequest: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        )
                      );
                    },
                    backgroundColor: AppColors.currentSectionColor,
                    textColor: AppColors.white,
                    text: "Solicitar",
                    icon: null,
                    coloredBorder: false
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: AppColors.currentSectionColor,
                    textColor: AppColors.white,
                    text: "Volver",
                    icon: null,
                    coloredBorder: true
                  ),
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
