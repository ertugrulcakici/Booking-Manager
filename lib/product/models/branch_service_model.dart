// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BranchServiceModel {
  final String uid;
  final String name;
  final num price;
  BranchServiceModel({
    required this.uid,
    required this.name,
    required this.price,
  });

  BranchServiceModel copyWith({
    String? uid,
    String? name,
    num? price,
  }) {
    return BranchServiceModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'price': price,
    };
  }

  factory BranchServiceModel.fromMap(Map<String, dynamic> map) {
    return BranchServiceModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      price: map['price'] as num,
    );
  }

  String toJson() => json.encode(toMap());

  factory BranchServiceModel.fromJson(String source) =>
      BranchServiceModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BranchService(uid: $uid, name: $name, price: $price)';
  }

  @override
  bool operator ==(covariant BranchServiceModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid && other.name == name && other.price == price;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ name.hashCode ^ price.hashCode;
  }
}
