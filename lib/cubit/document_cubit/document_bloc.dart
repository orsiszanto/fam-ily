import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/cubit/document_cubit/document_state.dart';
import 'package:familyapp/services/document_service.dart';

class DocumentBloc extends Cubit<DocumentState> {
  final DocumentService _documentService;

  DocumentBloc(this._documentService) : super(DocumentInitial());

  void uploadDocument({
    required String groupId,
    required String uploadedBy,
    required File file,
  }) {
    emit(DocumentLoading());
    _documentService
        .uploadDocument(file: file, groupId: groupId, uploadedBy: uploadedBy)
        .then((_) {
          emit(DocumentUploaded());
          loadDocuments(groupId: groupId);
        })
        .catchError((error) {
          emit(DocumentError(error.toString()));
        });
  }

  void loadDocuments({required String groupId}) {
    emit(DocumentLoading());
    _documentService
        .getDocuments(groupId)
        .then((documents) {
          emit(DocumentLoaded(documents));
        })
        .catchError((error) {
          emit(DocumentError(error.toString()));
        });
  }

  void deleteDocument({
    required String groupId,
    required String documentId,
    required String fileName,
  }) {
    emit(DocumentLoading());
    _documentService
        .deleteDocument(
          groupId: groupId,
          documentId: documentId,
          fileName: fileName,
        )
        .then((_) {
          emit(DocumentDeleted());
          loadDocuments(groupId: groupId);
        })
        .catchError((error) {
          emit(DocumentError(error.toString()));
        });
  }
}
