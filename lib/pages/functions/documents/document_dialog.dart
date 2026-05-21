import 'dart:io';

import 'package:familyapp/design/app_button.dart';
import 'package:familyapp/design/spacing.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/cubit/document_cubit/document_state.dart';
import 'package:familyapp/cubit/document_cubit/document_bloc.dart';

import 'package:familyapp/model/document_model.dart';

class DocumentDialog extends StatefulWidget {
  final String groupId;
  final Document? document;

  const DocumentDialog({required this.groupId, this.document, super.key});

  @override
  State<DocumentDialog> createState() => _DocumentDialogState();
}

class _DocumentDialogState extends State<DocumentDialog> {
  File? file;
  late final TextEditingController fileNameController;

  String get _documentButtonLabel {
    if (file == null) {
      return 'Select document';
    }

    final segments = file!.path.split(RegExp(r'[\\/]'));
    return segments.isNotEmpty ? segments.last : 'Select document';
  }

  @override
  void initState() {
    fileNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    fileNameController.dispose();
    super.dispose();
  }

  void _uploadDocument() {
    if (file == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No file selected')));
      return;
    }
    BlocProvider.of<DocumentBloc>(context).uploadDocument(
      groupId: widget.groupId,
      uploadedBy: FirebaseAuth.instance.currentUser!.uid,
      file: file!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentBloc, DocumentState>(
      listener: (context, state) {
        if (state is DocumentUploaded) {
          Navigator.pop(context);
        } else if (state is DocumentError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          final isLoading = state is DocumentLoading;

          return AlertDialog(
            title: Text('Upload document'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var picked = await FilePicker.pickFiles();

                    if (picked != null && picked.files.first.path != null) {
                      setState(() {
                        file = File(picked.files.first.path!);
                      });
                    }
                  },
                  child: Text(
                    _documentButtonLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.xs,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        isLoading: isLoading,
                        type: ButtonType.dialogCancel,
                      ),
                      const SizedBox(width: AppSpacing.l),
                      AppButton(
                        text: 'Save',
                        onPressed: _uploadDocument,
                        isLoading: isLoading,
                        type: ButtonType.dialogSave,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
