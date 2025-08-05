import 'dart:convert';

class Task {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime creationDate;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.creationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'creationDate': creationDate.toIso8601String(), // Store as a string
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] == 1,
      creationDate: DateTime.parse(json['creationDate']),
    );
  }

  factory Task.toJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Task.fromJson(json);
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? creationDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      creationDate: creationDate ?? this.creationDate,
    );
  }
}