class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final DateTime startDate;
  final DateTime endDate;
  final String? recurrence;
  final int notifyBeforeMinutes;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.startDate,
    required this.endDate,
    this.recurrence,
    required this.notifyBeforeMinutes,
  });
}
