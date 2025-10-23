import 'package:flutter/material.dart';
import '../services/meal_service.dart';
import '../utils/snack.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});
  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    final svc = MealService.instance;
    return FutureBuilder(
      future: svc.today(),
      builder: (c, snap) {
        final items = snap.data ?? [];
        final total = items.fold<int>(0, (s, m) => s + m.kcal);
        return Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [Text('Today Total: $total kcal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final m = items[i];
                    return ListTile(
                      title: Text(m.name),
                      subtitle: Text('${m.category} • ${m.kcal} kcal'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async { await svc.delete(m.id!); setState((){}); },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addMeal(context),
            label: const Text('Add Meal'), icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _addMeal(BuildContext context) async {
    final nameCtl = TextEditingController();
    final kcalCtl = TextEditingController();
    String category = 'Breakfast';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Meal'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Meal name')),
          TextField(controller: kcalCtl, decoration: const InputDecoration(labelText: 'Calories (kcal)'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: category,
            items: const ['Breakfast','Lunch','Dinner','Snack']
                .map((e) => DropdownMenuItem(value:e, child: Text(e))).toList(),
            onChanged: (v){ category = v!; },
            decoration: const InputDecoration(labelText: 'Category'),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    final kcal = int.tryParse(kcalCtl.text.trim()) ?? -1;
    if (nameCtl.text.trim().isEmpty || kcal < 0) { showSnack(context, 'Enter valid name and calories'); return; }
    await MealService.instance.insert(nameCtl.text.trim(), kcal, category);
    if (context.mounted) setState((){});
  }
}
