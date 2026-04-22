import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familyapp/model/calendarEvent_model.dart';

class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createEvent({
    required String groupId,
    required String title,
    required String createdBy,
    required DateTime startDate,
    required DateTime endDate,
    required int notifyBeforeMinutes,
    String description = "",
    String? recurrence,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw Exception("You must name the calendar event");
    }

    if (endDate.isBefore(startDate)) {
      throw Exception("End date cannot be before start date");
    }

    final calendarEventsDoc = _firestore
        .collection('group')
        .doc(groupId)
        .collection('calendarEvents');

    await calendarEventsDoc.add({
      'title': trimmedTitle,
      'description': description,
      'createdBy': createdBy,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'recurrence': recurrence,
      'notifyBeforeMinutes': notifyBeforeMinutes,
    });
  }

  Future<List<CalendarEvent>> getEvents({required String groupId}) async {
    final snapshot = await _firestore
        .collection('group')
        .doc(groupId)
        .collection('calendarEvents')
        .orderBy('startDate', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();

      return CalendarEvent(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        createdBy: data['createdBy'] ?? '',
        startDate:
            (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        recurrence: data['recurrence'],
        notifyBeforeMinutes: (data['notifyBeforeMinutes'] as int?) ?? 0,
      );
    }).toList();
  }

  Future<void> updateEvent({
    required String groupId,
    required String eventId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String? recurrence,
    required int notifyBeforeMinutes,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw Exception("You must name the calendar event");
    }

    if (endDate.isBefore(startDate)) {
      throw Exception("End date cannot be before start date");
    }

    final eventDoc = _firestore
        .collection('group')
        .doc(groupId)
        .collection('calendarEvents')
        .doc(eventId);

    await eventDoc.update({
      'title': trimmedTitle,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'recurrence': recurrence,
      'notifyBeforeMinutes': notifyBeforeMinutes,
    });
  }

  Future<void> deleteEvent({
    required String groupId,
    required String eventId,
  }) async {
    final eventDoc = _firestore
        .collection('group')
        .doc(groupId)
        .collection('calendarEvents')
        .doc(eventId);
    await eventDoc.delete();
  }
}
