import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_shadows.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/core/util/cipher.dart';
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

  bool _isParent = true;
  bool _isFemale = true;

  bool _formIsValid = false;
  bool _loading = false;

  bool _emailIsRegistered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
            ),
          ),
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
            Text('Nombre(s):', style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _nameController,
              hintText: "Ingresar nombre(s)",
              validation: (){
                setState(() {
                  _formIsValid = _emailController.text.isNotEmpty && _nameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
                });
              }
            ),
            const SizedBox(height: 20),

            Text('Apellido(s):', style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _lastNameController,
              hintText: "Ingresar apellido(s)",
              validation: (){
                setState(() {
                  _formIsValid = _emailController.text.isNotEmpty && _nameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
                });
              }
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

            Text('Correo electrónico:', style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _emailController,
              hintText: "Ingresar correo electrónico",
              validation: (){
                setState(() {
                  _formIsValid = _emailController.text.isNotEmpty && _nameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
                });
              }
            ),
            const SizedBox(height: 20),

            Text('Contraseña:', style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _passwordController,
              hintText: "Ingresar contraseña",
              validation: (){
                setState(() {
                  _formIsValid = _emailController.text.isNotEmpty && _nameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
                });
              }
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
                  },
                  backgroundColor: !_isParent ? AppColors.currentSectionColor : AppColors.white,
                  textColor: !_isParent ? AppColors.white : AppColors.currentSectionColor,
                  text: _isFemale == true ? 'Niñera' : 'Niñero',
                  icon: null,
                  coloredBorder: !_isParent ? true : false
                ),
              ],
            ),

            if (_emailIsRegistered == true) ...[
              const SizedBox(height: 20),
              Text('El correo ingresado ya está registrado', style: AppTextstyles.bodyText.copyWith(color: AppColors.red)),
            ],

            const SizedBox(height: 30),

            Center(
              child: AppButton(
                onPressed: () async {
                  setState(() {
                    _loading = true;
                  });
                  late Parent newParent;
                  late Babysitter newBabysitter;
                  bool notExists = true;
                  if (await _babysitterRepository.getBabysitterByEmail(_emailController.text) != null || await _parentRepository.getParentByEmail(_emailController.text) != null) {
                    notExists = false;
                  }

                  if (notExists == false) {
                    setState(() {
                      _loading = false;
                      _emailIsRegistered = !notExists;
                    });
                    return;
                  }
                  if (_isParent == true) {
                    newParent = Parent(
                      password: Cipher.hashPassword(_passwordController.text),
                      name: _nameController.text,
                      lastName: _lastNameController.text,
                      birthdate: null,
                      email: _emailController.text,
                      isFemale: _isFemale,
                      stars: 0,
                    );
                  } else if (_isParent == false) {
                    newBabysitter = Babysitter(
                      password: Cipher.hashPassword(_passwordController.text),
                      name: _nameController.text,
                      lastName: _lastNameController.text,
                      birthdate: null,
                      isFemale: _isFemale,
                      email: _emailController.text,
                      pricePerHour: 0,
                      workStartYear: 0,
                      expPhysicalDisability: false,
                      expHearingDisability: false,
                      expVisualDisability: false,
                      expOtherDisabilities: null,
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
                },
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