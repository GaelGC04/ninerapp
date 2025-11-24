import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_shadows.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/core/util/time_number_format.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/child.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/entities/person.dart';
import 'package:ninerapp/domain/entities/service.dart';
import 'package:ninerapp/domain/entities/service_status.dart';
import 'package:ninerapp/domain/repositories/iservice_repository.dart';
import 'package:ninerapp/presentation/subscreens/chat.dart';
import 'package:ninerapp/presentation/subscreens/child_info.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';

class ServiceInfoScreen extends StatefulWidget {
  final Person person;
  final Service service;
  final Parent parent;
  final Babysitter babysitter;
  final VoidCallback onWindowExit;

  const ServiceInfoScreen({
    super.key,
    required this.person,
    required this.service,
    required this.parent,
    required this.babysitter,
    required this.onWindowExit,
  });

  @override
  State<ServiceInfoScreen> createState() => _ServiceInfoScreenState();
}

class _ServiceInfoScreenState extends State<ServiceInfoScreen> {
  final IServiceRepository _serviceRepository = getIt<IServiceRepository>();
  bool _isLoading = true;
  String? _errorMessage;
  late Service serviceUpdated;
  
  LatLng _currentLocation = LatLng(22.769684, -102.576787);
  final Set<Marker> _markers = {};
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    loadService();
  }
 
  void _getLocation() async {
    final LatLng newLocation = LatLng(widget.service.latitude, widget.service.longitude);

    setState(() {
      _currentLocation = newLocation;
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_currentLocation),
      );

      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentLocation,
          infoWindow: InfoWindow(
            title: 'Ubicación del servicio',
          ),
        ),
      );
    });
  }

  Future<void> loadService() async {
    try {
      final service = await _serviceRepository.getServiceById(widget.service.id!);
      setState(() {
        serviceUpdated = service;

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains("SocketException")) {
            _errorMessage = 'No hay conexión a internet. Favor de verificar la red o intentar de nuevo más tarde.';
          } else {
            _errorMessage = 'Error al cargar el servicio: ${e.toString()}';
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onExit();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text("Datos de solicitud", style: AppTextstyles.appBarText),
        ),
        body: showServiceInfo(context),
      ),
    );
  }

  Padding showServiceInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (_isLoading == true) ...[
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Center(child: CircularProgressIndicator(color: AppColors.primary))
              )
            ] else if (_errorMessage != null) ...[
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Center(child: Text(_errorMessage!, style: AppTextstyles.appBarText.copyWith(color: AppColors.red), textAlign: TextAlign.center))
              )
            ] else ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.person is Parent) ...[
                                Text("${widget.babysitter.isFemale == true ? 'Niñera' : 'Niñero'}:", textAlign: TextAlign.start, style: AppTextstyles.bodyText),
                                Text(" - ${widget.babysitter.name} ${widget.babysitter.lastName}", textAlign: TextAlign.start, style: AppTextstyles.bodyText, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ] else if (widget.person is Babysitter) ...[
                                Text("${widget.parent.isFemale == true ? 'Madre' : 'Padre'}:", textAlign: TextAlign.start, style: AppTextstyles.bodyText),
                                Text(" - ${widget.parent.name} ${widget.parent.lastName}", textAlign: TextAlign.start, style: AppTextstyles.bodyText, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ],
                          ),
                        ),
                        Tooltip(
                          message: "Abrir chat",
                          child: IconButton(
                            onPressed: showServiceChat,
                            icon: Icon(FontAwesomeIcons.solidEnvelope), color: AppColors.currentListOption,
                            style: ButtonStyle(overlayColor: WidgetStateProperty.all(AppColors.invisible))
                          ),
                        ),
                      ]
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Estado del servicio:", textAlign: TextAlign.start, style: AppTextstyles.bodyText),
                          Text(" - ${serviceUpdated.status}", textAlign: TextAlign.start, style: AppTextstyles.bodyText, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Fecha:", textAlign: TextAlign.start, style: AppTextstyles.bodyText),
                          Text(" - ${TimeNumberFormat.parseDate(serviceUpdated.date, true, true)}", textAlign: TextAlign.start, style: AppTextstyles.bodyText, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Horas: ${serviceUpdated.hours}", textAlign: TextAlign.start, style: AppTextstyles.bodyText),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Minutos: ${serviceUpdated.minutes}", textAlign: TextAlign.start, style: AppTextstyles.bodyText),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Instrucciones adicionales:", textAlign: TextAlign.start, style: AppTextstyles.bodyText),
                          Text(serviceUpdated.instructions ?? "Sin instrucciones", textAlign: TextAlign.start, style: AppTextstyles.bodyText),
                        ],
                      ),
                    ),
                    _multipleInfoSection(
                      "Niños a cuidar:",
                      [
                        ...serviceUpdated.children.map((child) {
                          return (child);
                        }),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Costo total del servicio: \$${widget.service.totalPrice.toStringAsFixed(2)} mxn por 2 horas", textAlign: TextAlign.center, style: AppTextstyles.indexSubtitle.copyWith(color: AppColors.currentSectionColor)),
                          if (widget.service.paymentWithCard == true) ...[
                            Text("Pagado con tarjeta", textAlign: TextAlign.center, style: AppTextstyles.indexSubtitle.copyWith(color: AppColors.currentSectionColor)),
                          ] else ...[
                            Text("Pagar en efectivo al recoger a los niños", textAlign: TextAlign.center, style: AppTextstyles.indexSubtitle.copyWith(color: AppColors.currentSectionColor)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ubicación del servicio:", textAlign: TextAlign.start, style: AppTextstyles.bodyText),
                        ],
                      ),
                    ),
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
                            _getLocation();
                          },
                          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                            Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                            Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 45),
                    if (widget.service.status == ServiceStatus.canceled.value
                    || widget.service.status == ServiceStatus.completed.value
                    || widget.service.status == ServiceStatus.rejected.value) ...[
                      if ((widget.person is Parent == true && serviceUpdated.ratedByParent == false)
                      || (widget.person is Babysitter == true && serviceUpdated.ratedByBabysitter == false)) ...[
                        showRateSection(),
                      ] else if ((widget.person is Parent == true && serviceUpdated.ratedByParent == true)
                      || (widget.person is Babysitter == true && serviceUpdated.ratedByBabysitter == true)) ...[
                        showRatedDoneMessage(),
                      ],
                      const SizedBox(height: 25),
                    ],
                    if ((widget.person is Parent == true && serviceUpdated.reportedByParent == false)
                    || (widget.person is Babysitter == true && serviceUpdated.reportedByBabysitter == false)) ...[
                      showReportSection(),
                    ] else if ((widget.person is Parent == true && serviceUpdated.reportedByParent == true)
                    || (widget.person is Babysitter == true && serviceUpdated.reportedByBabysitter == true)) ...[
                      showReportDoneMessage(),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppButton(
                  onPressed: () => onExit(),
                  backgroundColor: AppColors.currentSectionColor,
                  textColor: AppColors.white,
                  text: "Volver",
                  icon: null,
                  coloredBorder: true
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void onExit() {
    widget.onWindowExit();
    Navigator.of(context).pop();
  }

  Container showRateSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.green,
          width: 2,
        ),
        color: AppColors.lightGreen,
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          if (widget.person is Parent) ...[
            Text("Calificar a ${widget.babysitter.name} ${widget.babysitter.lastName}", style: TextStyle(color: AppColors.green), textAlign: TextAlign.center),
          ] else  ...[
            Text("Calificar a ${widget.parent.name} ${widget.parent.lastName}", style: TextStyle(color: AppColors.green), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int starsIterator = 0; starsIterator < 5; starsIterator++) ...[
                Tooltip(
                  message: "${starsIterator + 1} Estrellas",
                  child: IconButton(
                    onPressed: (){
                      rateUser(starsIterator + 1);
                    },
                    icon: Icon(FontAwesomeIcons.solidStar),
                    color: AppColors.green,
                    hoverColor: AppColors.invisible,
                    splashColor: AppColors.invisible,
                    highlightColor: AppColors.invisible
                  ),
                ),
              ]
            ]
          ),
          const SizedBox(height: 10),
        ]
      )
    );
  }

  Container showRatedDoneMessage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      width: double.infinity,
      child: Text("Ya has calificado a ${widget.person is Parent == true ? "${widget.babysitter.name} ${widget.babysitter.lastName}" : "${widget.parent.name} ${widget.parent.lastName}"} en este servicio", style: TextStyle(color: AppColors.green), textAlign: TextAlign.center),
    );
  }

  void rateUser(int starsAmount) async {
    bool result = await _serviceRepository.updateUserRate(widget.service, widget.person is Parent == true, starsAmount);
    if (result == false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ha ocurrido un error al enviar la calificación, intentar de nuevo más tarde', style: TextStyle(color: AppColors.white)),
            backgroundColor: AppColors.red,
          ),
        );
      }
      return;
    }
    setState(() {
      if (widget.person is Parent) {
        serviceUpdated.ratedByParent = true;
      } else if (widget.person is Babysitter) {
        serviceUpdated.ratedByBabysitter = true;
      }
    });
  }

  AppButton showReportSection() {
    return AppButton(
      onPressed: () => showConfirmReportWindow(),
      backgroundColor: AppColors.red,
      textColor: AppColors.lightRed,
      text: (widget.person is Parent == true) ? "Reportar a ${widget.babysitter.name} ${widget.babysitter.lastName}" : "Reportar a ${widget.parent.name} ${widget.parent.lastName}",
      icon: null,
      coloredBorder: true
    );
  }

  void showConfirmReportWindow() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: null,
          contentPadding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
          actionsPadding: const EdgeInsets.only(bottom: 40, top: 20, left: 20, right: 20),
          content: Text('¿Deseas reportar a ${(widget.person is Parent == true) ? "${widget.babysitter.name} ${widget.babysitter.lastName}" : "${widget.parent.name} ${widget.parent.lastName}"}?', style: AppTextstyles.bodyText.copyWith(color: AppColors.currentSectionColor, fontSize: 22), textAlign: TextAlign.center),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton (
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  backgroundColor: AppColors.currentSectionColor,
                  textColor: AppColors.white,
                  text: "No",
                  icon: null,
                  coloredBorder: true
                ),
                const SizedBox(width: 30),
                AppButton (
                  onPressed: () {
                    reportUser();
                    Navigator.of(context).pop();
                  },
                  backgroundColor: AppColors.currentSectionColor,
                  textColor: AppColors.white,
                  text: "Si",
                  icon: null,
                  coloredBorder: false
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void reportUser() async {
    bool result = await _serviceRepository.updateUserReports(widget.service, widget.person is Parent == true);
    if (result == false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ha ocurrido un error al enviar el reporte, intentar de nuevo más tarde', style: TextStyle(color: AppColors.white)),
            backgroundColor: AppColors.red,
          ),
        );
      }
      return;
    }
    setState(() {
      if (widget.person is Parent) {
        serviceUpdated.reportedByParent = true;
      } else if (widget.person is Babysitter) {
        serviceUpdated.reportedByBabysitter = true;
      }
    });
  }

  Container showReportDoneMessage() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      width: double.infinity,
      child: Text("Ya has reportado a ${widget.person is Parent == true ? "${widget.babysitter.name} ${widget.babysitter.lastName}" : "${widget.parent.name} ${widget.parent.lastName}"} en este servicio", style: TextStyle(color: AppColors.red), textAlign: TextAlign.center),
    );
  }

  SizedBox _multipleInfoSection(String title, List<Child> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("\n$title", style: AppTextstyles.bodyText),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [AppShadows.inputShadow]
              ),
              child: Row(
                children: [
                  Expanded(child: Text("${item.name} ${item.lastName}", style: AppTextstyles.bodyText, textAlign: TextAlign.start, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 10),
                  Tooltip(
                    message: "Ver detalles",
                    child: IconButton(
                      onPressed: () {
                        showChildInfo(item);
                      },
                      icon: Icon(FontAwesomeIcons.solidEye, size: 20), color: AppColors.green,
                      style: ButtonStyle(overlayColor: WidgetStateProperty.all(AppColors.invisible))
                    ),
                  ),
                ],
              )
            ),
          )),
        ],
      ),
    );
  }

  void showServiceChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(parent: widget.parent, babysitter: widget.babysitter, currentUserIsParent: widget.person is Parent, service: widget.service),
      ),
    );
  }

  void showChildInfo(Child child) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChildInfoScreen(child: child),
      ),
    );
  }
}
