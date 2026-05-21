import 'package:flutter/material.dart';

//design
import 'package:familyapp/design/app_searchBar.dart';
import 'package:familyapp/design/app_bar.dart';
import 'package:familyapp/design/app_button.dart';
import 'package:familyapp/design/colors.dart';
import 'package:familyapp/design/spacing.dart';
import 'package:familyapp/design/app_card.dart';

//firebase
import 'package:firebase_auth/firebase_auth.dart';

//cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/cubit/todo_cubit/todo_state.dart';
import 'package:familyapp/cubit/todo_cubit/todo_bloc.dart';

//Todos pages
import 'package:familyapp/pages/functions/todo/todo_viewedit.dart';
import 'package:familyapp/pages/functions/todo/todo_create.dart';

class Todo extends StatefulWidget {
  final String createdBy;
  final String updatedBy;
  final String groupId;

  const Todo({
    required this.createdBy,
    required this.updatedBy,
    required this.groupId,
    super.key,
  });

  @override
  State<Todo> createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  final titleController = TextEditingController();
  String searchQuery = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<TodoBloc>(context).loadTodoLists(groupId: widget.groupId);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDelete(String todoListTitle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Todo list'),
          content: Text(
            'Are you sure you want to delete $todoListTitle todo list?',
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(dialogContext, false),
                      type: ButtonType.dialogCancel,
                    ),
                    SizedBox(width: AppSpacing.xl),
                    AppButton(
                      text: 'Delete',
                      onPressed: () => Navigator.pop(dialogContext, true),
                      type: ButtonType.dialogDelete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarStyles.functions(
        title: 'TODOS',
        onBack: () => Navigator.pop(context),
      ),
      body: wholeBody(context),
    );
  }

  Widget wholeBody(BuildContext context) {
    return BlocListener<TodoBloc, TodoState>(
      listener: (context, state) async {
        if (state is TodoDeleted) {
          BlocProvider.of<TodoBloc>(
            context,
          ).loadTodoLists(groupId: widget.groupId);
        } else if (state is TodoError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Column(
        children: [
          searchBar(),
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodoLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TodoListsLoaded) {
                  final filteredTodos = state.todos.where((todo) {
                    return todo.title.toLowerCase().contains(searchQuery);
                  }).toList();

                  if (filteredTodos.isEmpty) {
                    return Center(
                      child: Text(
                        searchQuery.isEmpty
                            ? 'No todo lists'
                            : 'No matching todo lists',
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                    ),
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todoList = filteredTodos[index];

                      return Dismissible(
                        key: ValueKey(todoList.id),
                        direction: DismissDirection.endToStart,
                        background: Container(color: AppColors.alert),
                        confirmDismiss: (_) async {
                          return await _confirmDelete(todoList.title);
                        },
                        onDismissed: (_) {
                          BlocProvider.of<TodoBloc>(context).deleteTodoList(
                            groupId: widget.groupId,
                            todoListId: todoList.id,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${todoList.title} todo list deleted!',
                              ),
                            ),
                          );
                        },
                        child: AppCardStyles.todoList(
                          title: todoList.title,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TodoViewEdit(
                                  todoList: todoList,
                                  groupId: widget.groupId,
                                  updatedBy: widget.createdBy,
                                ),
                              ),
                            ).then((_) {
                              if (mounted) {
                                BlocProvider.of<TodoBloc>(
                                  context,
                                ).loadTodoLists(groupId: widget.groupId);
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: FloatingActionButton(
              onPressed: () {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User or group not found')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TodoCreate(
                      groupId: widget.groupId,
                      createdBy: widget.createdBy,
                    ),
                  ),
                ).then((_) {
                  if (mounted) {
                    BlocProvider.of<TodoBloc>(
                      context,
                    ).loadTodoLists(groupId: widget.groupId);
                  }
                });
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s),
      child: AppSearchbar(
        hintText: 'Search...',
        controller: titleController,
        type: SearchbarType.secondary,
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }
}
