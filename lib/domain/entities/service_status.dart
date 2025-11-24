
enum ServiceStatus {
  waiting('Esperando respuesta'),
  accepted('Aceptado'),
  process('En proceso'),
  canceled('Cancelado'),
  rejected('Rechazado'),
  completed('Completado');

  final String value;
  const ServiceStatus(this.value);
}