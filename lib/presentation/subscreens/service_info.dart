import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:ninerapp/domain/repositories/iservice_repository.dart';
import 'package:ninerapp/presentation/subscreens/chat.dart';
import 'package:ninerapp/presentation/subscreens/child_info.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';

class ServiceInfoScreen extends StatefulWidget {
  final Person person;
  final Service service;
  final Parent parent;
  final Babysitter babysitter;

  const ServiceInfoScreen({
    super.key,
    required this.person,
    required this.service,
    required this.parent,
    required this.babysitter,
  });

  @override
  State<ServiceInfoScreen> createState() => _ServiceInfoScreenState();
}

class _ServiceInfoScreenState extends State<ServiceInfoScreen> {
  final IServiceRepository _serviceRepository = getIt<IServiceRepository>();
  bool _isLoading = true;
  String? _errorMessage;
  late Service serviceUpdated;

  @override
  void initState() {
    super.initState();
    loadService();
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Datos de solicitud", style: AppTextstyles.appBarText),
      ),
      body: Padding(
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
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppButton(
                    onPressed: () => Navigator.pop(context),
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
      ),
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
        builder: (context) => ChatScreen(parent: widget.parent, babysitter: widget.babysitter, currentUserIsParent: widget.person is Parent),
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
