import 'package:familyapp/model/calendarEvent_model.dart';

abstract class CalendarEventState {}

class CalendarInitial extends CalendarEventState {}

class EventCreated extends CalendarEventState {}

class EventLoading extends CalendarEventState {}

class EventUpdated extends CalendarEventState {}

class EventDeleted extends CalendarEventState {}

class CalendarError extends CalendarEventState {
  final String message;
  CalendarError(this.message);
}

class EventsLoaded extends CalendarEventState {
  final Map <DateTime, List<CalendarEvent>> events;
  final DateTime selectedDay;
  final List<CalendarEvent> selectedEvents;

  EventsLoaded({
    required this.events,
    required this.selectedDay,
    required this.selectedEvents,
});
}
