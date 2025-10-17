import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/core/util/time_number_format.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/child.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/entities/service.dart';
import 'package:ninerapp/domain/entities/service_status.dart';
import 'package:ninerapp/domain/repositories/ibabysitter_repository.dart';
import 'package:ninerapp/domain/repositories/ichild_repository.dart';
import 'package:ninerapp/domain/repositories/iservice_repository.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';
import 'package:ninerapp/presentation/widgets/app_text_field.dart';
import 'package:ninerapp/data/services/stripe_service.dart';

class RequestBabysitterScreen extends StatefulWidget {
  final Babysitter babysitter;
  final Parent parent;
  final VoidCallback onRequest;

  const RequestBabysitterScreen({
    super.key,
    required this.babysitter,
    required this.parent,
    required this.onRequest,
  });

  @override
  State<RequestBabysitterScreen> createState() => _RequestBabysitterScreenState();
}

class _RequestBabysitterScreenState extends State<RequestBabysitterScreen> {
  final IServiceRepository _serviceRepository = getIt<IServiceRepository>();
  final IBabysitterRepository _babysitterRepository = getIt<IBabysitterRepository>();
  final IChildRepository _childRepository = getIt<IChildRepository>();
  final TextEditingController _serviceDateController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  Map<Child, bool> childrenList = {};
  late Babysitter babysitter;

  String _serviceDateText = "";
  String? _selectedPaymentMethod = 'Tarjeta';
  bool _childrenAreLoading = true;
  String? _childrenErrorMessage;
  bool _babysitterLoading = true;
  String? _babysitterErrorMessage;

  LatLng _currentLocation = LatLng(22.769684, -102.576787);
  final Set<Marker> _markers = {};
  late GoogleMapController _mapController;

  bool _formIsValid = false;
  bool _addingService = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _loadChildren();
    _loadBabysitter();
  }

  Future<void> _getLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();

    if (!mounted) return;

    setState(() {
      _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);

      // Con esta parte se cambia la posición de el mapa al obtener la ubi actual del usuario
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLocation),
      );

      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentLocation,
          infoWindow: InfoWindow(
            title: 'Ubicación del servicio',
            snippet: 'Ubicación actual',
          ),
        ),
      );
    });
  }

  void _updateLocationOnMap(LatLng newLatLng) {
    setState(() {
      _currentLocation = newLatLng;

      // Se quita el marcador anterior
      _markers.clear(); 

      _markers.add(
        Marker(
          markerId: MarkerId('serviceLocation'),
          position: _currentLocation,
          infoWindow: InfoWindow(
            title: 'Ubicación del servicio',
            snippet: 'Ubicación seleccionada',
          ),
        ),
      );

      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLocation),
      );
    });
  }

  Future<void> _loadBabysitter() async {
    setState(() {
      _babysitterLoading = true;
      _babysitterErrorMessage = null;
    });

    try {
      final babysitterRes = await _babysitterRepository.getBabysitterById(widget.babysitter.id!);
      setState(() {
        babysitter = babysitterRes;

        _babysitterLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains("SocketException")) {
            _babysitterErrorMessage = 'No hay conexión a internet. Favor de verificar la red o intentar de nuevo más tarde.';
          } else {
            _babysitterErrorMessage = 'Error al cargar al niñero: ${e.toString()}';
          }
          _babysitterLoading = false;
        });
      }
    }
  }

  Future<void> _loadChildren() async {
    setState(() {
      _childrenAreLoading = true;
      _childrenErrorMessage = null;
    });

    try {
      final childrenRes = await _childRepository.getChildrenByOrder('Ordenar por edad (menor-mayor)', widget.parent.id!);
      setState(() {
        childrenList = {for (var child in childrenRes) child: false};

        _childrenAreLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains("SocketException")) {
            _childrenErrorMessage = 'No hay conexión a internet. Favor de verificar la red o intentar de nuevo más tarde.';
          } else {
            _childrenErrorMessage = 'Error al cargar los hijos: ${e.toString()}';
          }
          _childrenAreLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _serviceDateController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Solicitar niñero", style: AppTextstyles.appBarText),
        centerTitle: false,
        backgroundColor: AppColors.primary,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            babysitterInfo(),
            const SizedBox(height: 30),

            Text("Día y hora del servicio:", style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: AppTextField(
                  controller: _serviceDateController,
                  hintText: "Ingresar día y hora del servicio",
                  validation: () {}
                ),
              ),
            ),
            const SizedBox(height: 20),

            timeRequestedForms(),
            const SizedBox(height: 20),
            
            Text("Instrucciones adicionales:", style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            AppTextField(
              controller: _instructionsController,
              hintText: 'Instrucciones especiales',
              validation: () {},
            ),
            const SizedBox(height: 20),

            Text("Niños a cuidar:", style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            if (_childrenAreLoading) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Cargando niños...", style: AppTextstyles.bodyText),
                  const SizedBox(width: 20),
                  CircularProgressIndicator(color: AppColors.primary),
                ],
              ),
            ] else if (_childrenErrorMessage != null) ...[
              Center(child: Text(_childrenErrorMessage!, style: AppTextstyles.bodyText.copyWith(color: AppColors.red))),
            ] else if (childrenList.isEmpty) ...[
              Center(child: Text("No tienes hijos registrados...", style: AppTextstyles.bodyText)),
            ] else ...[
              ...childrenList.entries.map((entry) {
                final child = entry.key;
                final isSelected = entry.value;
                return Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          childrenList[child] = value!;
                          _formIsValid = (_serviceDateText.isNotEmpty && _hoursController.text.isNotEmpty && _minutesController.text.isNotEmpty && childrenList.values.any((value) => value == true));
                        });
                      },
                      activeColor: AppColors.currentSectionColor,
                    ),
                    Text(child.name, style: AppTextstyles.bodyText),
                  ],
                );
              }),
            ],
            const SizedBox(height: 20),

            Text("Pago:", style: AppTextstyles.bodyText),
            Row(
              children: [
                Expanded(
                  child: RadioGroup<String>(
                    groupValue: _selectedPaymentMethod,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Radio<String>(value: 'Tarjeta'),
                            Expanded(child: Text('Pago con tarjeta ahora', style: AppTextstyles.bodyText)),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(value: 'Efectivo'),
                            Expanded(child: Text('Pago en efectivo al niñero después del servicio', style: AppTextstyles.bodyText, overflow: TextOverflow.ellipsis, maxLines: 2)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text("Seleccionar ubicación donde se cuidará a sus hijos:\n(Latitud): ${_currentLocation.latitude}\n(Longitud): ${_currentLocation.longitude}", style: AppTextstyles.bodyText),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              height: 350,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: _currentLocation, zoom: 17),
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },

                  // Para cuando se deje presionado se asigne una nueva ubicación
                  onLongPress: _updateLocationOnMap,
                  
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                    Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                    Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
                  },
                ),
              ),
            ),
            
            SizedBox(height: 20),
            // La fecha del servicio debe ser ingresadas
            // Las horas deben ser ingresadas
            // Los minutos deben ser ingresados
            // Al menos uno de los niños debe de ser seleccionado de su checkbox
            if (_formIsValid)...[
              Center(child: Text("Total a pagar: \$${(babysitter.pricePerHour * (int.parse(_hoursController.text) + (int.parse(_minutesController.text)/60))).toStringAsFixed(2)} mxn\nPor ${_hoursController.text} horas con ${_minutesController.text} minutos", style: AppTextstyles.bodyText, textAlign: TextAlign.center)),
            ] else ...[
              Center(child: Text("Favor de llenar todo el formulario para continuar con la solicitud", style: AppTextstyles.bodyText.copyWith(color: AppColors.red), textAlign: TextAlign.center)),
            ],
            SizedBox(height: 20),

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
                  coloredBorder: true,
                ),
                AppButton(
                  onPressed: () => requestServiceActionButton(),
                  backgroundColor: AppColors.currentSectionColor,
                  textColor: AppColors.white,
                  text: 'Contratar',
                  icon: FontAwesomeIcons.personCircleQuestion,
                  coloredBorder: false,
                  isLocked: _formIsValid == false || _addingService == true,
                ),
              ]
            ),
          ],
        ),
      ),
    );
  }

  Future<void> requestServiceActionButton() async {
    setState(() {
      _addingService = true;
    });

    bool paymentSuccess = true;

    if (_selectedPaymentMethod == 'Tarjeta') {
      try {
        paymentSuccess = await StripeService.instance.makePayment((babysitter.pricePerHour * (int.parse(_hoursController.text) + (int.parse(_minutesController.text)/60))));
      } catch (e) {
        debugPrint(e.toString());
      }
      if (paymentSuccess == true) {
        await Future.delayed(Duration(seconds: 1));
      }
    }

    if (paymentSuccess == false) {
      setState(() {
        _addingService = false;
      });
      return;
    }

    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    DateTime parsedDate = dateFormat.parse(_serviceDateText);

    Service newService = Service(
      parent: widget.parent,
      babysitter: widget.babysitter,
      children: [],
      paymentWithCard: _selectedPaymentMethod == 'Tarjeta',
      date: parsedDate,
      hours: int.parse(_hoursController.text),
      minutes: int.parse(_minutesController.text),
      totalPrice: (babysitter.pricePerHour * (int.parse(_hoursController.text) + (int.parse(_minutesController.text)/60))),
      status: ServiceStatus.waiting.value,
      latitude: _currentLocation.latitude,
      longitude: _currentLocation.longitude,
      instructions: _instructionsController.text.trim() == "" ? null : _instructionsController.text.trim(),
    );
    for (var child in childrenList.keys) {
      if (childrenList[child] == true) {
        newService.children.add(child);
      }
    }
    await _serviceRepository.addService(newService).whenComplete(() {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      widget.onRequest();
    });
  }

  Row timeRequestedForms() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Horas:", style: AppTextstyles.bodyText),
              const SizedBox(height: 8),
              AppTextField(
                controller: _hoursController,
                hintText: "Horas",
                validation: () {
                  setState(() {
                    if (num.tryParse(_hoursController.text) == null) {
                      _hoursController.text = "";
                    }
                    _formIsValid = (_serviceDateText.isNotEmpty && _hoursController.text.isNotEmpty && _minutesController.text.isNotEmpty && childrenList.values.any((value) => value == true));
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Minutos:", style: AppTextstyles.bodyText),
              const SizedBox(height: 8),
              AppTextField(
                controller: _minutesController,
                hintText: "Minutos",
                validation: () {
                  setState(() {
                    if (num.tryParse(_minutesController.text) == null) {
                      _minutesController.text = "";
                    }
                    _formIsValid = (_serviceDateText.isNotEmpty && _hoursController.text.isNotEmpty && _minutesController.text.isNotEmpty && childrenList.values.any((value) => value == true));
                  });
                }
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      initialDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );

    // Se muestra el selector de hora si es que el usuario selecciona una fecha
    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialTime: TimeOfDay.now(),
      );

      // Si el usuario selecciona una hora
      if (pickedTime != null) {
        // Aqui se junta la fecha y la hora en un solo objeto DateTime
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _serviceDateController.text = "${TimeNumberFormat.formatTwoDigits(finalDateTime.day)}-${TimeNumberFormat.getMonthName(finalDateTime.month)}-${finalDateTime.year} ${TimeNumberFormat.formatTwoDigits(finalDateTime.hour)}:${TimeNumberFormat.formatTwoDigits(finalDateTime.minute)}";
          _serviceDateText = "${finalDateTime.day}-${finalDateTime.month}-${finalDateTime.year} ${finalDateTime.hour}:${finalDateTime.minute}";
          _formIsValid = (_serviceDateText.isNotEmpty && _hoursController.text.isNotEmpty && _minutesController.text.isNotEmpty && childrenList.values.any((value) => value == true));
        });
      }
    }
  }

  Padding babysitterInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (_babysitterLoading) ...[
            Expanded(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Cargando niñero...", style: AppTextstyles.bodyText),
                const SizedBox(width: 20),
                CircularProgressIndicator(color: AppColors.primary),
              ],
            )),
          ] else if (_babysitterErrorMessage != null) ...[
            Expanded(child: Center(child: Text(_babysitterErrorMessage!, style: AppTextstyles.bodyText.copyWith(color: AppColors.red)))),
          ] else ...[
            CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/img/babysitter.png'), // HACER poner imagen respectiva del niñero real guardada en supabase
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${babysitter.name} ${babysitter.lastName}", style: AppTextstyles.bodyText, overflow: TextOverflow.ellipsis, maxLines: 2),
                  SizedBox(width: 15),
                  Text("\$${babysitter.pricePerHour.toStringAsFixed(2)} mxn por hora", style: AppTextstyles.bodyText.copyWith(color: AppColors.green)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}