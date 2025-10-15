
enum ServiceStatus {
  waiting('Esperando respuesta'),
  canceled('Cancelado'),
  rejected('Rechazado'),
  accepted('Aceptado'),
  process('En proceso'),
  completed('Completado');

  final String value;
  const ServiceStatus(this.value);
}