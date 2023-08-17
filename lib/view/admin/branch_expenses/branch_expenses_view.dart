import 'package:bookingmanager/core/extensions/date_and_time_extensions.dart';
import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:bookingmanager/core/utils/popup_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/models/branch_model.dart';
import '../../../product/models/expense_model.dart';
import '../../../product/providers/provider_manager.dart';
import 'branch_expenses_notifier.dart';

class BranchExpensesView extends ConsumerStatefulWidget {
  final String branchUid;
  const BranchExpensesView({super.key, required this.branchUid});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BranchExpensesViewState();
}

class _BranchExpensesViewState extends ConsumerState<BranchExpensesView> {
  BranchModel get _branch => ref
      .watch(ProviderManager.branchManagerProvider)
      .getBranch(widget.branchUid)!;
  late final AutoDisposeChangeNotifierProvider<BranchExpensesNotifier> provider;

  @override
  void initState() {
    provider = ChangeNotifierProvider.autoDispose<BranchExpensesNotifier>(
        (ref) => BranchExpensesNotifier(_branch));

    Future.value().then((value) {
      ref.read(provider).getExpenses();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text(LocaleKeys.branch_expenses_view_title
          .tr(args: [ref.watch(provider).selectedDate.formattedDate])),
      centerTitle: true,
      actions: [
        IconButton(
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: ref.watch(provider).selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (selectedDate != null) {
                ref.read(provider).selectedDate = selectedDate;
                ref.read(provider).getExpenses();
              }
            },
            icon: const Icon(Icons.date_range)),
      ],
    );
  }

  Widget _body() {
    if (ref.watch(provider).isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ref.watch(provider).isError) {
      return Center(
          child: ElevatedButton(
              onPressed: () {
                ref.read(provider).getExpenses();
              },
              child: Text(ref.watch(provider).errorMessage)));
    }

    if (ref.watch(provider).expenses.isEmpty) {
      return Center(
          child: Text(LocaleKeys.branch_expenses_view_expense_not_found.tr()));
    }
    return _bodyContent();
  }

  Widget _bodyContent() {
    return Column(
      children: [
        Text(LocaleKeys.branch_expenses_view_daily_total
            .tr(args: [ref.watch(provider).totalAmount.toStringAsFixed(2)])),
        // "Gün toplamı: ${ref.watch(provider).totalAmount.toStringAsFixed(2)}"),
        const Divider(),
        ListView.builder(
          shrinkWrap: true,
          itemCount: ref.watch(provider).expenses.length,
          itemBuilder: (context, index) {
            return _expenseItem(ref.watch(provider).expenses[index]);
          },
        )
      ],
    );
  }

  Widget _expenseItem(ExpenseModel expense) {
    String subtitle = "";
    if (expense.description != null) {
      subtitle = expense.description!;
    }

    return Card(
      child: ListTile(
        title: Text(expense.categoryName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.branch_expenses_view_total
                .tr(args: [expense.amount.toStringAsFixed(2)])),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                    child: Text(LocaleKeys.branch_expenses_view_description
                        .tr(args: [subtitle.isEmpty ? "-" : subtitle]))),
                const SizedBox(width: 10),
                Text(LocaleKeys.branch_expenses_view_added_time
                    .tr(args: [expense.createdDateFormattedTime])),
              ],
            ),
          ],
        ),
        trailing: IconButton(
            onPressed: () {
              PopupHelper.showOkCancelDialog(
                  title:
                      LocaleKeys.branch_expenses_view_delete_expense_title.tr(),
                  content: LocaleKeys
                      .branch_expenses_view_delete_expense_content
                      .tr(),
                  onOk: () {
                    ref.read(provider).deleteExpense(expense);
                  });
            },
            icon: const Icon(Icons.delete)),
      ),
    );
  }
}
