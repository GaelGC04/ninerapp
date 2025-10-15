import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_shadows.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/domain/entities/person.dart';

class HomeSection extends StatefulWidget {
  final Person user;

  const HomeSection({
    super.key,
    required this.user
  });

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NiñerApp', style: AppTextstyles.appBarText),
        centerTitle: false,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 20),
              infoSection(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconInfo(AppColors.addChildColor, FontAwesomeIcons.baby, "Añadir hij@"),
                  SizedBox(width: 20),
                  iconInfo(AppColors.seeBabysittersColor, FontAwesomeIcons.personBreastfeeding, "Ver niñeros"),
                ]
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconInfo(AppColors.historyColor, FontAwesomeIcons.clock, "Historial"),
                  SizedBox(width: 20),
                  iconInfo(AppColors.settingsColor, FontAwesomeIcons.gear, "Opciones"),
                ]
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconInfo(AppColors.requestsColor, FontAwesomeIcons.personCircleQuestion, "Solicitudes"),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Expanded iconInfo(Color bgColor, IconData icon, String text) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: bgColor,
          boxShadow: [AppShadows.indexBoxShadow],
        ),
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: AppColors.fontColor),
            SizedBox(height: 25),
            Text(text, style: AppTextstyles.indexSubtitle, textAlign: TextAlign.center)
          ],
        ),
      ),
    );
  }

  Row infoSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.indexInfoColor,
              boxShadow: [AppShadows.indexBoxShadow],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${widget.user.name} ${widget.user.lastName}", style: AppTextstyles.indexTitle, textAlign: TextAlign.center),
                SizedBox(height: 25),
                Text("2 hijos registrados", style: AppTextstyles.indexSubtitle, textAlign: TextAlign.center),
                Text("20 servicios contratados", style: AppTextstyles.indexSubtitle, textAlign: TextAlign.center)
              ],
            ),
          ),
        )
      ],
    );
  }
}