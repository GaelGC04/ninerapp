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

class Login extends StatefulWidget {
  final Function(Person) setUser;
  final Function(bool) toggleLoginRegister;

  const Login({
    super.key,
    required this.setUser,
    required this.toggleLoginRegister
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final IParentRepository _parentRepository = getIt<IParentRepository>();
  final IBabysitterRepository _babysitterRepository = getIt<IBabysitterRepository>();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _formIsValid = false;
  bool _loading = false;

  bool _notRegistered = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          SizedBox(height: 60),
          formContainer(),
          SizedBox(height: 90),
          bottom()
        ],
      ),
    );
  }

  Column bottom() {
    return Column(
      children: [
        Text("¿No tienes una cuenta?", style: AppTextstyles.loginTitle.copyWith(color: AppColors.green)),
        SizedBox(height: 10),
        AppButton(
          onPressed: (){
            widget.toggleLoginRegister(false);
          },
          backgroundColor: AppColors.green,
          textColor: AppColors.white,
          text: "Registrate",
          icon: FontAwesomeIcons.plus,
          coloredBorder: false
        )
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
            Text('Correo electrónico: *', style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _emailController,
              hintText: "Ingresar correo electrónico",
              validation: (){
                setState(() {
                  _formIsValid = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
                });
              }
            ),
            const SizedBox(height: 20),
            Text('Contraseña: *', style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _passwordController,
              hintText: "Ingresar contraseña",
              validation: (){
                setState(() {
                  _formIsValid = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
                });
              }
            ),

            if (_notRegistered == true) ...[
              const SizedBox(height: 20),
              Text('Las credenciales son incorrectas, inténtalo de nuevo', style: AppTextstyles.bodyText.copyWith(color: AppColors.red)),
            ],

            const SizedBox(height: 30),
            Center(
              child: AppButton(
                onPressed: startSession,
                backgroundColor: AppColors.currentSectionColor,
                textColor: AppColors.white,
                text: 'Iniciar sesión',
                icon: FontAwesomeIcons.doorOpen,
                coloredBorder: false,
                isLocked: _formIsValid == false || _loading == true,
              ),
            )
          ],
        ),
      ),
    );
  }

  void startSession() async {
    setState(() {
      _loading = true;
    });
    Parent? loggedParent = await _parentRepository.getParentByEmailAndPassword(_emailController.text, Cipher.hashPassword(_passwordController.text));
    Babysitter? loggedBabysitter = await _babysitterRepository.getBabysitterByEmailAndPassword(_emailController.text, Cipher.hashPassword(_passwordController.text));

    if (loggedParent == null && loggedBabysitter == null) {
      setState(() {
        _loading = false;
        _notRegistered = true;
      });
      return;
    }
    if (loggedParent != null) {
      widget.setUser(loggedParent);
    } else if (loggedBabysitter != null){
      widget.setUser(loggedBabysitter);
    }
  }

  Row header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text("NiñerApp", style: AppTextstyles.loginAppNameTitle),
            const SizedBox(height: 10),
            CircleAvatar(radius: 35, backgroundImage: AssetImage('assets/img/logo.png')),
            const SizedBox(height: 10),
            Text("Bienvenido, identifícate", style: AppTextstyles.loginTitle),
          ],
        ),
      ],
    );
  }
}