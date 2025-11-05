import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_shadows.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/core/util/cipher.dart';
import 'package:ninerapp/core/util/time_number_format.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/entities/person.dart';
import 'package:ninerapp/domain/repositories/ibabysitter_repository.dart';
import 'package:ninerapp/domain/repositories/iparent_repository.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';
import 'package:ninerapp/presentation/widgets/app_text_field.dart';

class Register extends StatefulWidget {
  final Function(Person) setUser;
  final Function(bool) toggleLoginRegister;

  const Register({
    super.key,
    required this.setUser,
    required this.toggleLoginRegister
  });

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final IParentRepository _parentRepository = getIt<IParentRepository>();
  final IBabysitterRepository _babysitterRepository = getIt<IBabysitterRepository>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _pricePerHourController = TextEditingController();
  final TextEditingController _experienceYearsController = TextEditingController();

  String _birthdateText = "";

  bool _isParent = true;
  bool _isFemale = true;

  bool _formIsValid = false;
  bool _loading = false;

  bool _emailIsRegistered = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _birthdateController.dispose();
    _pricePerHourController.dispose();
    _experienceYearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: showForm(),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView showForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 60),
          header(),
          SizedBox(height: 40),
          formContainer(),
          SizedBox(height: 80),
          bottom()
        ],
      ),
    );
  }

  Column bottom() {
    return Column(
      children: [
        Text("¿Ya tienes una cuenta?", style: AppTextstyles.loginTitle.copyWith(color: AppColors.green)),
        SizedBox(height: 10),
        AppButton(
          onPressed: (){
            widget.toggleLoginRegister(true);
          },
          backgroundColor: AppColors.green,
          textColor: AppColors.white,
          text: "Inicia sesión",
          icon: FontAwesomeIcons.doorOpen,
          coloredBorder: false
        ),
      ]
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

            Text('Correo electrónico: *', style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _emailController,
              hintText: "Ingresar correo electrónico",
              validation: _validateForm
            ),
            const SizedBox(height: 20),

            Text('Contraseña: *', style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _passwordController,
              hintText: "Ingresar contraseña",
              validation: _validateForm
            ),
            const SizedBox(height: 20),

            Text('¿Eres ${_isFemale == true ? 'madre o niñera' : 'padre o niñero'}?:', style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppButton(
                  onPressed: (){
                    setState(() {
                      _isParent = true;
                    });
                    _validateForm();
                  },
                  backgroundColor: _isParent ? AppColors.currentSectionColor : AppColors.white,
                  textColor: _isParent ? AppColors.white : AppColors.currentSectionColor,
                  text: _isFemale == true ? 'Madre' : 'Padre',
                  icon: null,
                  coloredBorder: _isParent ? true : false
                ),
                SizedBox(width: 30),
                AppButton(
                  onPressed: (){
                    setState(() {
                      _isParent = false;
                    });
                    _validateForm();
                  },
                  backgroundColor: !_isParent ? AppColors.currentSectionColor : AppColors.white,
                  textColor: !_isParent ? AppColors.white : AppColors.currentSectionColor,
                  text: _isFemale == true ? 'Niñera' : 'Niñero',
                  icon: null,
                  coloredBorder: !_isParent ? true : false,
                ),
              ],
            ),

            if (_isParent == false) ...[
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
            ],

            if (_emailIsRegistered == true) ...[
              const SizedBox(height: 20),
              Text('El correo ingresado ya está registrado', style: AppTextstyles.bodyText.copyWith(color: AppColors.red)),
            ],

            const SizedBox(height: 30),

            Center(
              child: AppButton(
                onPressed: tryRegister,
                backgroundColor: AppColors.currentSectionColor,
                textColor: AppColors.white,
                text: 'Registrarse',
                icon: FontAwesomeIcons.arrowRight,
                coloredBorder: false,
                isLocked: _formIsValid == false || _loading == true,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _validateForm() {
    setState(() {
      if (_isParent == true) {
        _formIsValid = _nameController.text.isNotEmpty
        && _lastNameController.text.isNotEmpty
        && _birthdateController.text.isNotEmpty
        && _emailController.text.isNotEmpty
        && _passwordController.text.isNotEmpty;
      } else if (_isParent == false) {
        _formIsValid = _nameController.text.isNotEmpty
        && _lastNameController.text.isNotEmpty
        && _birthdateController.text.isNotEmpty
        && _emailController.text.isNotEmpty
        && _passwordController.text.isNotEmpty
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
        _formIsValid = (_nameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _birthdateText.isNotEmpty);
      });
    }
  }

  void tryRegister() async {
    setState(() {
      _loading = true;
    });
    late Parent newParent;
    late Babysitter newBabysitter;
    bool notExists = true;
    if (await _babysitterRepository.getBabysitterByEmail(_emailController.text.trim()) != null || await _parentRepository.getParentByEmail(_emailController.text.trim()) != null) {
      notExists = false;
    }

    if (notExists == false) {
      setState(() {
        _loading = false;
        _emailIsRegistered = !notExists;
      });
      return;
    }
    
    final DateTime newBirthdate = DateFormat('dd-MM-yyyy').parse(_birthdateText.trim());
    if (_isParent == true) {
      newParent = Parent(
        password: Cipher.hashPassword(_passwordController.text),
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthdate: newBirthdate,
        email: _emailController.text.trim(),
        isFemale: _isFemale,
        lastLatitude: null,
        lastLongitude: null,
        rating: 0,
        amountRatings: 0,
      );
    } else if (_isParent == false) {
      int currentYear = DateTime.now().year;
      int newExperienceYears = currentYear - int.parse(_experienceYearsController.text);
      newBabysitter = Babysitter(
        password: Cipher.hashPassword(_passwordController.text),
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthdate: newBirthdate,
        isFemale: _isFemale,
        email: _emailController.text.trim(),
        pricePerHour: _pricePerHourController.text.isNotEmpty ? double.parse(_pricePerHourController.text) : 100,
        workStartYear: newExperienceYears,
        expPhysicalDisability: false,
        expHearingDisability: false,
        expVisualDisability: false,
        expOtherDisabilities: null,
        lastLatitude: null,
        lastLongitude: null,
        rating: 0,
        amountRatings: 0,
      );
    }
    if (_isParent == true) {
      int newId = await _parentRepository.addParent(newParent);
      newParent.id = newId;
      widget.setUser(newParent);
    } else {
      int newId = await _babysitterRepository.addBabysitter(newBabysitter);
      newBabysitter.id = newId;
      widget.setUser(newBabysitter);
    }
  }

  Row header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text("Registrate", style: AppTextstyles.loginAppNameTitle),
          ],
        ),
      ],
    );
  }
}