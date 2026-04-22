import 'package:cloud_firestore/cloud_firestore.dart';

class TodoList {
  final String id;
  final String title;
  final String createdBy;
  final String updatedBy;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  TodoList({
    required this.id,
    required this.title,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });
}
