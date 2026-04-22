import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/cubit/note_cubit/note_state.dart';
import 'package:familyapp/services/note_service.dart';

class NoteBloc extends Cubit<NoteState> {
  final NoteService _noteService;

  NoteBloc(this._noteService) : super(NoteInitial());

  void createNote({
    required String groupId,
    required String title,
    required String createdBy,
    String content = "",
  }) {
    emit(NoteLoading());
    _noteService
        .createNote(
          groupId: groupId,
          title: title,
          createdBy: createdBy,
          content: content,
        )
        .then((_) {
          emit(NoteCreated());
        })
        .catchError((error) {
          emit(NoteError(error.toString()));
        });
  }

  void updateNote({
    required String groupId,
    required String noteId,
    required String title,
    required String content,
    required String updatedBy,
  }) {
    emit(NoteLoading());

    _noteService
        .updateNote(
          groupId: groupId,
          noteId: noteId,
          title: title,
          content: content,
          updatedBy: updatedBy,
        )
        .then((_) {
          emit(NoteUpdated());
        })
        .catchError((error) {
          emit(NoteError(error.toString()));
        });
  }

  void loadNotes({required String groupId}) {
    emit(NoteLoading());

    _noteService
        .getNotes(groupId: groupId)
        .then((notes) {
          emit(NotesLoaded(notes));
        })
        .catchError((error) {
          emit(NoteError(error.toString()));
        });
  }

  void deleteNote({required String groupId, required String noteId}) {
    emit(NoteLoading());
    _noteService
        .deleteNote(groupId: groupId, noteId: noteId)
        .then((_) {
          emit(NoteDeleted());
          loadNotes(groupId: groupId);
        })
        .catchError((error) {
          emit(NoteError(error.toString()));
        });
  }
}
