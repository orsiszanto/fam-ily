import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/cubit/contact_cubit/contact_state.dart';
import 'package:familyapp/services/contact_service.dart';

class ContactBloc extends Cubit<ContactState> {
  final ContactService _contactService;

  ContactBloc(this._contactService) : super(ContactInitial());

  void createContact({
    required String groupId,
    required String name,
    required String phoneNumber,
  }) {
    emit(ContactLoading());
    _contactService
        .createContact(groupId: groupId, name: name, phoneNumber: phoneNumber)
        .then((_) {
          emit(ContactCreated());
        })
        .catchError((error) {
          emit(ContactError(error.toString()));
        });
  }

  void updateContact({
    required String groupId,
    required String contactId,
    required String name,
    required String phoneNumber,
  }) {
    emit(ContactLoading());
    _contactService
        .updateContact(
          groupId: groupId,
          contactId: contactId,
          name: name,
          phoneNumber: phoneNumber,
        )
        .then((_) {
          emit(ContactUpdated());
        })
        .catchError((error) {
          emit(ContactError(error.toString()));
        });
  }

  void loadContacts({required String groupId}) {
    emit(ContactLoading());
    _contactService
        .getContacts(groupId: groupId)
        .then((contacts) {
          emit(ContactLoaded(contacts));
        })
        .catchError((error) {
          emit(ContactError(error.toString()));
        });
  }

  void deleteContact({required String groupId, required String contactId}) {
    emit(ContactLoading());
    _contactService
        .deleteContact(groupId: groupId, contactId: contactId)
        .then((_) {
          emit(ContactDeleted());
          loadContacts(groupId: groupId);
        })
        .catchError((error) {
          emit(ContactError(error.toString()));
        });
  }
}
