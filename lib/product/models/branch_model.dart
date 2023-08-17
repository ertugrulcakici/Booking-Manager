// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:bookingmanager/product/models/branch_service_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/services/firebase/auth/auth_service.dart';
import 'expense_category_model.dart';
import 'user_model.dart';

class BranchModel {
  final String uid;
  final String name;
  final String ownerUid;
  final List<String> workersUids;
  final num pricePerPerson;
  final int defaultDurationInMs;
  final int defaultPersonCount;
  final int startHour;
  final int endHour;

  final int lastExpenseCategoryUpdatedDate;
  final int lastBranchServiceUpdatedDate;

  int get defaultDurationInMinute => defaultDurationInMs ~/ 1000 ~/ 60;

  List<BranchServiceModel> branchServices = [];
  List<ExpenseCategoryModel> expenseCategories = [];
  List<UserModel> users = [];

  BranchModel(
      {required this.uid,
      required this.name,
      required this.ownerUid,
      required this.workersUids,
      required this.pricePerPerson,
      required this.defaultDurationInMs,
      required this.defaultPersonCount,
      required this.startHour,
      required this.endHour,
      required this.lastExpenseCategoryUpdatedDate,
      required this.lastBranchServiceUpdatedDate});

  BranchModel.create({required String newUid, required String newName})
      : uid = newUid,
        name = newName,
        ownerUid = AuthService.instance.userModel!.uid,
        workersUids = [],
        pricePerPerson = 100,
        defaultDurationInMs = 1000 * 60 * 60,
        defaultPersonCount = 1,
        startHour = 9,
        endHour = 17,
        lastExpenseCategoryUpdatedDate = DateTime.now().millisecondsSinceEpoch,
        lastBranchServiceUpdatedDate = DateTime.now().millisecondsSinceEpoch;

  BranchModel copyWith({
    String? uid,
    String? name,
    String? ownerUid,
    List<String>? workersUids,
    num? pricePerPerson,
    int? defaultDurationInMs,
    int? defaultPersonCount,
    int? startHour,
    int? endHour,
    int? lastExpenseCategoryUpdatedDate,
    int? lastBranchServiceUpdatedDate,
  }) {
    if (endHour != null && endHour < this.startHour) {
      throw ErrorDescription(LocaleKeys.branch_model_start_time_error.tr());
    }
    if (startHour != null && startHour > this.endHour) {
      throw ErrorDescription(LocaleKeys.branch_model_finish_time_error.tr());
    }

    final newStartHour = startHour ?? this.startHour;
    final newEndHour = endHour ?? this.endHour;

    if (newStartHour == newEndHour) {
      throw ErrorDescription(
          LocaleKeys.branch_model_equal_hours_not_allowed.tr());
    }

    if (newStartHour <= 0 || newStartHour >= 23) {
      throw ErrorDescription(
          LocaleKeys.branch_model_start_hour_must_be_0_24.tr());
    }

    if (newEndHour <= 0 || newEndHour >= 23) {
      throw ErrorDescription(
          LocaleKeys.branch_model_end_hour_must_be_0_24.tr());
    }

    return BranchModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      ownerUid: ownerUid ?? this.ownerUid,
      workersUids: workersUids ?? this.workersUids,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      defaultDurationInMs: defaultDurationInMs ?? this.defaultDurationInMs,
      defaultPersonCount: defaultPersonCount ?? this.defaultPersonCount,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      lastExpenseCategoryUpdatedDate:
          lastExpenseCategoryUpdatedDate ?? this.lastExpenseCategoryUpdatedDate,
      lastBranchServiceUpdatedDate:
          lastBranchServiceUpdatedDate ?? this.lastBranchServiceUpdatedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'ownerUid': ownerUid,
      'workersUids': workersUids,
      'pricePerPerson': pricePerPerson,
      'defaultDurationInMs': defaultDurationInMs,
      'defaultPersonCount': defaultPersonCount,
      'startHour': startHour,
      'endHour': endHour,
      'lastExpenseCategoryUpdatedDate': lastExpenseCategoryUpdatedDate,
      'lastBranchServiceUpdatedDate': lastBranchServiceUpdatedDate,
    };
  }

  factory BranchModel.fromMap(Map<String, dynamic> map) {
    return BranchModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      ownerUid: map['ownerUid'] as String,
      workersUids: List<String>.from(map['workersUids']),
      pricePerPerson: map['pricePerPerson'] as num,
      defaultDurationInMs: map['defaultDurationInMs'] as int,
      defaultPersonCount: map['defaultPersonCount'] as int,
      startHour: map['startHour'] as int,
      endHour: map['endHour'] as int,
      lastExpenseCategoryUpdatedDate:
          map['lastExpenseCategoryUpdatedDate'] as int,
      lastBranchServiceUpdatedDate: map['lastBranchServiceUpdatedDate'] as int,
    );
  }

  @override
  String toString() {
    return 'BranchModel(uid: $uid, name: $name, ownerUid: $ownerUid, workersUids: $workersUids, pricePerPerson: $pricePerPerson, defaultDurationInMs: $defaultDurationInMs, defaultPersonCount: $defaultPersonCount, startHour: $startHour, endHour: $endHour, lastExpenseCategoryUpdatedDate: $lastExpenseCategoryUpdatedDate, lastBranchServiceUpdatedDate: $lastBranchServiceUpdatedDate)';
  }

  @override
  bool operator ==(covariant BranchModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
