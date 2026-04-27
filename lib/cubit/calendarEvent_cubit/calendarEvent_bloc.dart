import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/services/calendarEvent_service.dart';
import 'package:familyapp/model/calendarEvent_model.dart';
import 'package:familyapp/cubit/calendarEvent_cubit/calendarEvent_state.dart';

class CalendarBloc extends Cubit<CalendarEventState> {
  final CalendarService _calendarService;

  CalendarBloc(this._calendarService) : super(CalendarInitial());

  DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> loadEvents({required String groupId}) async {
    emit(EventLoading());

    try {
      final eventsList = await _calendarService.getEvents(groupId: groupId);
      final groupEvents = _groupEvents(eventsList);

      emit(
        EventsLoaded(
          events: groupEvents,
          selectedDay: _normalize(DateTime.now()),
          selectedEvents: groupEvents[_normalize(DateTime.now())] ?? [],
        ),
      );
    } catch (error) {
      emit(CalendarError(error.toString()));
    }
  }

  Future<void> createEvent({
    required String groupId,
    required String title,
    required String createdBy,
    required DateTime startDate,
    required DateTime endDate,
    String? recurrence,
    String description = "",
  }) async {
    emit(EventLoading());

    try {
      await _calendarService.createEvent(
        groupId: groupId,
        title: title,
        createdBy: createdBy,
        startDate: startDate,
        endDate: endDate,
        recurrence: recurrence,
      );

      await loadEvents(groupId: groupId);
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }

  void updateEvent({
    required String groupId,
    required String eventId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String? recurrence,
  }) {
    emit(EventLoading());

    _calendarService
        .updateEvent(
          groupId: groupId,
          eventId: eventId,
          title: title,
          description: description,
          startDate: startDate,
          endDate: endDate,
          recurrence: recurrence,
        )
        .then((_) {
          emit(EventUpdated());
          loadEvents(groupId: groupId);
        })
        .catchError((error) {
          emit(CalendarError(error.toString()));
        });
  }

  void selectDay({
    required DateTime selectedDay,
    required DateTime focusedDay,
    required Map<DateTime, List<CalendarEvent>> events,
  }) {
    final normalized = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );

    final eventsForDay = events[normalized] ?? [];

    emit(
      EventsLoaded(
        events: events,
        selectedDay: selectedDay,
        selectedEvents: eventsForDay,
      ),
    );
  }

  void selectRange({
    required DateTime? start,
    required DateTime? end,
    required DateTime focusedDay,
    required Map<DateTime, List<CalendarEvent>> events,
  }) {
    if (start == null && end == null) return;

    final days = <DateTime>[];

    final s = start ?? end!;
    final e = end ?? start!;

    for (var d = s; !d.isAfter(e); d = d.add(const Duration(days: 1))) {
      days.add(DateTime(d.year, d.month, d.day));
    }

    final result = [for (final day in days) ...?events[day]];

    emit(
      EventsLoaded(
        events: events,
        selectedDay: focusedDay,
        selectedEvents: result,
      ),
    );
  }

  void deleteEvent({required String groupId, required String eventId}) {
    emit(EventLoading());
    _calendarService
        .deleteEvent(groupId: groupId, eventId: eventId)
        .then((_) {
          emit(EventDeleted());
          loadEvents(groupId: groupId);
        })
        .catchError((error) {
          emit(CalendarError(error.toString()));
        });
  }

  Map<DateTime, List<CalendarEvent>> _groupEvents(
    List<CalendarEvent> eventsList,
  ) {
    final map = <DateTime, List<CalendarEvent>>{};

    for (var event in eventsList) {
      DateTime startDate = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );

      DateTime endDate = DateTime(
        event.endDate.year,
        event.endDate.month,
        event.endDate.day,
      );

      for (
        var day = startDate;
        !day.isAfter(endDate);
        day = day.add(const Duration(days: 1))
      ) {
        final normalized = DateTime(day.year, day.month, day.day);

        if (map[normalized] == null) {
          map[normalized] = [];
        }

        map[normalized]!.add(event);
      }
    }

    return map;
  }
}
