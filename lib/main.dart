import 'package:flutter/material.dart';
//cubit
import 'package:familyapp/cubit/calendarEvent_cubit/calendarEvent_bloc.dart';
import 'package:familyapp/cubit/contact_cubit/contact_bloc.dart';
import 'package:familyapp/cubit/document_cubit/document_bloc.dart';
import 'package:familyapp/cubit/note_cubit/note_bloc.dart';
import 'package:familyapp/cubit/todo_cubit/todo_bloc.dart';
import 'package:familyapp/cubit/user_cubit/user_bloc.dart';
import 'package:familyapp/cubit/user_cubit/user_state.dart';
//pages
import 'package:familyapp/pages/auth/auth_page.dart';
import 'package:familyapp/pages/dashboard/dashboard.dart';
//services
import 'package:familyapp/services/calendarEvent_service.dart';
import 'package:familyapp/services/contact_service.dart';
import 'package:familyapp/services/document_service.dart';
import 'package:familyapp/services/note_service.dart';
import 'package:familyapp/services/notification_service.dart';
import 'package:familyapp/services/userSubscription_service.dart';
import 'package:familyapp/services/todo_service.dart';
//dependencies
import 'package:familyapp/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MyApp(
      todoService: TodoService(),
      noteService: NoteService(),
      documentService: DocumentService(),
      contactService: ContactService(),
      calendarService: CalendarService(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final TodoService todoService;
  final NoteService noteService;
  final DocumentService documentService;
  final ContactService contactService;
  final CalendarService calendarService;
  const MyApp({
    super.key,
    required this.todoService,
    required this.noteService,
    required this.documentService,
    required this.contactService,
    required this.calendarService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(create: (_) => UserBloc()),
        BlocProvider<TodoBloc>(create: (_) => TodoBloc(todoService)),
        BlocProvider<NoteBloc>(create: (_) => NoteBloc(noteService)),
        BlocProvider<DocumentBloc>(
          create: (_) => DocumentBloc(documentService),
        ),
        BlocProvider<ContactBloc>(create: (_) => ContactBloc(contactService)),
        BlocProvider<CalendarBloc>(
          create: (_) => CalendarBloc(calendarService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocListener<UserBloc, UserState>(
          listener: (context, state) async {
            if (state is LoggedIn) {
              await UserSubscriptionService.init();
              await NotificationService().initFCM();
            }

            if (state is NotAuthenticated) {
              UserSubscriptionService.stopListening();
            }
          },
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is AuthInProgress) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is NotAuthenticated) {
                return const AuthPage();
              }

              return const Dashboard();
            },
          ),
        ),
      ),
    );
  }
}
