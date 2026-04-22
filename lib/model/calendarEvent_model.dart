class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime firstDay = DateTime(1970,01,01);
  final DateTime lastDay = DateTime(2035,12,31);
  final DateTime focusedDay = DateTime.now();
  final String? recurrence;
  final int notifyBeforeMinutes;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.startDate,
    required this.endDate,
    required this.recurrence,
    required this.notifyBeforeMinutes,
  });
}
