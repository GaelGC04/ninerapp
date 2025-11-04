import 'package:flutter/material.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_shadows.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/core/util/time_number_format.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/babysitter.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/entities/person.dart';
import 'package:ninerapp/domain/entities/service.dart';
import 'package:ninerapp/domain/entities/service_status.dart';
import 'package:ninerapp/domain/repositories/iservice_repository.dart';

class ServiceCard extends StatefulWidget {
  final Service service;
  final Person person;
  final VoidCallback onStatusChange;

  const ServiceCard({
    super.key,
    required this.service,
    required this.person,
    required this.onStatusChange,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  final IServiceRepository _serviceRepository = getIt<IServiceRepository>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
//        Navigator.of(context).push(
//          MaterialPageRoute(
//            builder: (context) => ServiceInfoScreen(service: widget.service),
//          ),
//        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [AppShadows.inputShadow],
        ),
        child: showInfo(),
      ),
    );
  }

  Row showInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Solicitud para: ${widget.service.babysitter.name.split(" ")[0]} ${widget.service.babysitter.lastName.split(" ")[0]}', style: AppTextstyles.childCardText, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${widget.service.paymentWithCard == true ? 'Pago con tarjeta' : 'Pago con efectivo'}: \$${widget.service.totalPrice.toStringAsFixed(2)} mxn', style: AppTextstyles.childCardText, maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 10),
              Text('FECHA: ${TimeNumberFormat.formatTwoDigits(widget.service.date.day)}/${TimeNumberFormat.getMonthName(widget.service.date.month)}/${widget.service.date.year} - ${widget.service.date.hour}:${widget.service.date.minute}', style: AppTextstyles.childCardText, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${widget.service.hours} hora${widget.service.hours == 1 ? '' : 's'}, ${widget.service.minutes} minuto${widget.service.minutes == 1 ? '' : 's'}', style: AppTextstyles.childCardText, maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 10),
              Text('ESTADO: ${widget.service.status}', style: AppTextstyles.childCardText.copyWith(color: AppColors.currentListOption), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),

        if (widget.service.status == ServiceStatus.canceled.value || widget.service.status == ServiceStatus.rejected.value || widget.service.status == ServiceStatus.completed.value) ...[
          SizedBox(width: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 35, width: 35,
                child: IconButton(
                  icon: Icon(FontAwesomeIcons.trash, color: AppColors.red, size: 20),
                  onPressed: (){
                    onDeleteService(widget.service.id!, widget.service.parent);
                  }, tooltip: "Eliminar servicio", hoverColor: AppColors.invisible, color: AppColors.invisible
                ),
              ),
            ],
          ),
        ] else ...[
          if (widget.person is Parent && widget.service.status == ServiceStatus.waiting.value) ...[
            SizedBox(width: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 35, width: 35,
                  child: IconButton(
                    icon: Icon(FontAwesomeIcons.circleXmark, color: AppColors.currentSectionColor, size: 20),
                    onPressed: (){
                      changeStatus(widget.service.id!, ServiceStatus.canceled.value);
                    }, tooltip: "Cancelar servicio", hoverColor: AppColors.invisible, color: AppColors.invisible
                  ),
                ),
              ],
            ),
          ] else if (widget.person is Babysitter && widget.service.status == ServiceStatus.waiting.value) ...[
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 35, width: 35,
                  child: IconButton(
                    icon: Icon(FontAwesomeIcons.ban, color: AppColors.red, size: 20),
                    onPressed: (){
                      changeStatus(widget.service.id!, ServiceStatus.canceled.value);
                    }, tooltip: "Rechazar servicio", hoverColor: AppColors.invisible, color: AppColors.invisible
                  ),
                ),
                SizedBox(height: 5),
                SizedBox(
                  height: 35, width: 35,
                  child: IconButton(
                    icon: Icon(FontAwesomeIcons.circleCheck, color: AppColors.green, size: 20),
                    onPressed: (){
                      changeStatus(widget.service.id!, ServiceStatus.canceled.value);
                    }, tooltip: "Aceptar servicio", hoverColor: AppColors.invisible, color: AppColors.invisible
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  void changeStatus(int id, String status) async {
    await _serviceRepository.updateServiceStatus(id, status);
    widget.onStatusChange();
  }

  void onDeleteService(int serviceId, Person person) async {
    await _serviceRepository.deleteService(serviceId, person);
    widget.onStatusChange();
  }
}