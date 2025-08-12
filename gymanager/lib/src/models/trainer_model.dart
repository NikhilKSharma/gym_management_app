class Trainer {
  final String id;
  final String name;
  final String gender;

  Trainer({
    required this.id,
    required this.name,
    required this.gender,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: json['_id'],
      name: json['name'],
      gender: json['gender'],
    );
  }
}
