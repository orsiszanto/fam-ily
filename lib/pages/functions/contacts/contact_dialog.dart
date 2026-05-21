import 'package:flutter/material.dart';
//design
import 'package:familyapp/design/app_button.dart';
import 'package:familyapp/design/spacing.dart';

//cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/cubit/contact_cubit/contact_bloc.dart';
import 'package:familyapp/cubit/contact_cubit/contact_state.dart';

//Contact model
import 'package:familyapp/model/contact_model.dart';

class ContactDialog extends StatefulWidget {
  final String groupId;
  final Contact? contact;

  const ContactDialog({required this.groupId, this.contact, super.key});

  bool get isEdit => contact != null;

  @override
  State<ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<ContactDialog> {
  late final TextEditingController nameController;
  late final TextEditingController phoneNumberController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.contact?.name ?? '');
    phoneNumberController = TextEditingController(
      text: widget.contact?.phoneNumber ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void _saveContact() {
    final name = nameController.text.trim();
    final phoneNumber = phoneNumberController.text.trim();

    if (widget.isEdit) {
      context.read<ContactBloc>().updateContact(
        groupId: widget.groupId,
        contactId: widget.contact!.id,
        name: name,
        phoneNumber: phoneNumber,
      );
    } else {
      context.read<ContactBloc>().createContact(
        groupId: widget.groupId,
        name: name,
        phoneNumber: phoneNumber,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactBloc, ContactState>(
      listener: (context, state) {
        if (state is ContactCreated || state is ContactUpdated) {
          Navigator.pop(context);
        } else if (state is ContactError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<ContactBloc, ContactState>(
        builder: (context, state) {
          final isLoading = state is ContactLoading;

          return AlertDialog(
            title: Text(widget.isEdit ? 'Edit Contact' : 'New Contact'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(hintText: 'Name'),
                ),
                const SizedBox(height: AppSpacing.m),
                TextField(
                  controller: phoneNumberController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Phone number'),
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
                        onPressed: _saveContact,
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
