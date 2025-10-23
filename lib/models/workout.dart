class Workout {
  final int? id;
  final String type;
  final int? sets;
  final int? reps;
  final int? durationMin;
  final DateTime date;

  Workout({
    this.id,
    required this.type,
    this.sets,
    this.reps,
    this.durationMin,
    required this.date,
  });

  Workout copyWith({int? id, String? type, int? sets, int? reps, int? durationMin, DateTime? date}) =>
      Workout(id: id ?? this.id, type: type ?? this.type, sets: sets ?? this.sets,
          reps: reps ?? this.reps, durationMin: durationMin ?? this.durationMin, date: date ?? this.date);

  String pretty() {
    if (durationMin != null) return '$type • ${durationMin}m';
    if (sets != null && reps != null) return '$type • ${sets}x$reps';
    return type;
  }

  Map<String, dynamic> toRow() => {
    'id': id,
    'type': type,
    'sets': sets,
    'reps': reps,
    'durationMin': durationMin,
    'date': date.toIso8601String(),
  };

  static Workout fromRow(Map<String, dynamic> r) => Workout(
    id: r['id'] as int?, type: r['type'] as String,
    sets: r['sets'] as int?, reps: r['reps'] as int?,
    durationMin: r['durationMin'] as int?, date: DateTime.parse(r['date'] as String),
  );
}
