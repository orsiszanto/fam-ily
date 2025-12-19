import 'package:flutter/material.dart';
import 'package:familyapp/pages/functions/contacts/new_contact_page.dart';


class Contacts extends StatelessWidget {
  const Contacts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(), body: wholeBody(context));
  }

  Widget wholeBody(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        _buildGrindItem(context, Icons.checklist_outlined, "New Contact"),
        _buildGrindItem(context, Icons.contacts_outlined, "Contacts"),
        const SizedBox(),
      ],
    );
  }

  Widget _buildGrindItem(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case "New Contact":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewContact()),
            );
            break;
          case "Contacts":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Contacts()),
            );
            break;
          
          default:
          break;
        }
      },
      child: Card(
        margin: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.lightGreen),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.lightGreen,
      title: const Text('FAM-ILY'),
    );
  }
}
