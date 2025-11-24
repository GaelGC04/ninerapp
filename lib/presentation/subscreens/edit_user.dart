import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_shadows.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/core/util/time_number_format.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/entities/person.dart';
import 'package:ninerapp/domain/repositories/ibabysitter_repository.dart';
import 'package:ninerapp/domain/repositories/iparent_repository.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';
import 'package:ninerapp/presentation/widgets/app_text_field.dart';

class EditUserScreen extends StatefulWidget {
  final Person person;
  final Function(Person) setUser;

  const EditUserScreen({
    super.key,
    required this.person,
    required this.setUser,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final IParentRepository _parentRepository = getIt<IParentRepository>();
  final IBabysitterRepository _babysitterRepository = getIt<IBabysitterRepository>();
  
  Parent? _parent;
  Babysitter? _babysitter;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _pricePerHourController = TextEditingController();
  final TextEditingController _experienceYearsController = TextEditingController();
  final TextEditingController _profileImageUrlController = TextEditingController();
  String _birthdateText = "";
  bool _isFemale = true;

  final TextEditingController _otherDisabilitiesController = TextEditingController();
  bool _expPhysicalDisability = false;
  bool _expHearingDisability = false;
  bool _expVisualDisability = false;

  bool _formIsValid = true;
  bool _emailIsRegistered = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    if (widget.person is Parent) {
      _parent = await _parentRepository.getParentById(widget.person.id!);
      _nameController.text = _parent!.name;
      _lastNameController.text = _parent!.lastName;
      _emailController.text = _parent!.email;
      _birthdateController.text = TimeNumberFormat.parseDate(_parent!.birthdate!, false, false);
      _birthdateText = "${_parent!.birthdate!.day}-${_parent!.birthdate!.month}-${_parent!.birthdate!.year}";
      setState(() {
        _isFemale = _parent!.isFemale;
      });
    } else if (widget.person is Babysitter) {
      _babysitter = widget.person as Babysitter;
      _nameController.text = _babysitter!.name;
      _lastNameController.text = _babysitter!.lastName;
      _emailController.text = _babysitter!.email;
      _birthdateController.text = TimeNumberFormat.parseDate(_babysitter!.birthdate!, false, false);
      _birthdateText = "${_babysitter!.birthdate!.day}-${_babysitter!.birthdate!.month}-${_babysitter!.birthdate!.year}";
      _pricePerHourController.text = _babysitter!.pricePerHour.toString();
      _experienceYearsController.text = (DateTime.now().year - _babysitter!.workStartYear!).toString();
      setState(() {
        _isFemale = _babysitter!.isFemale;
      });
      _expPhysicalDisability = _babysitter!.expPhysicalDisability;
      _expHearingDisability = _babysitter!.expHearingDisability;
      _expVisualDisability = _babysitter!.expVisualDisability;
      _otherDisabilitiesController.text = _babysitter!.expOtherDisabilities ?? "";
      _profileImageUrlController.text = _babysitter!.profileImageUrl ?? "";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _pricePerHourController.dispose();
    _experienceYearsController.dispose();
    _otherDisabilitiesController.dispose();
    _profileImageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar datos", style: AppTextstyles.appBarText),
        centerTitle: false,
        backgroundColor: AppColors.primary,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            formContainer(),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  backgroundColor: AppColors.currentSectionColor,
                  textColor: AppColors.white,
                  text: "Volver",
                  icon: FontAwesomeIcons.arrowLeft,
                  coloredBorder: true
                ),
                const SizedBox(width: 10),
                AppButton(
                  onPressed: editUser,
                  backgroundColor: AppColors.currentSectionColor,
                  textColor: AppColors.white,
                  text: "Guardar",
                  icon: FontAwesomeIcons.floppyDisk,
                  coloredBorder: false,
                  isLocked: _formIsValid == false || _loading == true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container formContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.lightGrey,
        boxShadow: [AppShadows.inputShadow],
      ),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre(s): *', style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _nameController,
              hintText: "Ingresar nombre(s)",
              validation: _validateForm
            ),
            const SizedBox(height: 20),

            Text('Apellido(s): *', style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _lastNameController,
              hintText: "Ingresar apellido(s)",
              validation: _validateForm
            ),
            const SizedBox(height: 20),

            Text('Correo electrónico: *', style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _emailController,
              hintText: "Ingresar correo electrónico",
              validation: _validateForm
            ),
            const SizedBox(height: 20),
            
            Text("Fecha de nacimiento: *", style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: AppTextField(
                  controller: _birthdateController,
                  hintText: "Ingresar fecha de nacimiento",
                  validation: _validateForm
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Text('Género:', style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppButton(
                  onPressed: (){
                    setState(() {
                      _isFemale = true;
                    });
                  },
                  backgroundColor: _isFemale ? AppColors.currentSectionColor : AppColors.white,
                  textColor: _isFemale ? AppColors.white : AppColors.currentSectionColor,
                  text: "Mujer",
                  icon: null,
                  coloredBorder: _isFemale ? true : false
                ),
                SizedBox(width: 30),
                AppButton(
                  onPressed: (){
                    setState(() {
                      _isFemale = false;
                    });
                  },
                  backgroundColor: !_isFemale ? AppColors.currentSectionColor : AppColors.white,
                  textColor: !_isFemale ? AppColors.white : AppColors.currentSectionColor,
                  text: "Hombre",
                  icon: null,
                  coloredBorder: !_isFemale ? true : false
                ),
              ],
            ),

            if (widget.person is Babysitter) ...[
              const SizedBox(height: 20),
              Text('Precio por hora: *', style: AppTextstyles.bodyText),
              const SizedBox(height: 8),
              AppTextField(
                controller: _pricePerHourController,
                hintText: "Precio a cobrar por hora (mxn)",
                validation: _validateForm,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
              ),
              const SizedBox(height: 20),

              Text('Años de experiencia: *', style: AppTextstyles.bodyText),
              const SizedBox(height: 8),
              AppTextField(
                controller: _experienceYearsController,
                hintText: "Años de experiencia",
                validation: (){
                  _experienceYearsController.text = int.tryParse(_experienceYearsController.text.trim()) != null
                    ? int.parse(_experienceYearsController.text.trim()) > 60
                      ? "60"
                      : _experienceYearsController.text.trim()
                    : "0";
                  _validateForm();
                },
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*'))],
              ),
              const SizedBox(height: 20),

              Text('URL de imagen de perfil: *', style: AppTextstyles.bodyText),
              const SizedBox(height: 8),
              AppTextField(
                controller: _profileImageUrlController,
                hintText: "Ingresar url de imagen de perfil",
                validation: (){}
              ),
              const SizedBox(height: 20),

              Text("Experiencia en discapacidades:", style: AppTextstyles.bodyText),
              const SizedBox(height: 8),
              _buildCheckboxListTile('Física', _expPhysicalDisability, (bool? value) {
                setState(() {
                  _expPhysicalDisability = value!;
                });
              }),
              _buildCheckboxListTile('Auditiva', _expHearingDisability, (bool? value) {
                setState(() {
                  _expHearingDisability = value!;
                });
              }),
              _buildCheckboxListTile('Visual', _expVisualDisability, (bool? value) {
                setState(() {
                  _expVisualDisability = value!;
                });
              }),
              const SizedBox(height: 10),

              Text("Otra(s):", style: AppTextstyles.bodyText),
              const SizedBox(height: 8),
              AppTextField(
                controller: _otherDisabilitiesController,
                hintText: 'Ingresar otra(s) discapacidad(es)',
                validation: () {},
              ),
            ],

            if (_emailIsRegistered == true) ...[
              const SizedBox(height: 20),
              Text('El correo ingresado ya está en uso, intentar con otro', style: AppTextstyles.bodyText.copyWith(color: AppColors.red)),
            ],
          ],
        ),
      ),
    );
  }

  void editUser() async {
    setState(() {
      _loading = true;
    });
    try {
      late Parent newParent;
      late Babysitter newBabysitter;
      bool notExists = true;
      Parent? tempParent = await _parentRepository.getParentByEmail(_emailController.text.trim());
      Babysitter? tempBabysitter = await _babysitterRepository.getBabysitterByEmail(_emailController.text.trim());
      if (tempParent != null || tempBabysitter != null) {
        if (tempParent != null && tempParent.id != widget.person.id) {
          notExists = false;
        } else if (tempBabysitter != null && tempBabysitter.id != widget.person.id) {
          notExists = false;
        }
      }

      if (notExists == false) {
        setState(() {
          _loading = false;
          _emailIsRegistered = true;
        });
        return;
      }

      final DateTime newBirthdate = DateFormat('dd-MM-yyyy').parse(_birthdateText.trim());
      if (widget.person is Parent) {
        newParent = Parent(
          id: _parent!.id,
          password: null,
          name: _nameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          birthdate: newBirthdate,
          email: _emailController.text.trim(),
          isFemale: _isFemale,
          lastLatitude: null,
          lastLongitude: null,
          rating: 0,
          amountRatings: 0,
          amountReports: 0,
        );
      } else if (widget.person is Babysitter) {
        int currentYear = DateTime.now().year;
        int newExperienceYears = currentYear - int.parse(_experienceYearsController.text);
        newBabysitter = Babysitter(
          id: _babysitter!.id,
          password: null,
          name: _nameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          birthdate: newBirthdate,
          isFemale: _isFemale,
          email: _emailController.text.trim(),
          pricePerHour: _pricePerHourController.text.isNotEmpty ? double.parse(_pricePerHourController.text) : 100,
          workStartYear: newExperienceYears,
          expPhysicalDisability: _expPhysicalDisability,
          expHearingDisability: _expHearingDisability,
          expVisualDisability: _expVisualDisability,
          expOtherDisabilities: _otherDisabilitiesController.text.isNotEmpty ? _otherDisabilitiesController.text : null,
          lastLatitude: widget.person.lastLatitude,
          lastLongitude: widget.person.lastLongitude,
          rating: _babysitter!.rating,
          amountRatings: _babysitter!.amountRatings,
          profileImageUrl: _profileImageUrlController.text.trim().isEmpty ? null : _profileImageUrlController.text.trim(),
          amountReports: _babysitter!.amountReports,
          isIdentificationSent: _babysitter!.isIdentificationSent,
          isStudySent: _babysitter!.isStudySent,
          isDomicileSent: _babysitter!.isDomicileSent,
        );
      }
      if (widget.person is Parent) {
        await _parentRepository.updateParent(newParent);
        widget.setUser(newParent);
        if (!mounted) return;
        Navigator.of(context).pop();
      } else {
        await _babysitterRepository.updateBabysitter(newBabysitter);
        widget.setUser(newBabysitter);
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _loading = false;
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

  void _validateForm() {
    setState(() {
      if (widget.person is Parent) {
        _formIsValid = _nameController.text.isNotEmpty
        && _lastNameController.text.isNotEmpty
        && _birthdateController.text.isNotEmpty
        && _emailController.text.isNotEmpty;
      } else if (widget.person is Babysitter) {
        _formIsValid = _nameController.text.isNotEmpty
        && _lastNameController.text.isNotEmpty
        && _birthdateController.text.isNotEmpty
        && _emailController.text.isNotEmpty
        && _pricePerHourController.text.isNotEmpty
        && _experienceYearsController.text.isNotEmpty;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime maxDate = DateTime.now().subtract(const Duration(days: 365 * 18));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: maxDate,
      firstDate: DateTime(1900),
      lastDate: maxDate,
    );
    if (picked != null) {
      setState(() {
        _birthdateController.text = "${TimeNumberFormat.formatTwoDigits(picked.day)}-${TimeNumberFormat.getMonthName(picked.month)}-${picked.year}";
        _birthdateText = "${picked.day}-${picked.month}-${picked.year}";
        _validateForm();
      });
    }
  }
}