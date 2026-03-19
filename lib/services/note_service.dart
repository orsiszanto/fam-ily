import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familyapp/model/note_model.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future <void> createNote({
    required String groupId,
    required String title,
    required String createdBy,
    String content = "",
})async{
    final trimmedTitle = title.trim();
    if(trimmedTitle.isEmpty){
      throw Exception("You must name the note");
    }

    final notesDoc = _firestore.collection('group').doc(groupId).collection('notes');

    await notesDoc.add({
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'title':trimmedTitle,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': createdBy,
    });
  }

  Future<List<Note>> getNotes({
    required String groupId,
})async{
    final snapshot = await _firestore.collection('group').doc(groupId).collection('notes').orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc){
      final data = doc.data();

      return Note(
        id: doc.id,
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        createdBy: data['createdBy'] ?? '',
        createdAt: data['createdAt'],
        updatedBy: data['updatedBy'] ?? '',
        updatedAt: data['updatedAt'],
      );
    }).toList();
  }

  Future<void> updateNote({
    required String groupId,
    required String noteId,
    required String title,
    required String content,
    required String updatedBy,
  })async{
    final trimmedTitle = title.trim();
    if(trimmedTitle.isEmpty){
      throw Exception("You must name the note");
    }

    final noteDoc = _firestore.collection('group').doc(groupId).collection('notes').doc(noteId);

    await noteDoc.update({
      'title': trimmedTitle,
      'content': content,
      'updatedBy': updatedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future <void> deleteNote({
    required String groupId,
    required String noteId,
  })async{
    final noteDoc = _firestore.collection('group').doc(groupId).collection('notes').doc(noteId);
    await noteDoc.delete();
  }
}