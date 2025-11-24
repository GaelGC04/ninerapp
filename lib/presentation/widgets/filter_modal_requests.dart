import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/domain/entities/service_status.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';
import 'package:ninerapp/presentation/widgets/app_text_field.dart';

class FilterWindowRequests extends StatefulWidget {
  final String? statusService;
  final bool? paymentMethodIsCard;
  final bool? paymentMethodIsCash;
  final DateTime? initialDate;
  final DateTime? finalDate;

  const FilterWindowRequests({
    super.key,
    required this.statusService,
    required this.paymentMethodIsCard,
    required this.paymentMethodIsCash,
    required this.initialDate,
    required this.finalDate,
  });

  @override
  State<FilterWindowRequests> createState() => FilterWindowRequestsState();
}

class FilterWindowRequestsState extends State<FilterWindowRequests> {
  late TextEditingController _initialDateController;
  late TextEditingController _finalDateController;
  late bool _paymentMethodIsCard;
  late bool _paymentMethodIsCash;
  late String _statusService;
  String? textInitialDate;
  String? textFinalDate;


  @override
  void initState() {
    super.initState();
    _initialDateController = TextEditingController(text: widget.initialDate.toString());
    _finalDateController = TextEditingController(text: widget.finalDate.toString());
    _paymentMethodIsCard = widget.paymentMethodIsCard ?? false;
    _paymentMethodIsCash = widget.paymentMethodIsCash ?? false;
    _statusService = widget.statusService ?? 'Todos';
  }

  @override
  void dispose() {
    _initialDateController.dispose();
    _finalDateController.dispose();
    super.dispose();
  }

  void applyFilters() {
    Navigator.of(context).pop({
      'initialDate': int.tryParse(_initialDateController.text),
      'finalDate': int.tryParse(_finalDateController.text),
      'paymentMethodIsCard': _paymentMethodIsCard,
      'paymentMethodIsCash': _paymentMethodIsCash,
      'statusService': _statusService,
    });
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalDialogPadding = 20;
    const double internalContentPadding = 20;
    List<String> statusOptions = ServiceStatus.values.map((e) => e.value).toList();
    statusOptions.insert(0, 'Todos');

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
                  const Text("Estado de los servicios:", style: AppTextstyles.bodyText),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: statusOptions.contains(_statusService) ? _statusService : null,
                        hint: const Text("Seleccione un estado"),
                        
                        items: statusOptions.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(
                              status,
                              style: AppTextstyles.bodyText,
                            ),
                          );
                        }).toList(),
                        
                        onChanged: (String? newValue) {
                          setState(() {
                            if (newValue != null) {
                              _statusService = newValue;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
            
                  const Text("Tipo de pago:", style: AppTextstyles.bodyText),
                  loadCheckbox("Tarjeta", _paymentMethodIsCard, (newValue) {
                    setState(() => _paymentMethodIsCard = newValue!);
                  }),
                  loadCheckbox("Efectivo", _paymentMethodIsCash, (newValue) {
                    setState(() => _paymentMethodIsCash = newValue!);
                  }),
                  const SizedBox(height: 15),

                  const Text("Rango de fechas:", style: AppTextstyles.bodyText),
                  rangeMinMaxFields(_initialDateController, _finalDateController),
                  const SizedBox(height: 40),
            
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
            hintText: "Fecha inicial",
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
            hintText: "Fecha final",
            validation: () {
              // TODO en vez de esto, validar que la fecha final no sea anterior a la inicial, si es anterior entonces hacerla igual a inicial
              if (int.tryParse(maxController.text.trim()) == null || int.tryParse(minController.text.trim()) == null) return;
              if (int.tryParse(maxController.text.trim())! < int.tryParse(minController.text.trim())!) {
                setState(() {
                  maxController.text = minController.text;
                });
              }
            },
            keyboardType: TextInputType.number,
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