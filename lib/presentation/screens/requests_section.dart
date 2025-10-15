import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/entities/service.dart';
import 'package:ninerapp/domain/entities/service_status.dart';
import 'package:ninerapp/domain/repositories/iservice_repository.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';
import 'package:ninerapp/presentation/widgets/service_card.dart';

class RequestsSection extends StatefulWidget {
  final Parent parent;
  
  const RequestsSection({
    super.key,
    required this.parent
  });

  @override
  State<RequestsSection> createState() => _RequestsSectionState();
}

class _RequestsSectionState extends State<RequestsSection> {
  final IServiceRepository _serviceRepository = getIt<IServiceRepository>();
  List<Service> servicesList = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _showingFinishedServices = false;

  @override
  void initState() {
    super.initState();
    _loadServices(false);
  }

  Future<void> _loadServices(bool isFinished) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showingFinishedServices = isFinished;
    });

    try {
      final servicesRes = await _serviceRepository.getServicesByParentId(widget.parent.id!, isFinished);
      setState(() {
        servicesList = servicesRes;

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains("SocketException")) {
            _errorMessage = 'No hay conexión a internet. Favor de verificar la red o intentar de nuevo más tarde.';
          } else {
            _errorMessage = 'Error al cargar los servicios solicitados: ${e.toString()}';
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showingFinishedServices == true ? 'Historial de servicios' : 'Servicios', style: AppTextstyles.appBarText),
        centerTitle: false,
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          if (_isLoading)
            Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else if (_errorMessage != null)
            Expanded(child: Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(_errorMessage!, style: AppTextstyles.appBarText.copyWith(color: AppColors.red), textAlign: TextAlign.center))))
          else if (servicesList.isEmpty) ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text("No se han encontrado servicios ${_showingFinishedServices == true ? 'finalizados' : 'en proceso'}, ${_showingFinishedServices == true ? 'se mostrarán servicios hasta que hayan finalizado aquí...' : 'contrata un niñero para mostrar servicios aquí...'}", style: AppTextstyles.appBarText))],
              ),
            ),
          ] else ... [
            Expanded(
              child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      ...servicesList.map((service) {
                        return ServiceCard(
                          service: service,
                          onCancel: () => onCancelAction(service.id!, ServiceStatus.canceled.value),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 10),
          AppButton(
            onPressed: () async {
              _loadServices(!_showingFinishedServices);
            },
            backgroundColor: AppColors.currentListOption,
            textColor: AppColors.white,
            text: _showingFinishedServices == true ? 'Ver servicios en proceso' : 'Ver servicios finalizados',
            icon: FontAwesomeIcons.solidEye,
            coloredBorder: true,
            isLocked: _isLoading == true,
          ),
          SizedBox(height: 20),
        ]
      )
    );
  }

  void onCancelAction(int id, String status) async {
    await _serviceRepository.updateServiceStatus(id, status);
    _loadServices(_showingFinishedServices);
  }
}