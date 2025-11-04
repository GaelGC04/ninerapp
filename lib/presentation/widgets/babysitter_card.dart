import 'package:flutter/material.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_shadows.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/repositories/ibabysitter_repository.dart';
import 'package:ninerapp/presentation/screens/babysitter_info_screen.dart';


class BabysitterCard extends StatefulWidget {
  final Babysitter babysitter;
  final Parent parent;

  const BabysitterCard({
    super.key,
    required this.babysitter,
    required this.parent,
  });

  @override
  State<BabysitterCard> createState() => _BabysitterCardState();
}

class _BabysitterCardState extends State<BabysitterCard> {
  final IBabysitterRepository _babysitterRepository = getIt<IBabysitterRepository>();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.babysitter.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openBabysitterInfo,
      child: showInfo(),
    );
  }

Container showInfo() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [AppShadows.inputShadow],
    ),
    child: Row(
      children: [
        // FOTO
        CircleAvatar(
          radius: 32,
          backgroundImage: widget.babysitter.profileImageUrl != null
              ? NetworkImage(widget.babysitter.profileImageUrl!)
              : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
        ),

        const SizedBox(width: 14),

        // INFO
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.babysitter.name} ${widget.babysitter.lastName}',
                style: AppTextstyles.childCardText.copyWith(fontSize: 17),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "${widget.babysitter.getAge()} años",
                style: AppTextstyles.bodyText,
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(FontAwesomeIcons.locationDot, size: 13, color: AppColors.fontColor),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(_getDistance(), style: AppTextstyles.bodyText, maxLines: 1),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(FontAwesomeIcons.solidClock, size: 13, color: AppColors.fontColor),
                  const SizedBox(width: 5),
                  Text(
                    widget.babysitter.getExperienceYears() == 0
                        ? "Sin experiencia"
                        : "${widget.babysitter.getExperienceYears()} años de experiencia",
                    style: AppTextstyles.bodyText,
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                "\$${widget.babysitter.pricePerHour.toStringAsFixed(2)} mxn / hora",
                style: AppTextstyles.childCardText.copyWith(color: AppColors.green),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // COLUMNA DERECHA (Estrellas + Favorito)
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    widget.babysitter.getAverageStars().toStringAsFixed(1),
                    style: AppTextstyles.childCardText.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(width: 4),
                  const Icon(FontAwesomeIcons.solidStar, size: 14, color: AppColors.white),
                ],
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: onFavoritePress,
              child: Icon(
                isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                color: AppColors.green,
                size: 22,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  String _getDistance() {
    if (widget.parent.lastLatitude == null || widget.parent.lastLongitude == null || widget.babysitter.lastLatitude == null || widget.babysitter.lastLongitude == null) return "Ubicación sin definir";
    if (widget.babysitter.distanceMeters == null) return "Ubicación desconocida";

    return "A ${widget.babysitter.distanceMeters!} metros";
  }

  void _openBabysitterInfo() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BabysitterInfoScreen(babysitter: widget.babysitter, parent: widget.parent),
      ),
    );
  }

  void onFavoritePress() async {
    setState(() {
      isFavorite = !isFavorite;
    });
    await _babysitterRepository.editBabysitterFavorite(widget.babysitter.id!, widget.parent.id!, isFavorite);
  }
}