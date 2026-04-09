enum AlertType { temperature, movement, presence, wakeUp }
enum AlertSeverity { info, warning, critical }

class AlertModel {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isRead;

  const AlertModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isRead = false,
  });
}