import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/repositories/ibabysitter_repository.dart';
import 'package:ninerapp/presentation/widgets/babysitter_card.dart';

class BabysittersSection extends StatefulWidget {
  final Parent parent;

  const BabysittersSection({
    super.key,
    required this.parent
  });

  @override
  State<BabysittersSection> createState() => _BabysittersSectionState();
}

class _BabysittersSectionState extends State<BabysittersSection> {
  final IBabysitterRepository _babysitterRepository = getIt<IBabysitterRepository>();
  List<Babysitter> babysittersList = [];
  bool _isLoading = true;
  String? _errorMessage;

  String currentList = "Todos";

  int minimumStars = 0;
  int minDistanceMts = 0;
  int maxDistanceMts = 1000000;
  int minExpYears = 0;
  int maxExpYears = 100;
  int minPricePerHour = 0;
  int maxPricePerHour = 10000;
  bool hasPhysicalDisabilityExp = false;
  bool hasVisualDisabilityExp = false;
  bool hasHearingDisabilityExp = false;

  @override
  void initState() {
    super.initState();
    _loadBabysitters();
  }

  Future<void> _loadBabysitters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final babysittersRes = await _babysitterRepository.getBabysitters(minimumStars, minDistanceMts, maxDistanceMts, minExpYears, maxExpYears, minPricePerHour, maxPricePerHour, hasPhysicalDisabilityExp, hasVisualDisabilityExp, hasHearingDisabilityExp);
      setState(() {
        babysittersList = babysittersRes;

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains("SocketException")) {
            _errorMessage = 'No hay conexión a internet. Favor de verificar la red o intentar de nuevo más tarde.';
          } else {
            _errorMessage = 'Error al cargar los niñeros: ${e.toString()}';
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Niñeros', style: AppTextstyles.appBarText),
        centerTitle: false,
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          if (_isLoading)
            Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else if (_errorMessage != null)
            Expanded(child: Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(_errorMessage!, style: AppTextstyles.appBarText.copyWith(color: AppColors.red), textAlign: TextAlign.center))))
          else if (babysittersList.isEmpty) ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Center(child: Text("No se han encontrado niñeros...", style: AppTextstyles.appBarText))],
              ),
            ),
          ] else ... [
            buttonsBar(),
            Expanded(
              child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      ...babysittersList.map((babysitter) {
                        return BabysitterCard(
                          babysitter: babysitter,
                          parent: widget.parent,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buttonsBar() {
    List<String> options = ["Todos", "Favoritos"];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blueTransparent,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ...options.expand((option) => [
            optionButton(option, (){
              setState(() {
                currentList = option;
              });
            }),
            SizedBox(width: 10),
          ]), // HACER añadir accion para mostrar entre todos o favoritos
          Spacer(),
          Container(
            height: 40, width: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: (){
                // HACER que salga modal para filtrar niñeros
              },
              icon: Icon(FontAwesomeIcons.filter), color: AppColors.currentListOption,
              style: ButtonStyle(overlayColor: WidgetStateProperty.all(AppColors.invisible))
            )
          )
        ]
      ),
    );
  }

  TextButton optionButton(String option, VoidCallback? onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: currentList == option ? AppColors.currentListOption : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      ),
      child: Text(option, style: AppTextstyles.childCardText.copyWith(color: currentList == option ? AppColors.white : AppColors.fontColor)),
    );
  }
}