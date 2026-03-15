import 'package:familyapp/cubit/note_cubit/note_bloc.dart';
import 'package:familyapp/cubit/note_cubit/note_state.dart';
import 'package:familyapp/design/colors.dart';
import 'package:familyapp/design/spacing.dart';
import 'package:flutter/material.dart';
import 'package:familyapp/design/app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class NoteCreate extends StatefulWidget {
  final String groupId;
  final String createdBy;

  const NoteCreate({
    super.key,
  required this.groupId,
  required this.createdBy
  });

  @override
  State<NoteCreate> createState() => _NoteCreateState();
}

class _NoteCreateState extends State<NoteCreate> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void dispose(){
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    context.read<NoteBloc>().createNote(
      groupId: widget.groupId,
      title: title,
      createdBy: widget.createdBy,
      content: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NoteBloc, NoteState>(
      listener: (context, state) {
        if (state is NoteCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Note saved")),
          );
          Navigator.pop(context);
        }else if (state is NoteError){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
    child: Scaffold(
      appBar: AppBarStyles.functionsNewEdit(
        title: 'NEW NOTE',
        onBack: () => Navigator.pop(context),
      actions: [
        IconButton(
            onPressed: _saveNote,
            icon: const Icon(Icons.save_as_outlined, color: AppColors.textPrimary,)
        ),
      ],
      ),
      body: wholeBody(context),),
    );
  }

  Widget wholeBody (BuildContext context){
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          enabled: !isLoading,
        ),
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
        if(isLoading)
          const Padding(
          padding: EdgeInsets.only(top: AppSpacing.m),
          child: CircularProgressIndicator(),
          ),
      ],
    );
  }

}


