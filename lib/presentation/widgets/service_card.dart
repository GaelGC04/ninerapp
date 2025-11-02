import 'package:flutter/material.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_shadows.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/core/util/time_number_format.dart';
import 'package:ninerapp/domain/entities/service.dart';

class ServiceCard extends StatefulWidget {
  final Service service;
  final Function() onCancel;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onCancel
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
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
        if (widget.service.status == 'Esperando respuesta') ...[
          SizedBox(width: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 35, width: 35,
                child: IconButton(
                  icon: Icon(FontAwesomeIcons.circleXmark, color: AppColors.red, size: 20),
                  onPressed: (){
                    widget.onCancel();
                    // HACER accion de abrir modal para cancelar en caso de que el estatus sea Esperando respuesta
                  }, tooltip: "Cancelar servicio", hoverColor: AppColors.invisible, color: AppColors.invisible
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }
}