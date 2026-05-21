import 'package:flutter/material.dart';
//design
import 'package:familyapp/design/spacing.dart';
import 'package:familyapp/design/app_bar.dart';
import 'package:familyapp/design/colors.dart';

//cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/cubit/todo_cubit/todo_bloc.dart';
import 'package:familyapp/cubit/todo_cubit/todo_state.dart';

class TodoCreate extends StatefulWidget {
  final String groupId;
  final String createdBy;

  const TodoCreate({super.key, required this.groupId, required this.createdBy});

  @override
  State<TodoCreate> createState() => _TodoCreateState();
}

class _TodoCreateState extends State<TodoCreate> {
  final TextEditingController listTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<TodoBloc>(context).startCreateDraft();
      BlocProvider.of<TodoBloc>(context).addDraftItem();
    });
  }

  @override
  void dispose() {
    listTitleController.dispose();
    super.dispose();
  }

  void _saveTodoList() {
    BlocProvider.of<TodoBloc>(
      context,
    ).saveDraft(groupId: widget.groupId, currentUserId: widget.createdBy);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoBloc, TodoState>(
      listener: (context, state) {
        if (state is TodoSaved) {
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
          title: "NEW TODO LIST",
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
            return wholeBody(context, state);
          },
        ),
      ),
    );
  }

  Widget wholeBody(BuildContext context, TodoState state) {
    if (state is! TodoEditing) {
      return const Center(child: CircularProgressIndicator());
    }

    final isSaving = state.isSaving;

    return Column(
      children: [
        TextFormField(
          controller: listTitleController,
          onChanged: (value) {
            BlocProvider.of<TodoBloc>(context).updateDraftTitle(value);
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
                children: [
                  Checkbox(
                    value: item.isDone,
                    onChanged: isSaving
                        ? null
                        : (_) {
                            BlocProvider.of<TodoBloc>(
                              context,
                            ).updateDraftItemStatus(i: i);
                          },
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: item.title,
                      enabled: !isSaving,
                      onChanged: (value) {
                        BlocProvider.of<TodoBloc>(
                          context,
                        ).updateDraftItemTitle(i: i, newTitle: value);
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
                            BlocProvider.of<TodoBloc>(
                              context,
                            ).deleteDraftItem(i: i);
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
                      BlocProvider.of<TodoBloc>(context).addDraftItem();
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
