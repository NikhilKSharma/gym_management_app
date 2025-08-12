class Member {
  final String id;
  final String name;
  final String gender;
  final DateTime dob;
  final DateTime membershipEndDate;
  final String? photoUrl;
  final String? trainerName; // New field for the trainer's name

  Member({
    required this.id,
    required this.name,
    required this.gender,
    required this.dob,
    required this.membershipEndDate,
    this.photoUrl,
    this.trainerName,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    // Handle the populated trainer data
    String? tName;
    if (json['trainerId'] != null && json['trainerId'] is Map) {
      tName = json['trainerId']['name'];
    }

    return Member(
      id: json['_id'],
      name: json['name'],
      gender: json['gender'],
      dob: DateTime.parse(json['dob']),
      membershipEndDate: DateTime.parse(json['membershipEndDate']),
      photoUrl: json['photoUrl'],
      trainerName: tName,
    );
  }
}
