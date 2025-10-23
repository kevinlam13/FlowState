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
            TextFormField(controller: setsCtl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sets (optional)')),
            TextFormField(controller: repsCtl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reps (optional)')),
            TextFormField(controller: durCtl,  keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration (min, optional)')),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                final sets = int.tryParse(setsCtl.text);
                final reps = int.tryParse(repsCtl.text);
                final dur  = int.tryParse(durCtl.text);
                if ((sets == null || reps == null) && dur == null) {
                  showSnack(context, 'Provide sets&reps OR duration'); return;
                }
                if (widget.existing == null) {
                  await WorkoutService.instance.insert(Workout(
                    type: _type.value, sets: sets, reps: reps, durationMin: dur, date: DateTime.now(),
                  ));
                } else {
                  final w = widget.existing!;
                  await WorkoutService.instance.update(w.copyWith(
                    type: _type.value, sets: sets, reps: reps, durationMin: dur,
                  ));
                }
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.save), label: Text(editing ? 'Save Changes' : 'Save Workout'),
            )
          ],
        ),
      ),
    );
  }
}
