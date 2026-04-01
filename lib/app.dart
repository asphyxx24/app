import 'package:flutter/material.dart';
import 'package:mein_organizer/shared/theme.dart';
import 'package:mein_organizer/features/home/home_screen.dart';
import 'package:mein_organizer/features/notes/notes_screen.dart';
import 'package:mein_organizer/features/flashcards/decks_screen.dart';
import 'package:mein_organizer/features/calendar/calendar_screen.dart';
import 'package:mein_organizer/features/assistant/chat_screen.dart';

class MeinOrganizerApp extends StatelessWidget {
  const MeinOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mein Organizer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void setTab(int index) {
    setState(() => _currentIndex = index);
  }

  static const _screens = <Widget>[
    HomeScreen(),
    NotesScreen(),
    DecksScreen(),
    CalendarScreen(),
    ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: setTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note_rounded),
            label: 'Notizen',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style_rounded),
            label: 'Karten',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Kalender',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy_rounded),
            label: 'Claude',
          ),
        ],
      ),
    );
  }
}
