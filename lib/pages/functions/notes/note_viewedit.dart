import 'package:flutter/material.dart';
//design
import 'package:familyapp/design/colors.dart';
import 'package:familyapp/design/spacing.dart';
import 'package:familyapp/design/app_bar.dart';

//cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/cubit/note_cubit/note_bloc.dart';
import 'package:familyapp/cubit/note_cubit/note_state.dart';

//note model
import 'package:familyapp/model/note_model.dart';

class NoteViewEdit extends StatefulWidget {
  final Note note;
  final String groupId;
  final String updatedBy;

  const NoteViewEdit({
    super.key,
    required this.note,
    required this.groupId,
    required this.updatedBy,
  });

  @override
  State<NoteViewEdit> createState() => _NoteViewEditState();
}

class _NoteViewEditState extends State<NoteViewEdit> {
  late final TextEditingController titleController;
  late final TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    context.read<NoteBloc>().updateNote(
      groupId: widget.groupId,
      noteId: widget.note.id,
      title: title,
      content: content,
      updatedBy: widget.updatedBy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteBloc, NoteState>(
      listener: (context, state) {
        if (state is NoteUpdated) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Note saved")));
          Navigator.pop(context);
        } else if (state is NoteError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBarStyles.functionsNewEdit(
          title: 'EDIT NOTE',
          onBack: () => Navigator.pop(context),
          actions: [
            IconButton(
              onPressed: _saveNote,
              icon: const Icon(
                Icons.save_as_outlined,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        body: wholeBody(context),
      ),
    );
  }

  Widget wholeBody(BuildContext context) {
    final state = context.watch<NoteBloc>().state;
    final isLoading = state is NoteLoading;

    return Column(
      children: [
        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: "Title",
            border: InputBorder.none,
          ),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          enabled: !isLoading,
        ),
        Divider(),
        const SizedBox(height: AppSpacing.m),
        Expanded(
          child: TextField(
            controller: contentController,
            decoration: const InputDecoration(
              hintText: "Start typing your note",
              border: InputBorder.none,
            ),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.multiline,
            enabled: !isLoading,
          ),
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.m),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
