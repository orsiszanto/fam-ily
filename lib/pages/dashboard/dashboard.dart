import 'package:familyapp/cubit/calendarEvent_cubit/calendarEvent_bloc.dart';
import 'package:familyapp/cubit/document_cubit/document_bloc.dart';
import 'package:familyapp/cubit/todo_cubit/todo_bloc.dart';
import 'package:familyapp/services/calendarEvent_service.dart';
import 'package:familyapp/services/document_service.dart';
import 'package:familyapp/services/todo_service.dart';

import 'package:flutter/material.dart';
//design
import 'package:familyapp/design/app_bar.dart';

//firebase
import 'package:firebase_auth/firebase_auth.dart';

//cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:familyapp/cubit/user_cubit/user_bloc.dart';
import 'package:familyapp/cubit/contact_cubit/contact_bloc.dart';
import 'package:familyapp/cubit/note_cubit/note_bloc.dart';
import 'package:familyapp/cubit/user_cubit/user_state.dart';

//pages
import 'package:familyapp/pages/user/profile_page.dart';
import 'package:familyapp/pages/functions/todo/todo_page.dart';
import 'package:familyapp/pages/functions/calendar/calendar_page.dart';
import 'package:familyapp/pages/functions/notes/notes_page.dart';
import 'package:familyapp/pages/functions/documents/documents_page.dart';
import 'package:familyapp/pages/functions/contacts/contacts_page.dart';
import 'package:familyapp/pages/auth/auth_page.dart';

//services
import 'package:familyapp/services/contact_service.dart';
import 'package:familyapp/services/note_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is NotAuthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBarStyles.dashboard(
          title: 'FAM-ILY',

          onProfile: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          ),
        ),
        body: wholeBody(context),
      ),
    );
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
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => TodoBloc(TodoService()),
                  child: Todo(
                    groupId: currentGroup!,
                    createdBy: FirebaseAuth.instance.currentUser!.uid,
                    updatedBy: '',
                  ),
                ),
              ),
            );
            break;

          case "Calendar":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => CalendarBloc(CalendarService()),
                  child: CalendarScreen(
                    groupId: currentGroup!,
                    createdBy: FirebaseAuth.instance.currentUser!.uid,
                  ),
                ),
              ),
            );
            break;

          case "Notes":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => NoteBloc(NoteService()),
                  child: Notes(
                    groupId: currentGroup!,
                    createdBy: FirebaseAuth.instance.currentUser!.uid,
                  ),
                ),
              ),
            );
            break;

          case "Documents":
            final documentService = DocumentService();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => DocumentBloc(documentService),
                  child: Documents(
                    groupId: currentGroup!,
                    fileName: '',
                    documentService: documentService,
                  ),
                ),
              ),
            );
            break;

          case "Contacts":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => ContactBloc(ContactService()),
                  child: Contacts(groupId: currentGroup!),
                ),
              ),
            );
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
}
