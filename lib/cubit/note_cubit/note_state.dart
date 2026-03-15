import 'package:familyapp/model/note_model.dart';

abstract class NoteState {}

class NoteInitial extends NoteState {}

class NoteCreated extends NoteState{}

class NoteLoading extends NoteState {}

class NoteUpdated extends NoteState {}

class NoteError extends NoteState{
  final String message;
  NoteError(this.message);
}

class NotesLoaded extends NoteState{
  final List<Note> notes;
  NotesLoaded(this.notes);
}
