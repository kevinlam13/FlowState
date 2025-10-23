import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'screens/workout_log_screen.dart';
import 'screens/calorie_tracker_screen.dart';
import 'screens/progress_screen.dart';
import 'services/local_notifications.dart';
import 'services/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDb.instance.init();            // SQLite (no tables yet; created later)
  await LocalNotifs.ensureInitialized();  // Notifications (wired later)
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _idx = 0;
  final _pages = const [
    WorkoutLogScreen(),
    CalorieTrackerScreen(),
    ProgressScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEE, MMM d').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text('Fitness Tracker • $today')),
      body: _pages[_idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Workouts'),
          NavigationDestination(icon: Icon(Icons.fastfood), label: 'Calories'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Progress'),
        ],
      ),
    );
  }
}
