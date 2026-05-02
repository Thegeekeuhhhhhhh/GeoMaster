class IDD {
  final String root;
  final List<String> suffixes;

  IDD({required this.root, required this.suffixes});

  factory IDD.fromJson(Map<String, dynamic> json) {
    return IDD(
      root: json["root"] as String,
      suffixes: List<String>.from(json["suffixes"]),
    );
  }
}
