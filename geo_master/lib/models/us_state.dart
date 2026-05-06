class USState {
  final String id;
  final String name;
  final String capital;
  final double population;

  USState({
    required this.id,
    required this.name,
    required this.capital,
    required this.population,
  });

  factory USState.fromJson(Map<String, dynamic> json) {
    return USState(
      id: json['id'] as String,
      name: json['name'] as String,
      capital: json['capital'] as String,
      population: json['population'] as double,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'capital': capital,
    'population': population,
  };
}
