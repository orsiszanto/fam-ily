import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:familyapp/model/contact_model.dart';

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createContact({
    required String groupId,
    required String name,
    required String phoneNumber,
  }) async {
    final trimmedName = name.trim();
    final trimmedPhoneNumber = phoneNumber.trim();
    if (trimmedPhoneNumber.isEmpty || trimmedName.isEmpty) {
      throw Exception("You must fill both fields out!");
    }

    final contactsDoc = _firestore.collection('group').doc(groupId).collection(
        'contacts');

    await contactsDoc.add({
      'name': trimmedName,
      'phoneNumber': trimmedPhoneNumber
    });
  }

  Future <List<Contact>> getContacts({
    required String groupId,
  }) async {
    final snapshot = await _firestore
        .collection('group')
        .doc(groupId)
        .collection('contacts')
        .orderBy('name', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Contact(
          id: doc.id,
          name: data['name'] ?? '',
          phoneNumber: data['phoneNumber'] ?? ''
      );
    }).toList();
  }

  Future<void> updateContact({
    required String groupId,
    required String contactId,
    required String name,
    required String phoneNumber,
})async{
    final trimmedName = name.trim();
    final trimmedPhoneNumber = phoneNumber.trim();
    if (trimmedPhoneNumber.isEmpty || trimmedName.isEmpty) {
      throw Exception("You must fill both fields out!");
    }

    final contactDoc = _firestore.collection('group').doc(groupId).collection('contacts').doc(contactId);

    await contactDoc.update({
      'name' : trimmedName,
      'phoneNumber' : trimmedPhoneNumber,
    });
  }

  Future <void> deleteContact({
    required String groupId,
    required String contactId,
})async{
    final contactDoc = _firestore.collection('group').doc(groupId).collection('contacts').doc(contactId);
    await contactDoc.delete();
  }
}
