class OccupiedDate {
  final DateTime from;
  final DateTime to;

  OccupiedDate({required this.from, required this.to});

  factory OccupiedDate.fromJson(Map<String, dynamic> json) {
    return OccupiedDate(
      from: DateTime.parse(json['from']),
      to: DateTime.parse(json['to']),
    );
  }
}
