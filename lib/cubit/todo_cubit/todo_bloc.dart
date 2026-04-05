
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/cubit/todo_cubit/todo_state.dart';
import 'package:familyapp/services/todo_service.dart';
import 'package:familyapp/model/todoItem_model.dart';

class TodoBloc extends Cubit<TodoState>{
  final TodoService _todoService;

  TodoBloc(this._todoService): super (TodoInitial());

  void loadTodoLists({
    required String groupId,
  }){
    emit(TodoLoading());

    _todoService.getTodoLists(
        groupId: groupId
    ).then((todoLists){
      emit(TodoListsLoaded(todoLists));
    }).catchError((error){
      emit(TodoError(error.toString()));
    });
  }

  void startCreateDraft(){
    emit(TodoEditing(
        title: '',
        items: [],
      isEditMode: false,
    ),
    );
  }

  void startEditDraft({
    required String groupId,
    required String todoListId,
  }){
    emit(TodoLoading());
    _todoService.getTodoListById(
      groupId: groupId,
      todoListId: todoListId,
    ).then((todoList){
      _todoService.getTodoItems(
        groupId: groupId,
        todoListId: todoListId,
      ).then((items){
        emit(TodoEditing(
          title: todoList.title,
          items: items,
          isEditMode: true,
          todoListId: todoListId,
        ));
      }).catchError((error){
        emit(TodoError(error.toString()));
      });
    }).catchError((error){
      emit(TodoError(error.toString()));
    });
  }

  void addDraftItem(){
    final current = state;
    if(current is TodoEditing){
      final updatedItems = List<TodoItem>.from(current.items)..add(TodoItem(
          id: null,
          title: '',
          isDone: false),
      );
      emit(current.copyWith(items: updatedItems));
    }
  }

  void updateDraftTitle(String newTitle){
    final current = state;
    if(current is TodoEditing){
      emit(current.copyWith(title:newTitle));
    }
  }

  void updateDraftItemTitle({
    required int i,
    required String newTitle,
}){
    final current = state;
    if(current is TodoEditing){
      final updatedItems = List<TodoItem>.from(current.items);
      updatedItems[i] = TodoItem(id: updatedItems[i].id, title: newTitle, isDone: updatedItems[i].isDone);
      emit(current.copyWith(items: updatedItems));
    }
  }

  void updateDraftItemStatus({
    required int i,
    }){
    final current = state;
    if(current is TodoEditing){
      final updatedItems = List<TodoItem>.from(current.items);
      updatedItems[i] = TodoItem(
          id: updatedItems[i].id,
          title: updatedItems[i].title,
          isDone: !updatedItems[i].isDone);
      emit(current.copyWith(items: updatedItems));
    }
  }

  void deleteDraftItem({
    required int i,
}){
    final current = state;
    if(current is TodoEditing){
      final updatedItems = List<TodoItem>.from(current.items);
      updatedItems.removeAt(i);
      emit (current.copyWith(items: updatedItems));
    }
}

void saveDraft({
    required String groupId,
    required String currentUserId,
}){
    final current = state;
    if(current is! TodoEditing) return;
    emit(current.copyWith(isSaving: true));

    if(current.isEditMode && current.todoListId != null){
      _todoService.updateTodoListWithItems(
          groupId: groupId,
          todoListId: current.todoListId!,
          title: current.title,
          updatedBy: currentUserId,
          items: current.items
      ).then((_){
        emit(TodoSaved());
      }).catchError((error){
        emit(TodoError(error.toString()));
      });
    }else{
      _todoService.createTodoListWithItems(
          groupId: groupId,
          title: current.title,
          createdBy: currentUserId,
          items: current.items,
      ).then((_){
        emit(TodoSaved());
      }).catchError((error){
        emit(TodoError(error.toString()));
      });
    }

}

  void deleteTodoList({
    required String groupId,
    required String todoListId,
}){
    _todoService.deleteTodoList(
      groupId: groupId,
      todoListId: todoListId,
    ).then((_){
      emit(TodoDeleted());
    }).catchError((error){emit(TodoError(error.toString()));
    });
  }
}