import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_shadows.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/child.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/entities/person.dart';
import 'package:ninerapp/domain/repositories/ibabysitter_repository.dart';
import 'package:ninerapp/domain/repositories/ichild_repository.dart';
import 'package:ninerapp/domain/repositories/iparent_repository.dart';
import 'package:ninerapp/presentation/subscreens/edit_user_screen.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';

class OptionsSection extends StatefulWidget {
  final Person person;
  final VoidCallback onSessionClosed;
  final Function(Person) setUser;

  const OptionsSection({
    super.key,
    required this.person,
    required this.onSessionClosed,
    required this.setUser,
  });

  @override
  State<OptionsSection> createState() => _OptionsSectionState();
}

class _OptionsSectionState extends State<OptionsSection> {
  final IParentRepository _parentRepository = getIt<IParentRepository>();
  final IBabysitterRepository _babysitterRepository = getIt<IBabysitterRepository>();

  final IChildRepository _childRepository = getIt<IChildRepository>();
  List<Child> childrenList = [];

  Parent? _parent;
  Babysitter? _babysitter;
  int _stars = 0;
  bool _isLoading = true;
  String? _errorMessage;

  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final childrenRes = await _childRepository.getChildrenByOrder("Ordenar por nombre (A-Z)", _parent!.id!);
      setState(() {
        childrenList = childrenRes;

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains("SocketException")) {
            _errorMessage = 'No hay conexión a internet. Favor de verificar la red o intentar de nuevo más tarde.';
          } else {
            _errorMessage = 'Error al cargar los hijos: ${e.toString()}';
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    debugPrint("APUNTO DE EJECUTAR IF DE PARENT");
    if (_parent != null) {
      _loadChildren();
    }
    debugPrint("DESPUES DE EJECUTAR IF DE PARENT");
  }

  void _loadData() {
    if (widget.person is Parent) {
      _parent = widget.person as Parent;
      _stars = _parent!.getAverageStars().toInt();
    } else if (widget.person is Babysitter) {
      _babysitter = widget.person as Babysitter;
      _stars = _babysitter!.getAverageStars().toInt();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Opciones', style: AppTextstyles.appBarText),
        centerTitle: false,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            personalInfo(),
            if (widget.person is Parent) ...[
              const SizedBox(height: 20),
              childrenListContent(),
            ],
            const SizedBox(height: 20),
            AppButton(
              onPressed: () {
                widget.onSessionClosed();
              },
              backgroundColor: AppColors.lightGrey,
              textColor: AppColors.fontColor,
              text: "Cerrar sesión",
              icon: FontAwesomeIcons.rightFromBracket,
              coloredBorder: false
            ),
            const SizedBox(height: 14),
            AppButton(
              onPressed: () {
                if (widget.person is Parent) {
                  _parentRepository.deleteParent(_parent!.id!);
                } else if (widget.person is Babysitter) {
                  _babysitterRepository.deleteBabysitter(_babysitter!.id!);
                }
                // await deleteBabysitter / Parent
                widget.onSessionClosed();
              },
              backgroundColor: AppColors.historyColor,
              textColor: AppColors.fontColor,
              text: "Eliminar cuenta",
              icon: FontAwesomeIcons.trash,
              coloredBorder: false
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Container personalInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text('Información personal', style: AppTextstyles.indexSubtitle, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.lightGrey,
              boxShadow: [AppShadows.inputShadow],
            ),
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: ${widget.person.name} ${widget.person.lastName}', style: AppTextstyles.bodyText),
                Text('Edad: ${widget.person.getAge()} años', style: AppTextstyles.bodyText),
                Text('Correo: ${widget.person is Parent ? _parent!.email : _babysitter!.email}', style: AppTextstyles.bodyText),
                Row(
                  children: [
                    Text('Calificación:', style: AppTextstyles.bodyText),
                    ...List.generate(_stars, (index) {
                      return Row(
                        children: [
                          const SizedBox(width: 8),
                          Icon(FontAwesomeIcons.solidStar, color: AppColors.fontColor, size: 16),
                        ]
                      );
                    }),
                    ...List.generate(5 - _stars, (index) {
                      return Row(
                        children: [
                          const SizedBox(width: 8),
                          Icon(FontAwesomeIcons.star, color: AppColors.fontColor, size: 16),
                        ]
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: AppButton(
                    onPressed: (){
                      openUserEditionScreen(widget.person);
                    },
                    backgroundColor: AppColors.currentListOption,
                    textColor: AppColors.white,
                    text: "Editar datos",
                    icon: null,
                    coloredBorder: true
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void openUserEditionScreen(Person currentUser) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditUserScreen(person: currentUser, setUser: widget.setUser),
      ),
    );
  }

  Container childrenListContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text('Hijos', style: AppTextstyles.indexSubtitle, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.lightGrey,
              boxShadow: [AppShadows.inputShadow],
            ),
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...childrenList.map((child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${child.name} ${child.lastName}', style: AppTextstyles.bodyText),
                      Text(child.getAge() <= 0
                        ? child.getAge() == 0
                          ? '- Recién nacido'
                          : '- ${child.getAge().abs()} meses'
                        : '${child.getAge()} años', style: AppTextstyles.bodyText),
                      Text(' - ${child.isFemale == true ? 'Niña' : 'Niño'}', style: AppTextstyles.bodyText),
                      if (childrenList.indexOf(child) != childrenList.length - 1) ...[
                        const Divider(color: AppColors.fontColor, thickness: 1),
                      ],
                    ]
                  );
                }),
                const SizedBox(height: 20),
                Center(
                  child: AppButton(
                    onPressed: (){
                    },
                    backgroundColor: AppColors.currentListOption,
                    textColor: AppColors.white,
                    text: "Añadir hijo",
                    icon: null,
                    coloredBorder: true
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}