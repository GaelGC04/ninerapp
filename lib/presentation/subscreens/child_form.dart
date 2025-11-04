import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/core/util/time_number_format.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/child.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/repositories/ichild_repository.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';
import 'package:ninerapp/presentation/widgets/app_text_field.dart';

class ChildFormScreen extends StatefulWidget {
  final Parent parent;
  final VoidCallback onSave;

  const ChildFormScreen({
    super.key,
    required this.onSave,
    required this.parent
  });

  @override
  State<ChildFormScreen> createState() => _ChildFormScreenState();
}

class _ChildFormScreenState extends State<ChildFormScreen> {
  // HACER luego poner para que se pueda usar para editar y obtener datos de parametros
  final IChildRepository _childRepository = getIt<IChildRepository>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _otherDisabilityController = TextEditingController();

  String _birthdateText = "";
  String? _selectedGender = 'Mujer';
  bool _disabilityFisica = false;
  bool _disabilityAuditiva = false;
  bool _disabilityVisual = false;

  bool _formIsValid = false;
  bool _addingChild = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _birthdateController.dispose();
    _otherDisabilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Hijo(a)', style: AppTextstyles.appBarText),
        centerTitle: false,
        backgroundColor: AppColors.primary,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nombre(s):", style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _nameController,
              hintText: 'Nombre(s)',
              validation: () {
                setState(() {
                  _formIsValid = (_nameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _birthdateText.isNotEmpty);
                });
              },
            ),
            const SizedBox(height: 20),

            Text("Apellido(s):", style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _lastNameController,
              hintText: 'Apellido(s)',
              validation: () {
                setState(() {
                  _formIsValid = (_nameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _birthdateText.isNotEmpty);
                });
              },
            ),
            const SizedBox(height: 20),

            Text("Fecha de nacimiento:", style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            GestureDetector( // Con esto se puede hacer que se abra un cuadro para la fecha
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: AppTextField(
                  controller: _birthdateController,
                  hintText: "Ingresar fecha de nacimiento",
                  validation: () {}
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text("Sexo:", style: AppTextstyles.bodyText),
            Row(
              children: [
                Expanded(
                  child: RadioGroup<String>(
                    groupValue: _selectedGender,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Radio<String>(value: 'Mujer'),
                            Text('Mujer', style: AppTextstyles.bodyText),
                          ],
                        ),
                        Row(
                        children: [
                            Radio<String>(value: 'Hombre'),
                            Text('Hombre', style: AppTextstyles.bodyText),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text("Discapacidades:", style: AppTextstyles.bodyText),
            _buildCheckboxListTile('Física', _disabilityFisica, (bool? value) {
              setState(() {
                _disabilityFisica = value!;
              });
            }),
            _buildCheckboxListTile('Auditiva', _disabilityAuditiva, (bool? value) {
              setState(() {
                _disabilityAuditiva = value!;
              });
            }),
            _buildCheckboxListTile('Visual', _disabilityVisual, (bool? value) {
              setState(() {
                _disabilityVisual = value!;
              });
            }),
            const SizedBox(height: 10),

            Text("Otra(s):", style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _otherDisabilityController,
              hintText: 'Ingresar otra(s) discapacidad(es)',
              validation: () {
                _formIsValid = (_nameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _birthdateController.text.isNotEmpty);
              },
            ),

            const SizedBox(height: 30),
            if (_formIsValid == false) ...[
              Center(child: Text("Favor de llenar todo el formulario para continuar con el registro", style: AppTextstyles.bodyText.copyWith(color: AppColors.red), textAlign: TextAlign.center)),
              const SizedBox(height: 20),
            ],

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
                  onPressed: _saveChild,
                  backgroundColor: AppColors.currentSectionColor,
                  textColor: AppColors.white,
                  text: 'Guardar',
                  icon: FontAwesomeIcons.plus,
                  coloredBorder: false,
                  isLocked: _formIsValid == false || _addingChild == true,
                ),
              ]
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  void _saveChild() async {
    setState(() {
      _addingChild = true;
    });

    final String newName = _nameController.text.trim();
    final String newLastName = _lastNameController.text.trim();
    final DateTime newBirthdate = DateFormat('dd-MM-yyyy').parse(_birthdateText.trim());
    final bool newIsFemale = _selectedGender == 'Mujer';
    final bool newDisabilityFisica = _disabilityFisica;
    final bool newDisabilityAuditiva = _disabilityAuditiva;
    final bool newDisabilityVisual = _disabilityVisual;
    final String? newOtherDisability = _otherDisabilityController.text.trim().isEmpty ? null : _otherDisabilityController.text.trim();

    await _childRepository.addChild(
      Child(
        name: newName,
        lastName: newLastName,
        birthdate: newBirthdate,
        isFemale: newIsFemale,
        parentId: widget.parent.id!,
        physicalDisability: newDisabilityFisica,
        hearingDisability: newDisabilityAuditiva,
        visualDisability: newDisabilityVisual,
        otherDisabilities: newOtherDisability,
        lastLatitude: null,
        lastLongitude: null,
      )
    );

    if (!mounted) return;
    widget.onSave();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text = "${TimeNumberFormat.formatTwoDigits(picked.day)}-${TimeNumberFormat.getMonthName(picked.month)}-${picked.year}";
        _birthdateText = "${picked.day}-${picked.month}-${picked.year}";
        _formIsValid = (_nameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _birthdateText.isNotEmpty);
      });
    }
  }

  Widget _buildCheckboxListTile(String title, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.currentSectionColor,
        ),
        Text(title, style: AppTextstyles.bodyText),
      ],
    );
  }
}
