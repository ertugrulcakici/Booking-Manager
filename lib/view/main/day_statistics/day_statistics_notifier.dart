import 'package:bookingmanager/core/extensions/date_and_time_extensions.dart';
import 'package:bookingmanager/product/mixins/loading_notifier_mixin.dart';
import 'package:bookingmanager/product/models/branch_model.dart';
import 'package:bookingmanager/product/models/branch_service_model.dart';
import 'package:bookingmanager/product/models/expense_category_model.dart';
import 'package:bookingmanager/product/models/expense_model.dart';
import 'package:bookingmanager/product/models/session_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DayStatisticsNotifier extends ChangeNotifier with LoadingNotifierMixin {
  List<ExpenseModel> expenses = [];
  List<SessionModel> sessions = [];
  List<BranchServiceModel> services = [];
  List<ExpenseCategoryModel> expenseCategories = [];

  // Günlük toplam gelir
  num get totalIncome {
    num total = 0;
    for (var element in sessions) {
      total += element.total;
    }
    return total;
  }

  // Günlük toplam gider
  num get totalExpense {
    num total = 0;
    for (var element in expenses) {
      total += element.amount;
    }
    return total;
  }

  num get totalProfit => totalIncome - totalExpense;

  int get totalPersonCount {
    int total = 0;
    for (var element in sessions) {
      total += element.personCount;
    }
    return total;
  }

  int get totalSessionCount => sessions.length;

  // Günlük indirim
  num get totalDiscount {
    num total = 0;
    for (final session in sessions) {
      total += session.discount ?? 0;
    }
    return total;
  }

  // Günlük ekstra
  num get totalExtra {
    num total = 0;
    for (final session in sessions) {
      total += session.extra ?? 0;
    }
    return total;
  }

  // Toplam hizmet geliri
  num get totalServiceIncome {
    num total = 0;
    for (final session in sessions) {
      total += session.serviceTotal;
    }
    return total;
  }

  // Hizmetlerin gelirleri
  Map<String, num> get servicesTotals {
    final Map<String, num> data = {};
    for (final session in sessions) {
      for (final service in session.branchServicesUids) {
        BranchServiceModel serviceModel = session.branch.branchServices
            .firstWhere((element) => element.uid == service);
        data[serviceModel.name] =
            (data[serviceModel.name] ?? 0) + serviceModel.price;
      }
    }
    return data;
  }

  Map<String, num> get expenseCategoryTotals {
    final Map<String, num> data = {};
    for (final expense in expenses) {
      data[expense.category.name] =
          (data[expense.category.name] ?? 0) + expense.amount;
    }
    return data;
  }

  DateTime selectedDate;
  BranchModel branch;
  DayStatisticsNotifier(this.selectedDate, this.branch);

  Future<void> getStatistics(List<SessionModel> newSessions) async {
    try {
      isLoading = true;
      await _getExpenses();
      sessions = newSessions;
      services = branch.branchServices;
      expenseCategories = branch.expenseCategories;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  Future<void> _getExpenses() async {
    try {
      isLoading = true;
      final query = await FirebaseFirestore.instance
          .collection("branches/${branch.uid}/expenses")
          .where("createdDate",
              isGreaterThanOrEqualTo:
                  selectedDate.dayBeginning.millisecondsSinceEpoch,
              isLessThanOrEqualTo:
                  selectedDate.dayEnding.millisecondsSinceEpoch)
          .get();
      expenses = query.docs.map((e) => ExpenseModel.fromMap(e.data())).toList();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }
}
