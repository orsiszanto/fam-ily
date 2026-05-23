import 'package:familyapp/model/calendarEvent_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/design/app_button.dart';
import 'package:familyapp/design/spacing.dart';
import 'package:familyapp/cubit/calendarEvent_cubit/calendarEvent_bloc.dart';

class UpdateEventPage extends StatefulWidget {
  final String groupId;
  final DateTime? selectedDay;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final CalendarEvent event;

  const UpdateEventPage({
    super.key,
    required this.groupId,
    required this.event,
    this.selectedDay,
    this.rangeStart,
    this.rangeEnd,
  });

  @override
  State<UpdateEventPage> createState() => _UpdateEventPageState();
}

class _UpdateEventPageState extends State<UpdateEventPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();

    startDate = widget.event.startDate;
    endDate = widget.event.endDate;

    titleController.text = widget.event.title;
    descriptionController.text = widget.event.description;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
        if (endDate.isBefore(startDate)) {
          endDate = startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  void _save() {
    BlocProvider.of<CalendarBloc>(context).updateEvent(
      groupId: widget.groupId,
      eventId: widget.event.id,
      title: titleController.text,
      description: descriptionController.text,
      startDate: startDate,
      endDate: endDate,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Event")),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: AppSpacing.m),
            ListTile(
              title: const Text("Start date"),
              subtitle: Text(startDate.toString()),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickStartDate,
            ),

            ListTile(
              title: const Text("End date"),
              subtitle: Text(endDate.toString()),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickEndDate,
            ),

            const SizedBox(height: AppSpacing.m),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: "Title"),
            ),

            const SizedBox(height: AppSpacing.m),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: "Description"),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: "Cancel",
                    type: ButtonType.dialogCancel,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: AppButton(
                    text: "Save",
                    type: ButtonType.dialogSave,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
