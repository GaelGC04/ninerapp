import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/core/util/time_number_format.dart';
import 'package:ninerapp/domain/entities/service_status.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';
import 'package:ninerapp/presentation/widgets/app_text_field.dart';

class FilterWindowRequests extends StatefulWidget {
  final String? statusService;
  final bool? paymentMethodIsCard;
  final bool? paymentMethodIsCash;
  final DateTime? initialDate;
  final DateTime? finalDate;
  final bool statusToFilterAreFinished;

  const FilterWindowRequests({
    super.key,
    required this.statusService,
    required this.paymentMethodIsCard,
    required this.paymentMethodIsCash,
    required this.initialDate,
    required this.finalDate,
    required this.statusToFilterAreFinished,
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
  String? initialDateText;
  String? finalDateText;

  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  
  late List<String> statusOptions;

  @override
  void initState() {
    super.initState();
    _initialDateController = TextEditingController(text: widget.initialDate == null ? 'dd/mm/aaaa' :widget.initialDate.toString());
    _finalDateController = TextEditingController(text: widget.finalDate == null ? 'dd/mm/aaaa' :widget.finalDate.toString());
    _paymentMethodIsCard = widget.paymentMethodIsCard ?? false;
    _paymentMethodIsCash = widget.paymentMethodIsCash ?? false;

    _statusService = widget.statusService ?? 'Todos';
    
    List<String> finishedStatusOptions = [
      "Todos los estados finalizados",
      ServiceStatus.completed.value,
      ServiceStatus.canceled.value,
      ServiceStatus.rejected.value,
    ];

    List<String> processStatusOptions = [
      "Todos los estados en proceso",
      ServiceStatus.accepted.value,
      ServiceStatus.process.value,
      ServiceStatus.waiting.value,
    ];

    if (widget.statusToFilterAreFinished == true) {
      statusOptions = finishedStatusOptions;
    } else {
      statusOptions = processStatusOptions;
    }
  }

  @override
  void dispose() {
    _initialDateController.dispose();
    _finalDateController.dispose();
    super.dispose();
  }

  void applyFilters() {
    Navigator.of(context).pop({
      'initialDate': initialDateText == null ? null : _dateFormat.parse(_initialDateController.text),
      'finalDate': finalDateText == null ? null : _dateFormat.parse(_finalDateController.text),
      'paymentMethodIsCard': _paymentMethodIsCard,
      'paymentMethodIsCash': _paymentMethodIsCash,
      'statusService': (_statusService == 'Todos los estados finalizados' || _statusService == 'Todos los estados en proceso') ? null : _statusService,
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
                          onPressed: () => hideFiltersWindow(),
                          text: "Cancelar",
                          icon: null,
                          coloredBorder: true,
                          backgroundColor: AppColors.currentSectionColor,
                          textColor: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          backgroundColor: AppColors.currentSectionColor,
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

  void hideFiltersWindow() {
    Navigator.of(context).pop();
  }

  Widget rangeMinMaxFields(TextEditingController minController, TextEditingController maxController) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(context, true),
            child: AbsorbPointer(
              child: AppTextField(
                controller: minController,
                hintText: "Fecha inicial",
                validation: (){},
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        const Text("a", style: AppTextstyles.bodyText),
        const SizedBox(width: 20),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(context, false),
            child: AbsorbPointer(
              child: AppTextField(
                controller: maxController,
                hintText: "Fecha final",
                validation: (){},
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _validateMaxDate() {
    if (_finalDateController.text.isNotEmpty && _initialDateController.text.isNotEmpty) {
      try {
        DateTime minDate = _dateFormat.parse(_initialDateController.text);
        DateTime maxDate = _dateFormat.parse(_finalDateController.text);

        if (minDate.isAfter(maxDate)) {
          setState(() {
            _finalDateController.text = _initialDateController.text;
            finalDateText = initialDateText;
          });
        }
      } catch (e) {
        debugPrint('Error parsing date for validation: $e');
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isInitial) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isInitial == true) {
          _initialDateController.text = "${TimeNumberFormat.formatTwoDigits(picked.day)}-${TimeNumberFormat.formatTwoDigits(picked.month)}-${picked.year}";
          initialDateText = "${picked.day}-${picked.month}-${picked.year}";
          _validateMaxDate();
          return;
        } else {
          _finalDateController.text = "${TimeNumberFormat.formatTwoDigits(picked.day)}-${TimeNumberFormat.formatTwoDigits(picked.month)}-${picked.year}";
          finalDateText = "${picked.day}-${picked.month}-${picked.year}";
          _validateMaxDate();
          return;
        }
      });
    }
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