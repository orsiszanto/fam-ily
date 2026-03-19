import 'package:familyapp/cubit/contact_cubit/contact_bloc.dart';
import 'package:familyapp/cubit/contact_cubit/contact_state.dart';
import 'package:familyapp/cubit/user_cubit/user_bloc.dart';
import 'package:familyapp/design/app_bar.dart';
import 'package:familyapp/design/app_button.dart';
import 'package:familyapp/design/app_card.dart';
import 'package:familyapp/design/app_searchBar.dart';
import 'package:familyapp/design/colors.dart';
import 'package:familyapp/design/spacing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/pages/functions/contacts/contact_dialog.dart';

class Contacts extends StatefulWidget {
  final String groupId;

  const Contacts({
    required this.groupId,
    super.key,
});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  String searchQuery = "";
  late ContactBloc _contactBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _contactBloc = context.read<ContactBloc>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contactBloc.loadContacts(groupId: widget.groupId);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDelete(String contactName)async{
    final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext){
          return AlertDialog(
            title: const Text('Delete contact'),
            content: Text('Are you sure you want to delete $contactName contact?'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
                child:
                Row(
                  children: [
                    AppButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(dialogContext, false),
                      type: ButtonType.dialogCancel,
                    ),
                    const SizedBox(width: AppSpacing.xl,),
                    AppButton(
                      text: 'Delete',
                      onPressed: () => Navigator.pop(dialogContext, true),
                      type: ButtonType.dialogDelete,
                    ),
                  ],
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
        title: 'CONTACTS',
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
          child: BlocBuilder<ContactBloc, ContactState>(
            builder: (context, state) {
              if (state is ContactLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ContactLoaded) {
                final filteredContacts = state.contacts.where((contact) {
                  return contact.name.toLowerCase().contains(searchQuery);
                }).toList();

                if (filteredContacts.isEmpty) {
                  return Center(
                      child: Text(
                          searchQuery.isEmpty ? 'No contacts' : 'No matching contacts',
                      )
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];

                    return Dismissible(
                      key: ValueKey(contact.id),
                      direction:  DismissDirection.endToStart,
                      background: Container(color: AppColors.alert),
                      confirmDismiss: (_) async{
                          return await _confirmDelete(contact.name);
                      },
                      onDismissed: (_){
                          _contactBloc.deleteContact(
                              groupId: widget.groupId,
                              contactId: contact.id,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${contact.name} contact deleted!'),
                            )
                          );
                      },
                      child: AppCardStyles.contactList(
                        name: contact.name,
                        onTap: () async{
                          await showDialog(
                              context: context,
                              builder: (_) => BlocProvider.value(
                                  value: _contactBloc,
                              child: ContactDialog(
                                  groupId: widget.groupId,
                              contact: contact,
                              ),
                              ),
                          );
                          if(!mounted) return;
                          _contactBloc.loadContacts(groupId: widget.groupId);
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
            onPressed: () async{
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (currentGroup == null || uid == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User or group not found')),
                );
                return;
              }
              await showDialog(
                  context: context,
                  builder: (_) => BlocProvider.value(
                      value: _contactBloc,
                  child: ContactDialog(
                      groupId: widget.groupId,
                    ),
                  ),
              );
              if(!mounted) return;
              _contactBloc.loadContacts(groupId: widget.groupId);
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
        controller: nameController,
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
