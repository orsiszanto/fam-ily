import 'package:familyapp/design/app_button.dart';
import 'package:familyapp/design/colors.dart';
import 'package:familyapp/design/spacing.dart';
import 'package:familyapp/pages/functions/calendar/update_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:familyapp/cubit/calendarEvent_cubit/calendarEvent_bloc.dart';
import 'package:familyapp/cubit/calendarEvent_cubit/calendarEvent_state.dart';
import 'package:familyapp/model/calendarEvent_model.dart';
import 'package:familyapp/pages/functions/calendar/create_event.dart';

class CalendarScreen extends StatefulWidget {
  final String groupId;
  final String createdBy;

  const CalendarScreen({
    super.key,
    required this.groupId,
    required this.createdBy,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  RangeSelectionMode _rangeMode = RangeSelectionMode.toggledOff;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<CalendarBloc>(context).loadEvents(groupId: widget.groupId);
  }

  Future<bool> _confirmDelete(String eventTitle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete event'),
          content: Text('Are you sure you want to delete $eventTitle event?'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(dialogContext, false),
                      type: ButtonType.dialogCancel,
                    ),
                    SizedBox(width: AppSpacing.xl),
                    AppButton(
                      text: 'Delete',
                      onPressed: () => Navigator.pop(dialogContext, true),
                      type: ButtonType.dialogDelete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateEventPage(
                groupId: widget.groupId,
                createdBy: widget.createdBy,
                selectedDay: _selectedDay,
              ),
            ),
          );
          BlocProvider.of<CalendarBloc>(
            context,
          ).loadEvents(groupId: widget.groupId);
        },
      ),

      body: Column(
        children: [
          BlocBuilder<CalendarBloc, CalendarEventState>(
            builder: (context, state) {
              if (state is EventLoading) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is CalendarError) {
                return Center(child: Text(state.message));
              }

              if (state is! EventsLoaded) {
                return const SizedBox();
              }

              final events = state.events;

              return TableCalendar<CalendarEvent>(
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2030),
                focusedDay: _focusedDay,

                calendarFormat: _calendarFormat,
                rangeSelectionMode: _rangeMode,

                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

                eventLoader: (day) {
                  final normalized = DateTime(day.year, day.month, day.day);
                  return events[normalized] ?? [];
                },

                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },

                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });

                  BlocProvider.of<CalendarBloc>(context).selectDay(
                    selectedDay: selectedDay,
                    focusedDay: focusedDay,
                    events: events,
                  );
                },
              );
            },
          ),

          const SizedBox(height: 8),

          Expanded(
            child: BlocBuilder<CalendarBloc, CalendarEventState>(
              builder: (context, state) {
                if (state is EventLoading) {
                  return const SizedBox();
                }

                if (state is CalendarError) {
                  return Center(child: Text(state.message));
                }

                if (state is! EventsLoaded) {
                  return const SizedBox();
                }

                final selected = state.selectedEvents;

                if (selected.isEmpty) {
                  return const Center(child: Text("No events here"));
                }

                return ListView.builder(
                  itemCount: selected.length,
                  itemBuilder: (context, index) {
                    final event = selected[index];

                    return Dismissible(
                      key: ValueKey(event.id),
                      direction: DismissDirection.endToStart,
                      background: Container(color: AppColors.alert),
                      confirmDismiss: (_) async {
                        return await _confirmDelete(event.title);
                      },
                      onDismissed: (_) {
                        BlocProvider.of<CalendarBloc>(context).deleteEvent(
                          groupId: widget.groupId,
                          eventId: event.id,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${event.title} Event deleted!'),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(event.title),
                        subtitle: Text(event.description),
                        trailing: IconButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UpdateEventPage(
                                  groupId: widget.groupId,
                                  event: event,
                                ),
                              ),
                            );

                            BlocProvider.of<CalendarBloc>(
                              context,
                            ).loadEvents(groupId: widget.groupId);
                          },
                          icon: const Icon(Icons.edit_calendar),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
