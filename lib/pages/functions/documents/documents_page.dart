import 'package:familyapp/cubit/document_cubit/document_bloc.dart';
import 'package:familyapp/cubit/document_cubit/document_state.dart';
import 'package:familyapp/design/app_bar.dart';
import 'package:familyapp/design/app_button.dart';
import 'package:familyapp/design/app_card.dart';
import 'package:familyapp/design/app_searchBar.dart';
import 'package:familyapp/design/colors.dart';
import 'package:familyapp/design/spacing.dart';
import 'package:familyapp/pages/functions/documents/document_dialog.dart';
import 'package:familyapp/services/document_service.dart';
import 'package:familyapp/services/userSubscription_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Documents extends StatefulWidget {
  final String groupId;
  final String fileName;
  final DocumentService documentService;
  const Documents({
    required this.groupId,
    required this.fileName,
    required this.documentService,
    super.key,
  });

  @override
  State<Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  String searchQuery = "";
  final fileNameController = TextEditingController();
  late DocumentBloc _documentBloc;

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    const suffixes = ['KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int suffixIndex = -1;

    do {
      size /= 1024;
      suffixIndex++;
    } while (size >= 1024 && suffixIndex < suffixes.length - 1);

    return '${size.toStringAsFixed(size >= 10 ? 0 : 1)} ${suffixes[suffixIndex]}';
  }

  String _formatFileType(String fileType) {
    final normalized = fileType.trim();
    if (normalized.isEmpty) {
      return 'Unknown type';
    }

    return normalized.toUpperCase();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _documentBloc = context.read<DocumentBloc>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _documentBloc.loadDocuments(groupId: widget.groupId);
    });
  }

  @override
  void dispose() {
    fileNameController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDelete(String fileName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete document'),
          content: Text('Are you sure you want to delete $fileName document?'),
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
                    const SizedBox(width: AppSpacing.l),
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
        title: "DOCUMENTS",
        onBack: () => Navigator.pop(context),
      ),
      body: wholeBody(context),
    );
  }

  Widget wholeBody(BuildContext context) {
    return Column(
      children: [
        searchBar(),
        Expanded(
          child: BlocBuilder<DocumentBloc, DocumentState>(
            builder: (context, state) {
              if (state is DocumentLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DocumentLoaded) {
                final filteredContacts = state.documents.where((contact) {
                  return contact.fileName.toLowerCase().contains(searchQuery);
                }).toList();

                if (filteredContacts.isEmpty) {
                  return Center(
                    child: Text(
                      searchQuery.isEmpty
                          ? 'No documents'
                          : 'No matching documents',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final document = filteredContacts[index];

                    return Dismissible(
                      key: ValueKey(document.id),
                      direction: DismissDirection.endToStart,
                      background: Container(color: AppColors.alert),
                      confirmDismiss: (_) async {
                        return await _confirmDelete(document.fileName);
                      },
                      onDismissed: (_) {
                        _documentBloc.deleteDocument(
                          groupId: widget.groupId,
                          documentId: document.id,
                          fileName: document.fileName,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${document.fileName} document deleted!',
                            ),
                          ),
                        );
                      },
                      child: AppCardStyles.documentList(
                        title: document.fileName,
                        subtitle: Text(
                          '${_formatFileSize(document.fileSize)} • ${_formatFileType(document.fileType)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                        ),
                        onTap: () async {
                          final shouldDownload = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text('Download document'),
                                content: Text(
                                  'Do you want to download ${document.fileName} on your device?',
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
                                            onPressed: () => Navigator.pop(
                                              dialogContext,
                                              false,
                                            ),
                                            type: ButtonType.dialogCancel,
                                          ),
                                          const SizedBox(width: AppSpacing.l),
                                          AppButton(
                                            text: 'Download',
                                            onPressed: () => Navigator.pop(
                                              dialogContext,
                                              true,
                                            ),
                                            type: ButtonType.dialogSave,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (shouldDownload != true) return;

                          try {
                            final downloadPath = await widget.documentService
                                .downloadDocument(
                                  groupId: widget.groupId,
                                  fileName: document.fileName,
                                );

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('File saved to: $downloadPath'),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Download failed: $e'),
                                backgroundColor: AppColors.alert,
                              ),
                            );
                          }

                          if (!mounted) return;
                          _documentBloc.loadDocuments(groupId: widget.groupId);
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
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (UserSubscriptionService.currentGroupId == null ||
                  uid == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User or group not found')),
                );
                return;
              }
              await showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: _documentBloc,
                  child: DocumentDialog(groupId: widget.groupId),
                ),
              );
              if (!mounted) return;
              _documentBloc.loadDocuments(groupId: widget.groupId);
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s),
      child: AppSearchbar(
        hintText: 'Search...',
        controller: fileNameController,
        type: SearchbarType.secondary,
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.lightGreen,
      title: const Text('Documents'),
    );
  }
}
