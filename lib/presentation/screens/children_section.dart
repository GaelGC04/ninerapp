import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/domain/entities/child.dart';
import 'package:ninerapp/domain/entities/parent.dart';
import 'package:ninerapp/domain/repositories/ichild_repository.dart';
import 'package:ninerapp/presentation/subscreens/child_form.dart';
import 'package:ninerapp/core/constants/app_colors.dart';
import 'package:ninerapp/core/constants/app_textstyles.dart';
import 'package:ninerapp/presentation/widgets/app_button.dart';
import 'package:ninerapp/presentation/widgets/child_card.dart';

class ChildrenSection extends StatefulWidget {
  final Parent parent;
  
  const ChildrenSection({
    super.key,
    required this.parent
  });

  @override
  State<ChildrenSection> createState() => _ChildrenSectionState();
}

class _ChildrenSectionState extends State<ChildrenSection> {
  final IChildRepository _childRepository = getIt<IChildRepository>();
  List<Child> childrenList = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _orderList = [
    'Ordenar por nombre (A-Z)',
    'Ordenar por nombre (Z-A)',
    'Ordenar por edad (menor-mayor)',
    'Ordenar por edad (mayor-menor)'
  ];
  String _orderBy = 'Ordenar por nombre (A-Z)';

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final childrenRes = await _childRepository.getChildrenByOrder(_orderBy, widget.parent.id!);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hijo(s)', style: AppTextstyles.appBarText),
        centerTitle: false,
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          children: [
            if (_isLoading)
              Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
            else if (_errorMessage != null)
              Expanded(child: Center(child: Text(_errorMessage!, style: AppTextstyles.appBarText.copyWith(color: AppColors.red), textAlign: TextAlign.center)))
            else if (childrenList.isEmpty) ...[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Center(child: Text("No tienes hijos registrados...", style: AppTextstyles.appBarText))],
                ),
              ),
            ] else ... [
              SizedBox(height: 10),
              changeOrderContainer(),
              SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...childrenList.map((child) {
                        return ChildCard(
                          child: child,
                          onEdit: () {
                          },
                          onDelete: () {
                            // HACER pedir confirmacion antes de eliminar hijo
                            _childRepository.deleteChild(child.id!).then((_) {
                              _loadChildren();
                            }).catchError((e) {
                              // HACER mostrar modal diciendo que ocurrio un error al borrar al hijo
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 10),
            AppButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChildFormScreen(onSave: () {_loadChildren();}, parent: widget.parent),
                  ),
                );
              },
              backgroundColor: AppColors.currentListOption,
              textColor: AppColors.white,
              text: 'Añadir Hijo(a)',
              icon: FontAwesomeIcons.plus,
              coloredBorder: true,
            ),
            SizedBox(height: 20),
          ],
        ),
      )
    );
  }

  Row changeOrderContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: AppColors.settingsColor, borderRadius: BorderRadius.circular(10)),
          child: DropdownButton<String>(
            value: _orderBy,
            hint: const Text('Orden'),
            items: _orderList.map((orderOption) {
              return DropdownMenuItem(
                value: orderOption,
                child: Text(orderOption),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _orderBy = newValue!;
                _loadChildren();
              });
            },
          ),
        ),
      ],
    );
  }
}