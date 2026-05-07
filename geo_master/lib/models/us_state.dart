class USState {
  final String id;
  final String name;
  final String capital;
  final double population;
  final String trimmedName;

  USState({
    required this.id,
    required this.name,
    required this.capital,
    required this.population,
    required this.trimmedName,
  });

  factory USState.fromJson(Map<String, dynamic> json) {
    return USState(
      id: json['id'] as String,
      name: json['name'] as String,
      capital: json['capital'] as String,
      population: json['population'] as double,
      trimmedName: normalize(json['name'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'capital': capital,
    'population': population,
    'trimmedName': trimmedName,
  };

  static String normalize(String input) {
    const accents = 'àáâãäåèéêëìíîïòóôõöùúûüýÿñç';
    const replacements = 'aaaaaaeeeeiiiiooooouuuuyync';
    var result = input.toLowerCase();

    for (var i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], replacements[i]);
    }

    return result.replaceAll(RegExp(r'[^a-z]'), '');
  }
}
