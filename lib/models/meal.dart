class Meal {
  final int? id;
  final String name;
  final int kcal;
  final String category;
  final DateTime date;

  Meal({this.id, required this.name, required this.kcal, required this.category, required this.date});

  Map<String, dynamic> toRow() => {
    'id': id, 'name': name, 'kcal': kcal, 'category': category, 'date': date.toIso8601String()
  };

  static Meal fromRow(Map<String, dynamic> r) => Meal(
    id: r['id'] as int?, name: r['name'] as String, kcal: r['kcal'] as int,
    category: r['category'] as String, date: DateTime.parse(r['date'] as String),
  );
}
