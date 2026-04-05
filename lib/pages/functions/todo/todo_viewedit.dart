import 'package:flutter/material.dart';
//design
import 'package:familyapp/design/colors.dart';
import 'package:familyapp/design/spacing.dart';
import 'package:familyapp/design/app_bar.dart';

//cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/cubit/todo_cubit/todo_bloc.dart';
import 'package:familyapp/cubit/todo_cubit/todo_state.dart';

//todos modell
import 'package:familyapp/model/todoList_model.dart';


class TodoViewEdit extends StatefulWidget {
  final TodoList todoList;
  final String groupId;
  final String updatedBy;

  const TodoViewEdit({
    super.key,
    required this.todoList,
    required this.groupId,
    required this.updatedBy,
  });

  @override
  State<TodoViewEdit> createState() => _TodoViewEditState();
}

class _TodoViewEditState extends State<TodoViewEdit> {
  late final TextEditingController listTitleController;

  @override
  void initState(){
    super.initState();
    listTitleController = TextEditingController(text: widget.todoList.title);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final todoBloc = context.read<TodoBloc>();
      todoBloc.startEditDraft(
        groupId: widget.groupId,
        todoListId: widget.todoList.id,
      );
    });
  }

  @override
  void dispose(){
    listTitleController.dispose();
    super.dispose();
  }

  void _saveTodoList() {
    context.read<TodoBloc>().saveDraft(
      groupId: widget.groupId,
      currentUserId: widget.updatedBy,
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoBloc, TodoState>(
        listener: (context, state){
          if (state is TodoSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Todo list saved")),
            );
            Navigator.pop(context);
          } else if (state is TodoError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is TodoEditing) {
            if (listTitleController.text != state.title) {
              listTitleController.value = listTitleController.value.copyWith(
                text: state.title,
                selection: TextSelection.collapsed(offset: state.title.length),
              );
            }
          }
        },
      child: Scaffold(
        appBar: AppBarStyles.functionsNewEdit(
          title: "EDIT TODO LIST",
          onBack: () => Navigator.pop(context),
          actions: [
            IconButton(
              onPressed: _saveTodoList,
              icon: const Icon(
                Icons.save_as_outlined,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        body: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            if( state is TodoLoading || state is TodoInitial){
              return const Center(child: CircularProgressIndicator());
            }

            if(state is TodoError){
              return Center(
                child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Something went wrong",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    ElevatedButton(
                        onPressed: (){
                          context.read<TodoBloc>().startEditDraft(
                              groupId: widget.groupId,
                              todoListId: widget.todoList.id,
                          );
                        },
                        child: const Text("Retry"),
                    ),
                  ],
                ),
                ),
              );
            }

            if(state is TodoEditing){
              return wholeBody(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget wholeBody(BuildContext context, TodoEditing state){

    final isSaving = state.isSaving;

    return Column(
      children: [
        TextFormField(
          controller: listTitleController,
          onChanged: (value) {
            context.read<TodoBloc>().updateDraftTitle(value);
          },
          decoration: const InputDecoration(
            hintText: "Title",
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          enabled: !isSaving,
        ),
        Divider(),
        const SizedBox(height: AppSpacing.m),
        Expanded(
          child: ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, i) {
              final item = state.items[i];
              return Row(
                key: ValueKey(item.id ?? 'new_item_$i'),
                children: [
                  Checkbox(
                    value: item.isDone,
                    onChanged: isSaving
                        ? null
                        : (_) {
                      context.read<TodoBloc>().updateDraftItemStatus(
                        i: i,
                      );
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      key: ValueKey('field_${item.id ?? 'new_$i'}'),
                      initialValue: item.title,
                      enabled: !isSaving,
                      onChanged: (value) {
                        context.read<TodoBloc>().updateDraftItemTitle(
                          i: i,
                          newTitle: value,
                        );
                      },
                      decoration: const InputDecoration(
                        hintText: "Todo item",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: isSaving
                        ? null
                        : () {
                      context.read<TodoBloc>().deleteDraftItem(i: i);
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () {
                context.read<TodoBloc>().addDraftItem();
              },
              child: const Text("Add Item"),
            ),
          ),
        ),
        if (isSaving)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.m),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
