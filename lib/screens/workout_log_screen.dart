import 'package:flutter/material.dart';
import '../services/workout_service.dart';
import 'workout_upsert_screen.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});
  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  @override
  Widget build(BuildContext context) {
    final svc = WorkoutService.instance;
    return FutureBuilder(
      future: svc.getAll(),
      builder: (c, snap) {
        final items = snap.data ?? [];
        return Scaffold(
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final w = items[i];
              return ListTile(
                title: Text(w.type),
                subtitle: Text(w.pretty()),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async { await svc.delete(w.id!); setState((){}); },
                ),
                onTap: () async {
                  await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => WorkoutUpsertScreen(existing: w)));
                  setState((){});
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutUpsertScreen()));
              setState((){});
            },
            label: const Text('Add Workout'), icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
