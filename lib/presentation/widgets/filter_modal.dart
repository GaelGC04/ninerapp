import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';
import 'package:ninerapp/presentation/widgets/app_text_field.dart';

class FilterWindow extends StatefulWidget {
  final int initialMinimumStars;
  final int initialMinDistanceMts;
  final int initialMaxDistanceMts;
  final int initialMinExpYears;
  final int initialMaxExpYears;
  final int initialMinPricePerHour;
  final int initialMaxPricePerHour;
  final bool initialHasPhysicalDisabilityExp;
  final bool initialHasVisualDisabilityExp;
  final bool initialHasHearingDisabilityExp;

  const FilterWindow({
    super.key,
    required this.initialMinimumStars,
    required this.initialMinDistanceMts,
    required this.initialMaxDistanceMts,
    required this.initialMinExpYears,
    required this.initialMaxExpYears,
    required this.initialMinPricePerHour,
    required this.initialMaxPricePerHour,
    required this.initialHasPhysicalDisabilityExp,
    required this.initialHasVisualDisabilityExp,
    required this.initialHasHearingDisabilityExp,
  });

  @override
  State<FilterWindow> createState() => FilterWindowState();
}

class FilterWindowState extends State<FilterWindow> {
  late TextEditingController _minimumStarsController;
  late TextEditingController _minDistanceController;
  late TextEditingController _maxDistanceController;
  late TextEditingController _minExpController;
  late TextEditingController _maxExpController;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late bool _hasPhysicalDisabilityExp;
  late bool _hasVisualDisabilityExp;
  late bool _hasHearingDisabilityExp;

  @override
  void initState() {
    super.initState();
    _minimumStarsController = TextEditingController(text: widget.initialMinimumStars.toString());
    _minDistanceController = TextEditingController(text: widget.initialMinDistanceMts.toString());
    _maxDistanceController = TextEditingController(text: widget.initialMaxDistanceMts.toString());
    _minExpController = TextEditingController(text: widget.initialMinExpYears.toString());
    _maxExpController = TextEditingController(text: widget.initialMaxExpYears.toString());
    _minPriceController = TextEditingController(text: widget.initialMinPricePerHour.toString());
    _maxPriceController = TextEditingController(text: widget.initialMaxPricePerHour.toString());
    _hasPhysicalDisabilityExp = widget.initialHasPhysicalDisabilityExp;
    _hasVisualDisabilityExp = widget.initialHasVisualDisabilityExp;
    _hasHearingDisabilityExp = widget.initialHasHearingDisabilityExp;
  }

  @override
  void dispose() {
    _minimumStarsController.dispose();
    _minDistanceController.dispose();
    _maxDistanceController.dispose();
    _minExpController.dispose();
    _maxExpController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void applyFilters() {
    // Se cierra la ventana flotante y se devuelve un mapa con los nuevos filtros
    Navigator.of(context).pop({
      'minimumStars': int.tryParse(_minimumStarsController.text.replaceAll('-', '')) ?? 0,
      'minDistanceMts': int.tryParse(_minDistanceController.text.replaceAll('-', '')) ?? 0,
      'maxDistanceMts': int.tryParse(_maxDistanceController.text.replaceAll('-', '')) ?? 1000000,
      'minExpYears': int.tryParse(_minExpController.text.replaceAll('-', '')) ?? 0,
      'maxExpYears': int.tryParse(_maxExpController.text.replaceAll('-', '')) ?? 100,
      'minPricePerHour': int.tryParse(_minPriceController.text.replaceAll('-', '')) ?? 0,
      'maxPricePerHour': int.tryParse(_maxPriceController.text.replaceAll('-', '')) ?? 10000,
      'hasPhysicalDisabilityExp': _hasPhysicalDisabilityExp,
      'hasVisualDisabilityExp': _hasVisualDisabilityExp,
      'hasHearingDisabilityExp': _hasHearingDisabilityExp,
    });
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalDialogPadding = 20;
    const double internalContentPadding = 20;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: horizontalDialogPadding, vertical: 0),
      clipBehavior: Clip.antiAlias,
      backgroundColor: AppColors.white,
      contentPadding: const EdgeInsets.all(internalContentPadding),
      content: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final contentWidth = screenWidth - (horizontalDialogPadding * 2);

          return SizedBox(
            width: contentWidth,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Filtros", style: AppTextstyles.bodyText.copyWith(fontSize: 24)),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Text("Estrellas:", style: AppTextstyles.bodyText),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppTextField(
                          controller: _minimumStarsController,
                          hintText: "Estrellas",
                          validation: () {
                            if (int.tryParse(_minimumStarsController.text.trim()) == null) return;
                            if (int.tryParse(_minimumStarsController.text.trim())! > 5) {
                              setState(() {
                                _minimumStarsController.text = "5";
                              });
                            }
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*'))],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
            
                  const Text("Rango de distancia (metros):", style: AppTextstyles.bodyText),
                  rangeMinMaxFields(_minDistanceController, _maxDistanceController),
                  const SizedBox(height: 15),
            
                  const Text("Rango de experiencia (años):", style: AppTextstyles.bodyText),
                  rangeMinMaxFields(_minExpController, _maxExpController),
                  const SizedBox(height: 15),
            
                  const Text("Rango de precios por hora (mxn):", style: AppTextstyles.bodyText),
                  rangeMinMaxFields(_minPriceController, _maxPriceController),
                  const SizedBox(height: 15),
            
                  const Text("Conocimientos en discapacidades:", style: AppTextstyles.bodyText),
                  loadCheckbox("Física", _hasPhysicalDisabilityExp, (newValue) {
                    setState(() => _hasPhysicalDisabilityExp = newValue!);
                  }),
                  loadCheckbox("Visual", _hasVisualDisabilityExp, (newValue) {
                    setState(() => _hasVisualDisabilityExp = newValue!);
                  }),
                  loadCheckbox("Auditiva", _hasHearingDisabilityExp, (newValue) {
                    setState(() => _hasHearingDisabilityExp = newValue!);
                  }),
                  const SizedBox(height: 20),
            
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          onPressed: () => Navigator.of(context).pop(),
                          text: "Cancelar",
                          icon: null,
                          coloredBorder: true,
                          backgroundColor: AppColors.currentListOption,
                          textColor: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          backgroundColor: AppColors.currentListOption,
                          textColor: AppColors.white,
                          onPressed: applyFilters,
                          icon: null,
                          coloredBorder: false,
                          text: "Aplicar",
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget rangeMinMaxFields(TextEditingController minController, TextEditingController maxController) {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: minController,
            hintText: "Min",
            validation: () {},
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*'))],
          ),
        ),
        const SizedBox(width: 20),
        const Text("a", style: AppTextstyles.bodyText),
        const SizedBox(width: 20),
        Expanded(
          child: AppTextField(
            controller: maxController,
            hintText: "Max",
            validation: () {
              if (int.tryParse(maxController.text.trim()) == null || int.tryParse(minController.text.trim()) == null) return;
              if (int.tryParse(maxController.text.trim())! < int.tryParse(minController.text.trim())!) {
                setState(() {
                  maxController.text = minController.text;
                });
              }
            },
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*'))], //r'^-?\d*' para negativos
          ),
        ),
      ],
    );
  }

  Widget loadCheckbox(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title, style: AppTextstyles.bodyText.copyWith(color: AppColors.fontColor)),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.green,
      contentPadding: EdgeInsets.zero,
    );
  }
}