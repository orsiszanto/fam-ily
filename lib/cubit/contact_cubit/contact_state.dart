import 'package:familyapp/model/contact_model.dart';

abstract class ContactState {}

class ContactInitial extends ContactState {}

class ContactCreated extends ContactState {}

class ContactLoading extends ContactState {}

class ContactUpdated extends ContactState {}

class ContactDeleted extends ContactState {}

class ContactError extends ContactState{
  final String message;
  ContactError(this.message);
}

class ContactLoaded extends ContactState{
  final List<Contact> contacts;
  ContactLoaded(this.contacts);
}