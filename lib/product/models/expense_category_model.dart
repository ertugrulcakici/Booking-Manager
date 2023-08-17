// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/widgets.dart';

@immutable
final class ExpenseCategoryModel {
  final String uid;
  final String name;
  final String? description;
  const ExpenseCategoryModel({
    required this.uid,
    required this.name,
    required this.description,
  });

  ExpenseCategoryModel copyWith({
    String? uid,
    String? name,
    String? description,
  }) {
    return ExpenseCategoryModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'description': description,
    };
  }

  factory ExpenseCategoryModel.fromMap(Map<String, dynamic> map) {
    return ExpenseCategoryModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExpenseCategoryModel.fromJson(String source) =>
      ExpenseCategoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ExpenseCategoryModel(uid: $uid, name: $name, description: $description)';

  @override
  bool operator ==(covariant ExpenseCategoryModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.name == name &&
        other.description == description;
  }

  @override
  int get hashCode => uid.hashCode ^ name.hashCode ^ description.hashCode;
}
