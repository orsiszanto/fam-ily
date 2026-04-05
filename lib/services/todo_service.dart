import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familyapp/model/todoList_model.dart';
import 'package:familyapp/model/todoItem_model.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _todoListsRef(String groupId) {
    return _firestore.collection('group').doc(groupId).collection('todoLists');
  }

  CollectionReference<Map<String, dynamic>> _todoItemsRef(
    String groupId,
    String todoListId,
  ) {
    return _todoListsRef(groupId).doc(todoListId).collection('todoItems');
  }

  Future<void> createTodoListWithItems({
    required String groupId,
    required String title,
    required String createdBy,
    required List<TodoItem> items,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw Exception("You must name the todo list");
    }

    final cleanedItems = items
        .map(
          (item) => TodoItem(
            id: item.id,
            title: item.title.trim(),
            isDone: item.isDone,
          ),
        )
        .where((item) => item.title.isNotEmpty)
        .toList();

    final todoListDoc = _todoListsRef(groupId).doc();
    final batch = _firestore.batch();

    batch.set(todoListDoc, {
      'title': trimmedTitle,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': createdBy,
    });

    for (final item in cleanedItems) {
      final itemDoc = todoListDoc.collection('todoItems').doc();
      batch.set(itemDoc, {'title': item.title, 'isDone': item.isDone});
    }

    await batch.commit();
  }

  Future<List<TodoList>> getTodoLists({required String groupId}) async {
    final snapshot = await _todoListsRef(
      groupId,
    ).orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return TodoList(
        id: doc.id,
        title: data['title'] ?? '',
        createdBy: data['createdBy'] ?? '',
        createdAt: data['createdAt'],
        updatedBy: data['updatedBy'] ?? '',
        updatedAt: data['updatedAt'],
      );
    }).toList();
  }

  Future<TodoList> getTodoListById({
    required String groupId,
    required String todoListId,
  }) async {
    final doc = await _todoListsRef(groupId).doc(todoListId).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception("Todo list not found");
    }

    final data = doc.data()!;

    return TodoList(
      id: doc.id,
      title: data['title'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'],
      updatedBy: data['updatedBy'] ?? '',
      updatedAt: data['updatedAt'],
    );
  }

  Future<List<TodoItem>> getTodoItems({
    required String groupId,
    required String todoListId,
  }) async {
    final snapshot = await _todoItemsRef(groupId, todoListId).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TodoItem(
        id: doc.id,
        title: data['title'] ?? '',
        isDone: data['isDone'] ?? false,
      );
    }).toList();
  }

  Future<void> updateTodoListWithItems({
    required String groupId,
    required String todoListId,
    required String title,
    required String updatedBy,
    required List<TodoItem> items,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw Exception("You must name the todo list");
    }

    final cleanedItems = items
        .map(
          (item) => TodoItem(
            id: item.id,
            title: item.title.trim(),
            isDone: item.isDone,
          ),
        )
        .where((item) => item.title.isNotEmpty)
        .toList();

    final todoListDoc = _todoListsRef(groupId).doc(todoListId);
    final existingItemsSnapshot = await _todoItemsRef(
      groupId,
      todoListId,
    ).get();

    final batch = _firestore.batch();

    batch.update(todoListDoc, {
      'title': trimmedTitle,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': updatedBy,
    });

    final existingIds = existingItemsSnapshot.docs.map((doc) => doc.id).toSet();
    final incomingIds = cleanedItems
        .where((item) => item.id != null)
        .map((item) => item.id!)
        .toSet();

    for (final existingDoc in existingItemsSnapshot.docs) {
      if (!incomingIds.contains(existingDoc.id)) {
        batch.delete(existingDoc.reference);
      }
    }

    for (final item in cleanedItems) {
      if (item.id == null) {
        final newDoc = todoListDoc.collection('todoItems').doc();
        batch.set(newDoc, {'title': item.title, 'isDone': item.isDone});
      } else if (existingIds.contains(item.id)) {
        final itemDoc = todoListDoc.collection('todoItems').doc(item.id);
        batch.update(itemDoc, {'title': item.title, 'isDone': item.isDone});
      }
    }

    await batch.commit();
  }

  Future<void> deleteTodoList({
    required String groupId,
    required String todoListId,
  }) async {
    final todoListDoc = _todoListsRef(groupId).doc(todoListId);
    final todoItemsSnapshot = await todoListDoc.collection('todoItems').get();

    final batch = _firestore.batch();

    for (final doc in todoItemsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(todoListDoc);

    await batch.commit();
  }
}
