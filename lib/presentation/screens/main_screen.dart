import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ninerapp/core/util/location_service.dart';
import 'package:ninerapp/data/services/local_auth_service.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/person.dart';
import 'package:ninerapp/domain/repositories/ibabysitter_repository.dart';
import 'package:ninerapp/domain/repositories/iparent_repository.dart';
import 'package:ninerapp/presentation/screens/babysitters_section.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/presentation/screens/children_section.dart';
import 'package:ninerapp/presentation/screens/login.dart';
import 'package:ninerapp/presentation/screens/register.dart';
import 'package:ninerapp/presentation/screens/requests_section.dart';
import 'package:ninerapp/presentation/screens/home_section.dart';
import 'package:ninerapp/presentation/screens/options_section.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final IParentRepository _parentRepository = getIt<IParentRepository>();
  final IBabysitterRepository _babysitterRepository = getIt<IBabysitterRepository>();
  final LocalAuthService _localAuthService = getIt<LocalAuthService>();

  String currentSection = 'Inicio';

  Person? _user;
  bool _showLogin = true;
  bool _isSessionLoading = true;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadUserFromLocalSession();
      updateLocation();
      setState(() {
        _isSessionLoading = false;
      });
    });
  }

  // Se carga el usuario desde BD local
  Future<void> _loadUserFromLocalSession() async {
    final sessionData = await _localAuthService.loadUserSession();
    if (sessionData != null) {
      final int userId = sessionData['id'];
      final String userType = sessionData['type'];

      try {
        if (userType == 'parent') {
          final Parent parent = await _parentRepository.getParentById(userId);
          setUser(parent, saveLocal: false);
        } else if (userType == 'babysitter') {
          final Babysitter babysitter = await _babysitterRepository.getBabysitterById(userId);
          setUser(babysitter, saveLocal: false);
        }
      } catch (e) {
        debugPrint('Error al cargar sesión local: $e');
        await _localAuthService.clearUserSession();
      }
    }
  }
  // TODO añadir screen de edicion y detalles de hijos
  
  void setUser(Person user, {bool saveLocal = true}) async {
    setState(() {
      currentSection = 'Inicio';
      _showLogin = true;
      _user = user;
    });
    if (saveLocal) {
      await _localAuthService.saveUserSession(user);
    }
    await updateLocation();
  }

  void unsetUser() async {
    await _localAuthService.clearUserSession();
    setState(() {
      _user = null;
    });
  }

  Future<void> updateLocation() async {
    try {
      LatLng? currentLocation = await LocationService.getLocation();

      if (_user == null) return;
      setState(() {
        _user!.lastLatitude = currentLocation?.latitude;
        _user!.lastLongitude = currentLocation?.longitude;
      });
      if (_user != null && _user is Babysitter) {
        Babysitter babysitter = _user as Babysitter;
        await _babysitterRepository.updateBabysitter(babysitter);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void showingLoginScreen(bool value) {
    setState(() {
      _showLogin = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      _isSessionLoading == true
        ? Center(child: CircleAvatar(radius: 60, backgroundImage: AssetImage('assets/img/logo.png')))
        : _user == null
        ? _showLogin == true
          ? showLoginSection()
          : showRegisterSection()
        : Column(
          children: [
            seeMainScreen(),
            showFooter(),
          ],
        ),
    );
  }

  Login showLoginSection() => Login(setUser: setUser, toggleLoginRegister: showingLoginScreen);

  Register showRegisterSection() => Register(setUser: setUser, toggleLoginRegister: showingLoginScreen);

  Expanded seeMainScreen() {
    return Expanded(
      child: switch (currentSection) {
        'Inicio' => HomeSection(user: _user!, changeSection: _changeSection),
        'Hijo(s)' => ChildrenSection(parent: _user! as Parent),
        'HijoAdd' => ChildrenSection(parent: _user! as Parent, addingChild: true),
        'Niñeros' => BabysittersSection(parent: _user! as Parent),
        'Solicitudes' => RequestsSection(person: _user!),
        'Historial' => RequestsSection(person: _user!, showingFinishedServices: true),
        'Opciones' => OptionsSection(person: _user!, onSessionClosed: unsetUser, setUser: setUser),
        _ => HomeSection(user: _user!, changeSection: _changeSection),
      },
    );
  }

  Container showFooter() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
      ),
      // Fila donde van icono y nombre
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerIcon('Inicio', FontAwesomeIcons.solidHouse),
            if (_user is Parent) ...[
              _footerIcon('Hijo(s)', FontAwesomeIcons.baby),
              _footerIcon('Niñeros', FontAwesomeIcons.personBreastfeeding),
            ],
            _footerIcon('Solicitudes', FontAwesomeIcons.personCircleQuestion),
            _footerIcon('Opciones', FontAwesomeIcons.gear),
          ]
        ),
      ),
    );
  }

  Expanded _footerIcon(String sectionName, IconData icon) {
    return Expanded(
      child: InkWell(
        onTap: (){
          _changeSection(sectionName);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: currentSection == sectionName ? AppColors.currentSectionColor : AppColors.fontColor, size: 20),
            Text(sectionName, style: AppTextstyles.footerText.copyWith(color: currentSection == sectionName ? AppColors.currentSectionColor : AppColors.fontColor)),
          ],
        ),
      ),
    );
  }

  void _changeSection(String sectionName) async {
    if (sectionName == 'Inicio') {
      updateLocation();
    }

    return setState(() {
      currentSection = sectionName;
    });
  }
}