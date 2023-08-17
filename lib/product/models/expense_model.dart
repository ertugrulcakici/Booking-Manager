// ignore_for_file: public_member_api_docs, sort_constructors_first, hash_and_equals

import 'package:bookingmanager/core/extensions/date_and_time_extensions.dart';
import 'package:bookingmanager/product/models/branch_model.dart';
import 'package:bookingmanager/product/models/expense_category_model.dart';

import '../providers/provider_manager.dart';

class ExpenseModel {
  final String uid;
  final String createdByUid;
  final String branchUid;
  BranchModel get branch => ProviderManager.branchManager.getBranch(branchUid)!;
  ExpenseCategoryModel get category => branch.expenseCategories
      .firstWhere((element) => element.uid == categoryUid);
  final int createdDate;
  final String categoryUid;
  final String? description;
  final num amount;

  String get branchName =>
      ProviderManager.ref
          .read(ProviderManager.branchManagerProvider)
          .getBranch(branchUid)
          ?.name ??
      "İş yeri adı bulunamadı";

  String get createdDateFormattedTime =>
      DateTime.fromMillisecondsSinceEpoch(createdDate).formattedTime;

  String get categoryName => ProviderManager.ref
      .read(ProviderManager.branchManagerProvider)
      .getBranch(branchUid)!
      .expenseCategories
      .firstWhere((element) => element.uid == categoryUid)
      .name;

  ExpenseModel({
    required this.uid,
    required this.createdByUid,
    required this.branchUid,
    required this.createdDate,
    required this.categoryUid,
    this.description,
    required this.amount,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> json) {
    return ExpenseModel(
      uid: json['uid'] as String,
      createdByUid: json['createdByUid'] as String,
      branchUid: json['branchUid'] as String,
      createdDate: json['createdDate'] as int,
      categoryUid: json['categoryUid'] as String,
      description: json['description'] as String?,
      amount: json['amount'] as num,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'createdByUid': createdByUid,
      'branchUid': branchUid,
      'createdDate': createdDate,
      'categoryUid': categoryUid,
      'description': description,
      'amount': amount,
    };
  }

  // check if they are equal with uid

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModel &&
          runtimeType == other.runtimeType &&
          uid == other.uid;
}
