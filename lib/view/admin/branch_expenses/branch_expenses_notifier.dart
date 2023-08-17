import 'package:bookingmanager/core/extensions/date_and_time_extensions.dart';
import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:bookingmanager/core/utils/popup_helper.dart';
import 'package:bookingmanager/product/mixins/loading_notifier_mixin.dart';
import 'package:bookingmanager/product/models/branch_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../product/models/expense_model.dart';

class BranchExpensesNotifier extends ChangeNotifier with LoadingNotifierMixin {
  BranchModel branchModel;
  BranchExpensesNotifier(this.branchModel);

  List<ExpenseModel> expenses = [];
  double get totalAmount => expenses.fold(
      0, (previousValue, element) => previousValue + element.amount);

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  set selectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners();
  }

  Future<void> getExpenses() async {
    try {
      final query = FirebaseFirestore.instance
          .collection("branches/${branchModel.uid}/expenses")
          .where("createdDate",
              isGreaterThanOrEqualTo:
                  _selectedDate.dayBeginning.millisecondsSinceEpoch,
              isLessThanOrEqualTo:
                  _selectedDate.dayEnding.millisecondsSinceEpoch);
      isLoading = true;
      final snapshot = await query.get();
      expenses =
          snapshot.docs.map((e) => ExpenseModel.fromMap(e.data())).toList();
      expenses.sort((a, b) => a.createdDate.compareTo(b.createdDate));
    } catch (e) {
      errorMessage = LocaleKeys.general_error_try_again.tr();
    } finally {
      isLoading = false;
    }
  }

  Future<void> deleteExpense(ExpenseModel expenseModel) async {
    try {
      PopupHelper.showLoadingWhile(() async => await FirebaseFirestore.instance
          .collection("branches/${branchModel.uid}/expenses")
          .doc(expenseModel.uid)
          .delete());
      expenses.remove(expenseModel);
      notifyListeners();
    } catch (e) {
      errorMessage = LocaleKeys.general_error_try_again.tr();
    } finally {
      isLoading = false;
    }
  }
}
