import 'package:flutter/material.dart';
import '../services/workout_service.dart';
import 'workout_upsert_screen.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  Future<void> _addRoutineDialog() async {
    final level = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Add Preset Routine'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Beginner'),
            child: const Text('Beginner'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Intermediate'),
            child: const Text('Intermediate'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'Advanced'),
            child: const Text('Advanced'),
          ),
          const Divider(height: 8),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (level == null) return;
    await WorkoutService.instance.insertRoutine(level);
    if (!mounted) return;
    setState(() {});
  }

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

  // NEW: reliable FAB action menu via bottom sheet
  Future<void> _showAddMenu() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Add Workout'),
              onTap: () async {
                Navigator.pop(context);
                await _openAdd();
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add_check),
              title: const Text('Add Routine'),
              onTap: () async {
                Navigator.pop(context);
                await _addRoutineDialog();
              },
            ),
          ],
        ),
      ),
    );
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
            child: Text('No workouts yet. Tap the + button to get started.'),
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
            onPressed: _showAddMenu,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        );
      },
    );
  }
}
