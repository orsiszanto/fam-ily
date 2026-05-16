import 'package:familyapp/model/document_model.dart';

abstract class DocumentState {}

class DocumentInitial extends DocumentState {}

class DocumentUploaded extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentDeleted extends DocumentState {}

class DocumentDownloaded extends DocumentState {}

class DocumentError extends DocumentState {
  final String message;
  DocumentError(this.message);
}

class DocumentLoaded extends DocumentState {
  final List<Document> documents;
  DocumentLoaded(this.documents);
}
