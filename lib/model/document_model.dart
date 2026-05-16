import 'package:cloud_firestore/cloud_firestore.dart';

class Document {
  final String id;
  final String fileName;
  final String uploadedBy;
  final Timestamp uploadedAt;
  final int fileSize;
  final String fileType;
  final String downloadUrl;

  Document({
    required this.id,
    required this.fileName,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.fileSize,
    required this.fileType,
    required this.downloadUrl,
  });
}
