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
import 'package:familyapp/cubit/note_cubit/note_state.dart';
import 'package:familyapp/cubit/note_cubit/note_bloc.dart';

//notes pages
import 'package:familyapp/pages/functions/notes/note_viewedit.dart';
import 'package:familyapp/pages/functions/notes/note_create.dart';

class Notes extends StatefulWidget {
  final String createdBy;
  final String groupId;

  const Notes({required this.createdBy, required this.groupId, super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  final titleController = TextEditingController();
  String searchQuery = "";
  late NoteBloc _noteBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _noteBloc = context.read<NoteBloc>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _noteBloc.loadNotes(groupId: widget.groupId);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDelete(String noteTitle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete note'),
          content: Text('Are you sure you want to delete $noteTitle note?'),
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
        title: 'NOTES',
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
          child: BlocBuilder<NoteBloc, NoteState>(
            builder: (context, state) {
              if (state is NoteLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is NotesLoaded) {
                final filteredNotes = state.notes.where((note) {
                  return note.title.toLowerCase().contains(searchQuery);
                }).toList();

                if (filteredNotes.isEmpty) {
                  return Center(
                    child: Text(
                      searchQuery.isEmpty ? 'No notes' : 'No matching notes',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];

                    return Dismissible(
                      key: ValueKey(note.id),
                      direction: DismissDirection.endToStart,
                      background: Container(color: AppColors.alert),
                      confirmDismiss: (_) async {
                        return await _confirmDelete(note.title);
                      },
                      onDismissed: (_) {
                        _noteBloc.deleteNote(
                          groupId: widget.groupId,
                          noteId: note.id,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${note.title} note deleted!'),
                          ),
                        );
                      },
                      child: AppCardStyles.noteList(
                        title: note.title,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: _noteBloc,
                                child: NoteViewEdit(
                                  note: note,
                                  groupId: widget.groupId,
                                  updatedBy: widget.createdBy,
                                ),
                              ),
                            ),
                          ).then((_) {
                            if (mounted) {
                              _noteBloc.loadNotes(groupId: widget.groupId);
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
                  builder: (_) => BlocProvider.value(
                    value: _noteBloc,
                    child: NoteCreate(
                      groupId: widget.groupId,
                      createdBy: widget.createdBy,
                    ),
                  ),
                ),
              ).then((_) {
                if (mounted) {
                  _noteBloc.loadNotes(groupId: widget.groupId);
                }
              });
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
