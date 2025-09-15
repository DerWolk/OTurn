class Task {
  final String id;
  final String name;
  final String? groupId;
  final List<String> additionalMembers;
  final List<String> excludedMembers;
  final bool fairMode;
  final List<TaskHistory> history;
  final List<String> fairQueue;
  final DateTime createdAt;
  final DateTime lastUpdated;

  Task({
    required this.id,
    required this.name,
    this.groupId,
    required this.additionalMembers,
    required this.excludedMembers,
    required this.fairMode,
    required this.history,
    required this.fairQueue,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      groupId: json['group_id'],
      additionalMembers: List<String>.from(json['additional_members'] ?? []),
      excludedMembers: List<String>.from(json['excluded_members'] ?? []),
      fairMode: json['fair_mode'] ?? true,
      history: (json['history'] as List?)
          ?.map((h) => TaskHistory.fromJson(h))
          .toList() ?? [],
      fairQueue: List<String>.from(json['fair_queue'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'group_id': groupId,
      'additional_members': additionalMembers,
      'excluded_members': excludedMembers,
      'fair_mode': fairMode,
      'history': history.map((h) => h.toJson()).toList(),
      'fair_queue': fairQueue,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? name,
    String? groupId,
    List<String>? additionalMembers,
    List<String>? excludedMembers,
    bool? fairMode,
    List<TaskHistory>? history,
    List<String>? fairQueue,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      additionalMembers: additionalMembers ?? this.additionalMembers,
      excludedMembers: excludedMembers ?? this.excludedMembers,
      fairMode: fairMode ?? this.fairMode,
      history: history ?? this.history,
      fairQueue: fairQueue ?? this.fairQueue,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class TaskHistory {
  final String selectedPerson;
  final DateTime timestamp;
  final List<String> participants;

  TaskHistory({
    required this.selectedPerson,
    required this.timestamp,
    required this.participants,
  });

  factory TaskHistory.fromJson(Map<String, dynamic> json) {
    return TaskHistory(
      selectedPerson: json['selected_person'],
      timestamp: DateTime.parse(json['timestamp']),
      participants: List<String>.from(json['participants']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selected_person': selectedPerson,
      'timestamp': timestamp.toIso8601String(),
      'participants': participants,
    };
  }
}