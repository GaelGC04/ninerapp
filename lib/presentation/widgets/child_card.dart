import 'package:flutter/material.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_shadows.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/domain/entities/child.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/presentation/subscreens/child_info.dart';

class ChildCard extends StatelessWidget {
  final Child child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ChildCard({
    super.key,
    required this.child,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    int totalDisabilities = 0;
    if (child.physicalDisability) totalDisabilities++;
    if (child.hearingDisability) totalDisabilities++;
    if (child.visualDisability) totalDisabilities++;
    if (child.otherDisabilities != null && child.otherDisabilities!.isNotEmpty) totalDisabilities++;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChildInfoScreen(child: child),
          ),
        );
      },
      child: showInfo(totalDisabilities),
    );
  }

  Container showInfo(int totalDisabilities) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(15), boxShadow: [AppShadows.inputShadow]),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: child.isFemale ? AssetImage('assets/img/niña.png') : AssetImage('assets/img/niño.png'),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.name, style: AppTextstyles.childCardText, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(child.getAge() <= 0 ?
                  child.getAge() == 0 ?
                    'Recién nacido' :
                    '${child.getAge().abs()} meses' :
                  '${child.getAge()} años',
                style: AppTextstyles.childCardText),
                Text(totalDisabilities == 0 ? 'Sin discapacidades' : totalDisabilities == 1 ? '1 Discapacidad' : totalDisabilities < 4 ? '$totalDisabilities Discapacidades' : '3+ Discapacidades', style: AppTextstyles.childCardText),
              ],
            ),
          ),
          SizedBox(
            height: 35, width: 35,
            child: IconButton(
              icon: Icon(FontAwesomeIcons.pen, color: AppColors.fontColor, size: 20),
              onPressed: onEdit, tooltip: "Editar", hoverColor: AppColors.invisible, color: AppColors.invisible
            ),
          ),
          SizedBox(
            height: 35, width: 35,
            child: IconButton(
              icon: Icon(FontAwesomeIcons.trash, color: AppColors.red, size: 20),
              onPressed: onDelete, tooltip: "Borrar", hoverColor: AppColors.invisible, color: AppColors.invisible
            ),
          ),
        ],
      ),
    );
  }
}