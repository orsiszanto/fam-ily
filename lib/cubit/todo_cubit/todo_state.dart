import 'package:familyapp/model/todoList_model.dart';
import 'package:familyapp/model/todoItem_model.dart';

abstract class TodoState {}

class TodoInitial extends TodoState {}

class TodoCreated extends TodoState {}

class TodoLoading extends TodoState {}

class TodoListsLoaded extends TodoState {
  final List<TodoList> todos;
  TodoListsLoaded(this.todos);
}

class TodoSaved extends TodoState {}

class TodoDeleted extends TodoState {}

class TodoEditing extends TodoState {
  final String title;
  final List<TodoItem> items;
  final bool isEditMode;
  final String? todoListId;
  final bool isSaving;

  TodoEditing({
    required this.title,
    required this.items,
    this.isEditMode = false,
    this.todoListId,
    this.isSaving = false,
  });

  TodoEditing copyWith({
    String? title,
    List<TodoItem>? items,
    bool? isEditMode,
    String? todoListId,
    bool? isSaving,
  }) {
    return TodoEditing(
      title: title ?? this.title,
      items: items ?? this.items,
      isEditMode: isEditMode ?? this.isEditMode,
      todoListId: todoListId ?? this.todoListId,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class TodoError extends TodoState {
  final String message;
  TodoError(this.message);
}
