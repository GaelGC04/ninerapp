import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/presentation/subscreens/request_babysitter.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';

class BabysitterInfoScreen extends StatefulWidget {
  final Babysitter babysitter;
  final Parent parent;

  const BabysitterInfoScreen({
    super.key,
    required this.babysitter,
    required this.parent,
  });

  @override
  State<BabysitterInfoScreen> createState() => _BabysitterInfoScreenState();
}

class _BabysitterInfoScreenState extends State<BabysitterInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil de ${widget.babysitter.name}", style: AppTextstyles.appBarText),
        centerTitle: false,
        backgroundColor: AppColors.primary,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nombre:", style: AppTextstyles.bodyText),
            Text("${widget.babysitter.name} ${widget.babysitter.lastName}", style: AppTextstyles.childCardText),
            const SizedBox(height: 8),

            if (widget.babysitter.expPhysicalDisability || widget.babysitter.expHearingDisability || widget.babysitter.expVisualDisability || (widget.babysitter.expOtherDisabilities != null && widget.babysitter.expOtherDisabilities!.isNotEmpty)) ...[
              Text("Experiencia en las siguientes discapacidades:", style: AppTextstyles.bodyText),
              if (widget.babysitter.expPhysicalDisability) Text(" - Física", style: AppTextstyles.childCardText),
              if (widget.babysitter.expHearingDisability) Text(" - Auditiva", style: AppTextstyles.childCardText),
              if (widget.babysitter.expVisualDisability) Text(" - Visual", style: AppTextstyles.childCardText),
            ],
            if (widget.babysitter.expOtherDisabilities != null && widget.babysitter.expOtherDisabilities!.isNotEmpty) ...[
              Text("Otra(s):", style: AppTextstyles.childCardText),
              Text(" - ${widget.babysitter.expOtherDisabilities!}", style: AppTextstyles.childCardText),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AppButton(
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  backgroundColor: AppColors.currentSectionColor,
                  textColor: AppColors.white,
                  text: 'Volver',
                  icon: FontAwesomeIcons.arrowLeft,
                  coloredBorder: true
                ),
                AppButton(
                  onPressed: _openRequestBabysitterScreen,
                  backgroundColor: AppColors.currentSectionColor,
                  textColor: AppColors.white,
                  text: 'Contratar',
                  icon: FontAwesomeIcons.personCircleQuestion,
                  coloredBorder: false
                ),
              ]
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  void _openRequestBabysitterScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RequestBabysitterScreen(
          babysitter: widget.babysitter,
          parent: widget.parent,
          onRequest: () {
            if (!mounted) return;
            Navigator.of(context).pop();
          },
        ),
      )
    );
  }
}