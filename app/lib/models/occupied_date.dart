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

  Map<String, dynamic> toJson() {
    return {'from': from.toIso8601String(), 'to': to.toIso8601String()};
  }

  int get year => from.year;
  int get month => from.month;
  int get day => from.day;
}
