import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String createdBy;
  final Timestamp? createdAt;
  final String updatedBy;
  final Timestamp? updatedAt;

  Note({
    required this.id,
  required this.title,
  required this.content,
  required this.createdBy,
  required this.createdAt,
  required this.updatedBy,
  required this.updatedAt,});
}