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
  final String? paymentMethod;
  final DateTime? initialDate;
  final DateTime? finalDate;
  final bool statusToFilterAreFinished;

  const FilterWindowRequests({
    super.key,
    required this.statusService,
    required this.paymentMethod,
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
  late String _paymentMethod;
  late String _statusService;
  String? initialDateText;
  String? finalDateText;

  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  
  late List<String> statusOptions;
  final List<String> paymentOptions = [
    "Todos los tipos de pago",
    "Con tarjeta",
    "En efectivo",
  ];

  @override
  void initState() {
    super.initState();
    _initialDateController = TextEditingController(text: widget.initialDate == null ? 'dd/mm/aaaa' : "${TimeNumberFormat.formatTwoDigits(widget.initialDate!.day)}-${TimeNumberFormat.formatTwoDigits(widget.initialDate!.month)}-${TimeNumberFormat.formatTwoDigits(widget.initialDate!.year)}");
    _finalDateController = TextEditingController(text: widget.finalDate == null ? 'dd/mm/aaaa' : "${TimeNumberFormat.formatTwoDigits(widget.finalDate!.day)}-${TimeNumberFormat.formatTwoDigits(widget.finalDate!.month)}-${TimeNumberFormat.formatTwoDigits(widget.finalDate!.year)}");
    if (widget.initialDate != null) {
      initialDateText = "${widget.initialDate!.day}-${widget.initialDate!.month}-${widget.initialDate!.year}";
    }
    if (widget.finalDate != null) {
      finalDateText = "${widget.finalDate!.day}-${widget.finalDate!.month}-${widget.finalDate!.year}";
    }
    _paymentMethod = widget.paymentMethod ?? 'Todos los tipos de pago';
    
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
      _statusService = widget.statusService ?? 'Todos los estados finalizados';
      statusOptions = finishedStatusOptions;
    } else {
      _statusService = widget.statusService ?? 'Todos los estados en proceso';
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
      'initialDate': initialDateText == null ? null : _dateFormat.parse(_initialDateController.text).copyWith(hour: 0, minute: 0, second: 0),
      'finalDate': finalDateText == null ? null : _dateFormat.parse(_finalDateController.text).copyWith(hour: 23, minute: 59, second: 59),
      'paymentMethod': _paymentMethod == 'Todos los tipos de pago' ? null : _paymentMethod,
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
                        hint: const Text("Seleccionar estado"),
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
                          setStatusFilter(newValue);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
            
                  const Text("Tipo de pago:", style: AppTextstyles.bodyText),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: paymentOptions.contains(_paymentMethod) ? _paymentMethod : null,
                        hint: const Text("Seleccionar tipo de pago"),
                        items: paymentOptions.map((String payment) {
                          return DropdownMenuItem<String>(
                            value: payment,
                            child: Text(
                              payment,
                              style: AppTextstyles.bodyText,
                            ),
                          );
                        }).toList(),
                        
                        onChanged: (String? newValue) {
                          setPaymentMethodFilter(newValue);
                        },
                      ),
                    ),
                  ),
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

  void setPaymentMethodFilter(String? newPaymentMethod) {
    setState(() {
      if (newPaymentMethod != null) {
        _paymentMethod = newPaymentMethod;
      }
    });
  }

  void setStatusFilter(String? newStatus) {
    setState(() {
      if (newStatus != null) {
        _statusService = newStatus;
      }
    });
  }

  void hideFiltersWindow() {
    Navigator.of(context).pop();
  }

  Widget rangeMinMaxFields(TextEditingController minController, TextEditingController maxController) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => selectDate(context, true),
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
            onTap: () => selectDate(context, false),
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

  void setInitialAndFinalDateEqual() {
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

  Future<void> selectDate(BuildContext context, bool isInitial) async {
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
          setInitialAndFinalDateEqual();
          return;
        } else {
          _finalDateController.text = "${TimeNumberFormat.formatTwoDigits(picked.day)}-${TimeNumberFormat.formatTwoDigits(picked.month)}-${picked.year}";
          finalDateText = "${picked.day}-${picked.month}-${picked.year}";
          setInitialAndFinalDateEqual();
          return;
        }
      });
    }
  }
}