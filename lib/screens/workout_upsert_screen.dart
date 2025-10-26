import 'package:flutter/material.dart';
import '../services/workout_service.dart';
import '../utils/snack.dart';
import '../models/workout.dart';

class WorkoutUpsertScreen extends StatefulWidget {
  final Workout? existing;
  const WorkoutUpsertScreen({super.key, this.existing});

  @override
  State<WorkoutUpsertScreen> createState() => _WorkoutUpsertScreenState();
}

class _WorkoutUpsertScreenState extends State<WorkoutUpsertScreen> {
  final _form = GlobalKey<FormState>();
  final _type = ValueNotifier('Run');
  final setsCtl = TextEditingController();
  final repsCtl = TextEditingController();
  final durCtl  = TextEditingController();

  @override
  void initState() {
    super.initState();
    final w = widget.existing;
    if (w != null) {
      _type.value = w.type;
      setsCtl.text = w.sets?.toString() ?? '';
      repsCtl.text = w.reps?.toString() ?? '';
      durCtl.text  = w.durationMin?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    setsCtl.dispose();
    repsCtl.dispose();
    durCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Workout' : 'Add Workout')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ValueListenableBuilder(
              valueListenable: _type,
              builder: (_, v, __) => DropdownButtonFormField(
                value: v,
                items: const ['Run','Walk','Cycle','Lift','Swim']
                    .map((e)=>DropdownMenuItem(value:e, child: Text(e))).toList(),
                onChanged: (val)=>_type.value = val!,
                decoration: const InputDecoration(labelText: 'Type'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: setsCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Sets (optional)'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: repsCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Reps (optional)'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: durCtl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration (min, optional)'),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () async {
                final sets = int.tryParse(setsCtl.text.trim());
                final reps = int.tryParse(repsCtl.text.trim());
                final dur  = int.tryParse(durCtl.text.trim());

                // Validation:
                // 1) If using sets/reps, require both (no partial). Otherwise allow duration.
                if (((sets == null) ^ (reps == null)) && dur == null) {
                  showSnack(context, 'Provide both sets & reps OR a duration');
                  return;
                }
                // 2) Non-negative values only (if provided).
                if ((sets != null && sets < 0) ||
                    (reps != null && reps < 0) ||
                    (dur  != null && dur  < 0)) {
                  showSnack(context, 'Values cannot be negative');
                  return;
                }
                // 3) At least one mode must be provided.
                if ((sets == null || reps == null) && dur == null) {
                  showSnack(context, 'Provide sets&reps OR duration');
                  return;
                }

                if (!editing) {
                  await WorkoutService.instance.insert(Workout(
                    type: _type.value,
                    sets: sets,
                    reps: reps,
                    durationMin: dur,
                    date: DateTime.now(),
                  ));
                } else {
                  final w = widget.existing!;
                  await WorkoutService.instance.update(w.copyWith(
                    type: _type.value,
                    sets: sets,
                    reps: reps,
                    durationMin: dur,
                  ));
                }

                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: Text(editing ? 'Save Changes' : 'Save Workout'),
            )
          ],
        ),
      ),
    );
  }
}
