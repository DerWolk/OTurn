class Group {
  final String id;
  final String name;
  final List<String> members;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      members: List<String>.from(json['members']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Group copyWith({
    String? id,
    String? name,
    List<String>? members,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}