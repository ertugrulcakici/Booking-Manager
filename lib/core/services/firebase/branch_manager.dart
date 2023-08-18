import 'dart:async';

import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:bookingmanager/product/models/expense_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import '../../../product/models/branch_model.dart';
import '../../../product/models/branch_service_model.dart';
import '../../../product/models/expense_category_model.dart';
import '../../../product/models/user_model.dart';
import 'auth/auth_service.dart';

class BranchManager extends ChangeNotifier {
  BranchManager();

  @override
  void dispose() {
    branchesListener?.cancel();
    branchesListener = null;
    branches = [];
    super.dispose();
  }

  StreamSubscription<QuerySnapshot>? branchesListener;
  List<BranchModel> branches = [];

  BranchModel? getBranch(String uid) =>
      branches.firstWhere((element) => element.uid == uid);

  Future<UserModel> getBranchUser({
    required String branchUid,
    required String userUid,
  }) async {
    final branch = getBranch(branchUid)!;
    if (branch.ownerUid == userUid) {
      return AuthService.instance.userModel!;
    }

    if (branch.workersUids.contains(userUid)) {
      return branch.users.firstWhere((element) => element.uid == userUid);
    }

    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(userUid).get();
    if (userDoc.exists) {
      return UserModel.fromMap(userDoc.data()!);
    }

    return UserModel.deletedUser();
  }

  Future<void> toggleListener() async {
    branchesListener?.cancel();
    if (AuthService.instance.userModel!.workersOf.isEmpty &&
        AuthService.instance.userModel!.ownersOf.isEmpty) {
      return;
    }
    branchesListener = FirebaseFirestore.instance
        .collection("branches")
        .where("uid", whereIn: [
          ...AuthService.instance.userModel!.workersOf,
          ...AuthService.instance.userModel!.ownersOf
        ])
        .snapshots()
        .listen((event) async {
          final newBranches =
              event.docs.map((e) => BranchModel.fromMap(e.data())).toList();

          for (BranchModel newBranch in newBranches) {
            await _fetchServices(newBranch, dontNotify: true);
            await _fetchExpenseCategories(newBranch, dontNotify: true);
            await _fetchUsers(newBranch, dontNotify: true);
          }
          branches = newBranches;
          notifyListeners();
        });
  }

  Future<void> _fetchServices(BranchModel branch,
      {bool dontNotify = false}) async {
    final QuerySnapshot<Map<String, dynamic>> branchServices =
        await FirebaseFirestore.instance
            .collection("branches/${branch.uid}/branch_services")
            .get();
    branch.branchServices = branchServices.docs
        .map((e) => BranchServiceModel.fromMap(e.data()))
        .toList();
    if (!dontNotify) {
      notifyListeners();
    }
  }

  Future<void> _fetchExpenseCategories(BranchModel branch,
      {bool dontNotify = false}) async {
    final QuerySnapshot<Map<String, dynamic>> expenseCategories =
        await FirebaseFirestore.instance
            .collection("branches/${branch.uid}/expense_categories")
            .get();
    branch.expenseCategories = expenseCategories.docs
        .map((e) => ExpenseCategoryModel.fromMap(e.data()))
        .toList();
    if (!dontNotify) {
      notifyListeners();
    }
  }

  Future<void> _fetchUsers(BranchModel branch,
      {bool dontNotify = false}) async {
    final QuerySnapshot<Map<String, dynamic>> users = await FirebaseFirestore
        .instance
        .collection("users")
        .where("uid", whereIn: [branch.ownerUid, ...branch.workersUids]).get();
    branch.users = users.docs.map((e) => UserModel.fromMap(e.data())).toList();
    if (!dontNotify) {
      notifyListeners();
    }
  }

  Future<void> createBranch(String name) async {
    String newUid = FirebaseFirestore.instance.collection("branches").doc().id;
    final branch = BranchModel.create(newUid: newUid, newName: name);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
          FirebaseFirestore.instance.collection("branches").doc(branch.uid),
          branch.toMap());
      transaction.update(
          FirebaseFirestore.instance
              .collection("users")
              .doc(AuthService.instance.userModel!.uid),
          {
            "ownersOf": FieldValue.arrayUnion([branch.uid]),
          });
    });
  }

  Future<void> deleteBranch(BranchModel branch) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.delete(
          FirebaseFirestore.instance.collection("branches").doc(branch.uid));
      transaction.update(
          FirebaseFirestore.instance
              .collection("users")
              .doc(AuthService.instance.userModel!.uid),
          {
            "ownersOf": FieldValue.arrayRemove([branch.uid]),
          });

      for (String workerUid in branch.workersUids) {
        transaction.update(
            FirebaseFirestore.instance.collection("users").doc(workerUid), {
          "workersOf": FieldValue.arrayRemove([branch.uid]),
        });
      }
    });
  }

  Future<void> leaveBranch(String uid) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(
        FirebaseFirestore.instance
            .collection("users")
            .doc(AuthService.instance.userModel!.uid),
        {
          "workersOf": FieldValue.arrayRemove([uid]),
        },
      );
      transaction.update(
        FirebaseFirestore.instance.collection("branches").doc(uid),
        {
          "workersUids":
              FieldValue.arrayRemove([AuthService.instance.userModel!.uid]),
        },
      );
    });
  }

  Future<void> createExpense(
      {required String branchUid,
      required String categoryUid,
      required num amount,
      String? description}) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docRef = FirebaseFirestore.instance
          .collection("branches/$branchUid/expenses")
          .doc();
      ExpenseModel expense = ExpenseModel(
          uid: docRef.id,
          categoryUid: categoryUid,
          branchUid: branchUid,
          amount: amount,
          createdByUid: AuthService.instance.userModel!.uid,
          createdDate: DateTime.now().millisecondsSinceEpoch,
          description: description);
      transaction.set(docRef, expense.toMap());
    });
  }

  Future<void> editBranch(BranchModel branch) async {
    await FirebaseFirestore.instance
        .collection("branches")
        .doc(branch.uid)
        .set(branch.toMap());
  }

  Future<void> addWorkerToBranch(
      {required String branchUid, required String userMail}) async {
    final branch = branches.firstWhere((element) => element.uid == branchUid);
    if (branch.users.any((element) => element.email == userMail)) {
      throw ErrorDescription("Kullanıcı zaten bu şubede kayıtlı");
    }

    final String? result = await FirebaseFirestore.instance
        .runTransaction<String?>((transaction) async {
      final userDocRef = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: userMail)
          .get();
      if (userDocRef.docs.isEmpty) {
        return LocaleKeys.commons_user_not_found.tr();
      }
      final userDoc = await transaction.get(userDocRef.docs.first.reference);
      if (!userDoc.exists) {
        return LocaleKeys.commons_user_not_found.tr();
      }

      transaction.update(userDoc.reference, {
        "workersOf": FieldValue.arrayUnion([branchUid])
      });

      transaction.update(
          FirebaseFirestore.instance.collection("branches").doc(branchUid), {
        "workersUids": FieldValue.arrayUnion([userDoc.data()!["uid"]])
      });
      return null;
    }, maxAttempts: 1, timeout: const Duration(seconds: 5));
    if (result != null) {
      throw ErrorDescription(result);
    }
  }

  Future<void> setBranchServiceToBranch(
      {required String branchUid,
      required String serviceName,
      required num servicePrice,
      String? serviceUid}) async {
    try {
      final serviceDocRef = FirebaseFirestore.instance
          .collection("branches/$branchUid/branch_services")
          .doc(serviceUid);

      final branchDocRef =
          FirebaseFirestore.instance.collection("branches").doc(branchUid);

      final serviceModel = BranchServiceModel(
          uid: serviceDocRef.id, name: serviceName, price: servicePrice);
      final BranchModel newBranchModel = getBranch(branchUid)!.copyWith(
          lastBranchServiceUpdatedDate: DateTime.now().millisecondsSinceEpoch);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(serviceDocRef, serviceModel.toMap());
        transaction.update(branchDocRef, newBranchModel.toMap());
      });
    } catch (e) {
      throw ErrorDescription(serviceUid == null
          ? LocaleKeys.branch_manager_error_creating_service.tr()
          : LocaleKeys.branch_manager_error_updating_service.tr());
    }
  }

  Future<void> deleteBranchService(
      {required String branchUid, required String serviceUid}) async {
    try {
      final serviceDocRef = FirebaseFirestore.instance
          .collection("branches/$branchUid/branch_services")
          .doc(serviceUid);
      final branchDocRef =
          FirebaseFirestore.instance.collection("branches").doc(branchUid);

      final usedSessionsQuery = FirebaseFirestore.instance
          .collection("branches/$branchUid/sessions")
          .where("branchServicesUids", arrayContains: serviceUid);

      final BranchModel newBranchModel = getBranch(branchUid)!.copyWith(
          lastBranchServiceUpdatedDate: DateTime.now().millisecondsSinceEpoch);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.delete(serviceDocRef);
        transaction.update(branchDocRef, newBranchModel.toMap());
        final usedSessionsQueryData = await usedSessionsQuery.get();
        for (var element in usedSessionsQueryData.docs) {
          await element.reference.update({
            "branchServicesUids": FieldValue.arrayRemove([serviceUid])
          });
        }
      });
    } catch (e) {
      throw ErrorDescription(
          LocaleKeys.branch_manager_error_deleting_service.tr());
    }
  }

  Future<void> setExpenseCategory(
      {required String branchUid,
      required String categoryName,
      String? categoryDescription,
      String? categoryUid}) async {
    try {
      final expenseCategoryDocRef = FirebaseFirestore.instance
          .collection("branches/$branchUid/expense_categories")
          .doc(categoryUid);
      final branchDocRef =
          FirebaseFirestore.instance.collection("branches").doc(branchUid);
      final BranchModel newBranchModel = getBranch(branchUid)!.copyWith(
          lastExpenseCategoryUpdatedDate:
              DateTime.now().millisecondsSinceEpoch);
      final category = ExpenseCategoryModel(
          uid: expenseCategoryDocRef.id,
          name: categoryName,
          description: categoryDescription);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(expenseCategoryDocRef, category.toMap());
        transaction.update(branchDocRef, newBranchModel.toMap());
      });
    } catch (e) {
      throw ErrorDescription(categoryUid == null
          ? LocaleKeys.branch_manager_error_creating_expense_category.tr()
          : LocaleKeys.branch_manager_error_updating_expense_category.tr());
    }
  }

  Future<void> deleteExpenseCategory(
      {required String branchUid, required String categoryUid}) async {
    try {
      final expenseCategoryDocRef = FirebaseFirestore.instance
          .collection("branches/$branchUid/expense_categories")
          .doc(categoryUid);
      final branchDocRef =
          FirebaseFirestore.instance.collection("branches").doc(branchUid);

      final BranchModel newBranchModel = getBranch(branchUid)!.copyWith(
          lastExpenseCategoryUpdatedDate:
              DateTime.now().millisecondsSinceEpoch);
      final usedExpensesQuery = FirebaseFirestore.instance
          .collection("branches/$branchUid/expenses")
          .where("categoryUid", isEqualTo: categoryUid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.delete(expenseCategoryDocRef);
        transaction.update(branchDocRef, newBranchModel.toMap());
        final usedExpensesQueryData = await usedExpensesQuery.get();
        for (var element in usedExpensesQueryData.docs) {
          transaction.delete(element.reference);
        }
      });
    } catch (e) {
      throw ErrorDescription(
          LocaleKeys.branch_manager_error_deleting_expense_category.tr());
    }
  }

  Future<void> deleteWorkerFromBranch(
      {required String branchUid, required String userUid}) async {
    final String? result = await FirebaseFirestore.instance
        .runTransaction<String?>((transaction) async {
      final userDocRef =
          FirebaseFirestore.instance.collection("users").doc(userUid);

      transaction.update(userDocRef, {
        "workersOf": FieldValue.arrayRemove([branchUid])
      });

      transaction.update(
          FirebaseFirestore.instance.collection("branches").doc(branchUid), {
        "workersUids": FieldValue.arrayRemove([userUid])
      });
      return null;
    }, maxAttempts: 1, timeout: const Duration(seconds: 5));
    if (result != null) {
      throw ErrorDescription(result);
    }
  }
}
