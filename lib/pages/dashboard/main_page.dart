import 'package:flutter/material.dart';
import 'package:familyapp/pages/functions/todo/todo_page.dart';
import 'package:familyapp/pages/functions/calendar/calendar_page.dart';
import 'package:familyapp/pages/functions/notes/notes_page.dart';
import 'package:familyapp/pages/functions/documents/documents_page.dart';
import 'package:familyapp/pages/functions/contacts/contacts_page.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(), body: wholeBody(context));
  }

  Widget wholeBody(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        _buildGridItem(context, Icons.checklist_outlined, "ToDo List"),
        _buildGridItem(context, Icons.calendar_today_outlined, "Calendar"),
        _buildGridItem(context, Icons.note_outlined, "Notes"),
        _buildGridItem(context, Icons.folder_outlined, "Documents"),
        _buildGridItem(context, Icons.contacts_outlined, "Contacts"),
        const SizedBox(),
      ],
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        switch (label) {
          case "ToDo List":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Todo()),
            );
            break;

          case "Calendar":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Calendar()),
            );
            break;

          case "Notes":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Notes()),
            );
            break;

          case "Documents":
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Documents()),
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
      automaticallyImplyLeading: false,
    );
  }
}
