import 'package:flutter/material.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_shadows.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/repositories/ibabysitter_repository.dart';
import 'package:ninerapp/presentation/subscreens/babysitter_info.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [AppShadows.inputShadow],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/img/babysitter.png'), // HACER poner imagen respectiva del niñero real guardada en supabase
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.babysitter.name} ${widget.babysitter.lastName}', style: AppTextstyles.childCardText, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${widget.babysitter.getAge()} años', style: AppTextstyles.childCardText, maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.locationArrow, size: 14, color: AppColors.fontColor),
                    SizedBox(width: 5),
                    Text(_getDistance(), style: AppTextstyles.childCardText, maxLines: 1, overflow: TextOverflow.ellipsis), // HACER añadir attr de ubicacion para obtener distancia en metros
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.hourglass, size: 14, color: AppColors.fontColor),
                    SizedBox(width: 5),
                    Text(widget.babysitter.getExperienceYears() == 0 ? 'Sin experiencia' : '${widget.babysitter.getExperienceYears()} años de experiencia', style: AppTextstyles.childCardText, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
                SizedBox(height: 10),
                Text('\$${widget.babysitter.pricePerHour.toStringAsFixed(2)} mxn por hora', style: AppTextstyles.childCardText.copyWith(color: AppColors.green), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 35, width: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text((widget.babysitter.getAverageStars()).toStringAsFixed(1), style: AppTextstyles.childCardText.copyWith(color: AppColors.white), textAlign: TextAlign.center), // HACER con metodo de get stars en babysitter calcular promedio
                    Icon(FontAwesomeIcons.solidStar, size: 14, color: AppColors.white),
                  ]
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 45, width: 45,
                child: IconButton(
                  icon: Icon(isFavorite == true ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart, color: AppColors.green, size: 20),
                  onPressed: onFavoritePress, tooltip: isFavorite == true ? "Eliminar de favoritos" : "Añadir a favoritos", hoverColor: AppColors.invisible, color: AppColors.invisible
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