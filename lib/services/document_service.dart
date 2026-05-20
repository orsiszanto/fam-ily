import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familyapp/model/document_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class DocumentService {
  static const MethodChannel _downloadsChannel = MethodChannel(
    'familyapp/downloads',
  );

  Future<void> uploadDocument({
    required File file,
    required String groupId,
    required String uploadedBy,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final fileSize = await file.length();
      final fileType = fileName.split('.').last.toLowerCase();

      final storageRef = FirebaseStorage.instance.ref().child(
        'group/$groupId/documents/$fileName',
      );

      final uploadTask = storageRef.putFile(file);

      final snapshot = await uploadTask;

      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('group')
          .doc(groupId)
          .collection('documents')
          .add({
            'fileName': fileName,
            'uploadedBy': uploadedBy,
            'uploadedAt': FieldValue.serverTimestamp(),
            'fileSize': fileSize,
            'fileType': fileType,
            'downloadUrl': downloadUrl,
          });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Document>> getDocuments(String groupId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('group')
          .doc(groupId)
          .collection('documents')
          .orderBy('uploadedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();

        return Document(
          id: doc.id,
          fileName: data['fileName'] ?? '',
          uploadedBy: data['uploadedBy'] ?? '',
          uploadedAt: data['uploadedAt'] ?? '',
          fileSize: data['fileSize'] ?? 0,
          fileType: data['fileType'] ?? '',
          downloadUrl: data['downloadUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error getting documents: $e');
      rethrow;
    }
  }

  Future<String> downloadDocument({
    required String groupId,
    required String fileName,
  }) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/$fileName');

      final storageRef = FirebaseStorage.instance.ref().child(
        'group/$groupId/documents/$fileName',
      );

      await storageRef.writeToFile(tempFile);

      final String savedPath =
          await _downloadsChannel.invokeMethod<String>('saveToDownloads', {
            'sourcePath': tempFile.path,
            'fileName': fileName,
          }) ??
          tempFile.path;

      try {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}

      return savedPath;
    } catch (e) {
      throw Exception('Failed to download document: $e');
    }
  }

  Future<void> deleteDocument({
    required String groupId,
    required String documentId,
    required String fileName,
  }) async {
    try {
      await FirebaseStorage.instance
          .ref()
          .child('group/$groupId/documents/$fileName')
          .delete();

      await FirebaseFirestore.instance
          .collection('group')
          .doc(groupId)
          .collection('documents')
          .doc(documentId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }
}
