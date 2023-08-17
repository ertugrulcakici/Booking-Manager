import 'package:bookingmanager/core/extensions/date_and_time_extensions.dart';
import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:bookingmanager/product/providers/provider_manager.dart';
import 'package:bookingmanager/view/main/day_statistics/widget/custom_pie_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/models/branch_model.dart';
import 'day_statistics_notifier.dart';

part 'model/chart_sample_data_model.dart';

class DayStatisticsView extends ConsumerStatefulWidget {
  final BranchModel branchModel;
  final DateTime selectedDate;
  const DayStatisticsView(
      {super.key, required this.branchModel, required this.selectedDate});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DayStatisticsViewState();
}

class _DayStatisticsViewState extends ConsumerState<DayStatisticsView> {
  late final AutoDisposeChangeNotifierProvider<DayStatisticsNotifier> provider;

  @override
  void initState() {
    provider = ChangeNotifierProvider.autoDispose<DayStatisticsNotifier>(
        (ref) =>
            DayStatisticsNotifier(widget.selectedDate, widget.branchModel));
    Future.delayed(Duration.zero, () {
      ref
          .read(provider)
          .getStatistics(ref.watch(ProviderManager.sessionManagerProvider));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(LocaleKeys.day_statistics_title
              .tr(args: [widget.selectedDate.formattedDate]))),
      body: _body(),
    );
  }

  Widget _body() {
    if (ref.watch(provider).isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ref.watch(provider).isError) {
      return Center(
          child: ElevatedButton(
              onPressed: () => ref.read(provider).getStatistics(
                  ref.watch(ProviderManager.sessionManagerProvider)),
              child: Text(ref.watch(provider).errorMessage)));
    }

    return _bodyContent();
  }

  Widget _bodyContent() {
    return ListView(
      children: [
        _generalStatistics(),
        _servicesStatistics(),
        _expensesStatistics(),
      ],
    );
  }

  Widget _generalStatistics() {
    List<String> data = [
      LocaleKeys.day_statistics_total_income
          .tr(args: [ref.watch(provider).totalIncome.toStringAsFixed(2)]),
      LocaleKeys.day_statistics_total_expense
          .tr(args: [ref.watch(provider).totalExpense.toStringAsFixed(2)]),
      LocaleKeys.day_statistics_total_profit
          .tr(args: [ref.watch(provider).totalProfit.toStringAsFixed(2)]),
      LocaleKeys.day_statistics_total_discount
          .tr(args: [ref.watch(provider).totalDiscount.toStringAsFixed(2)]),
      LocaleKeys.day_statistics_total_extra
          .tr(args: [ref.watch(provider).totalExtra.toStringAsFixed(2)]),
      LocaleKeys.day_statistics_total_person_count
          .tr(args: [ref.watch(provider).totalPersonCount.toString()]),
      LocaleKeys.day_statistics_total_session_count
          .tr(args: [ref.watch(provider).totalSessionCount.toString()]),
    ];
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.separated(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final rowData = data[index];
            final header = rowData.split(":")[0];
            final value = rowData.split(":")[1];
            return Row(
              children: [
                Expanded(child: Center(child: Text(header))),
                Container(
                    width: 1, height: 50, color: Colors.black.withOpacity(0.1)),
                Expanded(child: Center(child: Text(value))),
              ],
            );
          },
          separatorBuilder: (context, index) {
            double thickness = [4, 2].contains(index) ? 1 : 0;
            return Divider(
              thickness: thickness,
              height: 0,
              color: Colors.black.withOpacity(thickness == 1 ? 1 : 0.5),
            );
          },
          itemCount: data.length),
    );
  }

  Widget _servicesStatistics() {
    if (ref.watch(provider).servicesTotals.isEmpty) {
      return _notFoundTitle(LocaleKeys.day_statistics_service_not_found.tr());
    }

    return CustomPieChart(
        title: LocaleKeys.day_statistics_service_statistics.tr(),
        data: ref.watch(provider).servicesTotals);
  }

  Widget _expensesStatistics() {
    if (ref.watch(provider).expenseCategoryTotals.isEmpty) {
      return _notFoundTitle(LocaleKeys.commons_expense_category_not_found.tr());
    }
    return CustomPieChart(
        title: LocaleKeys.day_statistics_expense_category_statistics.tr(),
        data: ref.watch(provider).expenseCategoryTotals);
  }

  Widget _notFoundTitle(String title) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          Text(title,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center),
          const Divider()
        ],
      ),
    );
  }
}
