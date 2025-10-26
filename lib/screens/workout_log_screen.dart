import 'package:flutter/material.dart';
import '../services/workout_service.dart';
import 'workout_upsert_screen.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  Future<void> _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WorkoutUpsertScreen()),
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openEdit(int index, List items) async {
    final w = items[index];
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutUpsertScreen(existing: w)),
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final svc = WorkoutService.instance;

    return FutureBuilder(
      future: svc.getAll(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];

        return Scaffold(
          body: items.isEmpty
              ? const Center(
            child: Text('No workouts yet. Tap "Add Workout" to create one.'),
          )
              : ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final w = items[i];
              return ListTile(
                title: Text(w.type),
                subtitle: Text(w.pretty()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await svc.delete(w.id!);
                    if (!mounted) return;
                    setState(() {});
                  },
                ),
                onTap: () => _openEdit(i, items),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Workout'),
          ),
        );
      },
    );
  }
}
