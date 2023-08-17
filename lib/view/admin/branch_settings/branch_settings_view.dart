import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:bookingmanager/view/main/home/home_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/navigation/navigation_service.dart';
import '../../../core/utils/popup_helper.dart';
import '../../../product/models/branch_model.dart';
import '../../../product/models/branch_service_model.dart';
import '../../../product/models/expense_category_model.dart';
import '../../../product/providers/provider_manager.dart';

part 'widgets/branch_service_item.dart';
part 'widgets/create_branch_service_dialog.dart';
part 'widgets/create_expense_category_dialog.dart';
part 'widgets/expense_category_item.dart';

@immutable
class BranchSettingsView extends ConsumerStatefulWidget {
  final String branchUid;
  const BranchSettingsView({super.key, required this.branchUid});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BranchSettingsViewState();
}

class _BranchSettingsViewState extends ConsumerState<BranchSettingsView> {
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _personCountController;
  late final TextEditingController _startHourController;
  late final TextEditingController _endHourController;

  // these values works like a bucket to store previous values to prevent unnecessary rebuilds
  String _pricePrevious = "";
  String _durationPrevious = "";
  String _personCountPrevious = "";
  String _startHourPrevious = "";
  String _endHourPrevious = "";

  BranchModel get branch => ref
      .watch(ProviderManager.branchManagerProvider)
      .getBranch(widget.branchUid)!;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final branch = ref
        .read(ProviderManager.branchManagerProvider)
        .getBranch(widget.branchUid)!;
    _priceController =
        TextEditingController(text: branch.pricePerPerson.toStringAsFixed(2));
    _durationController =
        TextEditingController(text: branch.defaultDurationInMinute.toString());
    _personCountController =
        TextEditingController(text: branch.defaultPersonCount.toString());
    _startHourController =
        TextEditingController(text: branch.startHour.toString());
    _endHourController = TextEditingController(text: branch.endHour.toString());
    _pricePrevious = _priceController.text;
    _durationPrevious = _durationController.text;
    _personCountPrevious = _personCountController.text;
    _startHourPrevious = _startHourController.text;
    _endHourPrevious = _endHourController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Theme(
                data: ThemeData(
                    expansionTileTheme: const ExpansionTileThemeData(
                  iconColor: Colors.black,
                  backgroundColor: Colors.white,
                  tilePadding: EdgeInsets.all(10),
                )),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _pricePerPersonTextField(),
                    _defaultDurationTextField(),
                    _defaultPersonCountTextField(),
                    _startHourTextField(),
                    _endHourTextField(),
                    _branchServices(),
                    _expenseCategories(),
                  ],
                ),
              ),
            ),
            _deleteBranchButton()
          ],
        ),
      ),
    );
  }

  Center _deleteBranchButton() {
    return Center(
      child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.all(10),
            minimumSize: const Size(0.8, 0.05),
            foregroundColor: Colors.white,
          ),
          onPressed: _deleteBranch,
          icon: const Icon(Icons.delete),
          label: Text(LocaleKeys.branch_settings_view_delete_branch.tr())),
    );
  }

  ExpansionTile _expenseCategories() {
    return ExpansionTile(
        title: Text(LocaleKeys.branch_settings_view_expense_categories.tr()),
        children: [
          Card(
            color: Colors.green[200],
            child: ListTile(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) =>
                        _CreateExpenseCategoryDialog(branchUid: branch.uid));
              },
              title: Text(LocaleKeys.commons_add_expense_category.tr()),
              trailing: const Icon(Icons.add),
            ),
          ),
          ...List.generate(
              branch.expenseCategories.length,
              (index) => _ExpenseCategoryItem(
                  branchUid: branch.uid,
                  expenseCategory: branch.expenseCategories[index])),
        ]);
  }

  ExpansionTile _branchServices() {
    return ExpansionTile(
        title: Text(LocaleKeys.branch_settings_view_branch_services.tr()),
        children: [
          Card(
            color: Colors.green[200],
            child: ListTile(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) =>
                        _CreateBranchServiceDialog(branchUid: branch.uid));
              },
              title: Text(LocaleKeys.commons_add_service.tr()),
              trailing: const Icon(Icons.add),
            ),
          ),
          ...List.generate(
              branch.branchServices.length,
              (index) => _BranchServiceItem(
                  branchUid: branch.uid,
                  branchService: branch.branchServices[index])),
        ]);
  }

  Card _pricePerPersonTextField() {
    void submit([String? value]) async {
      value ??= _priceController.text.trim();
      if (_pricePrevious == value) {
        _unFocus();
        return;
      }
      _pricePrevious = value;
      final pricePerPerson = num.tryParse(value.replaceAll(",", ".").trim());
      if (pricePerPerson == null) {
        PopupHelper.showAnimatedInfoDialog(
            title: LocaleKeys.commons_enter_valid_number.tr(),
            isSuccessful: false);
        return;
      }

      try {
        BranchModel newBranch = branch.copyWith(pricePerPerson: pricePerPerson);
        await PopupHelper.showLoadingWhile(() async => await ref
            .read(ProviderManager.branchManagerProvider)
            .editBranch(newBranch));
        await PopupHelper.showAnimatedInfoDialog(
            title: LocaleKeys.branch_settings_view_person_price_updated.tr(),
            isSuccessful: true);
      } catch (e) {
        PopupHelper.showAnimatedInfoDialog(
            title: e.toString(), isSuccessful: false);
      } finally {
        _unFocus();
      }
    }

    return Card(
      child: TextField(
        controller: _priceController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: LocaleKeys.branch_settings_view_person_price_label.tr(),
          border: InputBorder.none,
          icon: const Icon(Icons.attach_money),
          suffixIcon:
              IconButton(onPressed: submit, icon: const Icon(Icons.check)),
        ),
        onSubmitted: submit,
      ),
    );
  }

  Card _defaultDurationTextField() {
    void submit([String? value]) async {
      value ??= _durationController.text.trim();
      if (_durationPrevious == value) {
        _unFocus();
        return;
      }
      _durationPrevious = value;
      final duration = int.tryParse(value.replaceAll(",", ".").trim());
      if (duration == null) {
        PopupHelper.showAnimatedInfoDialog(
            title: LocaleKeys.branch_settings_view_invalid_time.tr(),
            isSuccessful: false);
        return;
      }

      try {
        BranchModel newBranch =
            branch.copyWith(defaultDurationInMs: duration * 60 * 1000);
        await PopupHelper.showLoadingWhile(() async => await ref
            .read(ProviderManager.branchManagerProvider)
            .editBranch(newBranch));
        await PopupHelper.showAnimatedInfoDialog(
            title:
                LocaleKeys.branch_settings_view_default_duration_updated.tr(),
            isSuccessful: true);
      } catch (e) {
        PopupHelper.showAnimatedInfoDialog(
            title: e.toString(), isSuccessful: false);
      } finally {
        _unFocus();
      }
    }

    return Card(
      child: TextField(
        controller: _durationController,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        onSubmitted: submit,
        decoration: InputDecoration(
          labelText:
              LocaleKeys.branch_settings_view_default_duration_label.tr(),
          border: InputBorder.none,
          icon: const Icon(Icons.timer),
          suffixIcon:
              IconButton(onPressed: submit, icon: const Icon(Icons.check)),
        ),
      ),
    );
  }

  Card _defaultPersonCountTextField() {
    void submit([String? value]) async {
      value ??= _personCountController.text.trim();
      if (_personCountPrevious == value) {
        _unFocus();
        return;
      }
      _personCountPrevious = value;
      final personCount = int.tryParse(value.replaceAll(",", ".").trim());
      if (personCount == null) {
        PopupHelper.showAnimatedInfoDialog(
            title: LocaleKeys.commons_enter_valid_number.tr(),
            isSuccessful: false);
        return;
      }

      try {
        BranchModel newBranch =
            branch.copyWith(defaultPersonCount: personCount);
        await PopupHelper.showLoadingWhile(() async => await ref
            .read(ProviderManager.branchManagerProvider)
            .editBranch(newBranch));
        await PopupHelper.showAnimatedInfoDialog(
            title: LocaleKeys.branch_settings_view_default_person_count_updated
                .tr(),
            isSuccessful: true);
      } catch (e) {
        PopupHelper.showAnimatedInfoDialog(
            title: e.toString(), isSuccessful: false);
      } finally {
        _unFocus();
      }
    }

    return Card(
      child: TextField(
        controller: _personCountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        onSubmitted: submit,
        decoration: InputDecoration(
          labelText:
              LocaleKeys.branch_settings_view_default_person_count_label.tr(),
          border: InputBorder.none,
          icon: const Icon(Icons.person),
          suffixIcon:
              IconButton(onPressed: submit, icon: const Icon(Icons.check)),
        ),
      ),
    );
  }

  Card _startHourTextField() {
    void submit([String? value]) async {
      value ??= _startHourController.text.trim();
      if (_startHourPrevious == value) {
        _unFocus();
        return;
      }
      _startHourPrevious = value;
      int? startHour = int.tryParse(value.replaceAll(",", ".").trim());
      if (startHour == null) {
        PopupHelper.showAnimatedInfoDialog(
            title: LocaleKeys.branch_settings_view_invalid_time.tr(),
            isSuccessful: false);
        return;
      }
      try {
        BranchModel newBranch = branch.copyWith(startHour: startHour);
        await PopupHelper.showLoadingWhile(() async => await ref
            .read(ProviderManager.branchManagerProvider)
            .editBranch(newBranch));
        await PopupHelper.showAnimatedInfoDialog(
            title:
                LocaleKeys.branch_settings_view_default_start_hour_updated.tr(),
            isSuccessful: true);
      } catch (e) {
        PopupHelper.showAnimatedInfoDialog(
            title: e.toString(), isSuccessful: false);
      } finally {
        _unFocus();
      }
    }

    return Card(
      child: TextField(
        controller: _startHourController,
        keyboardType: TextInputType.number,
        onSubmitted: submit,
        decoration: InputDecoration(
          labelText:
              LocaleKeys.branch_settings_view_default_start_hour_label.tr(),
          border: InputBorder.none,
          icon: const Icon(Icons.timer),
          suffixIcon:
              IconButton(onPressed: submit, icon: const Icon(Icons.check)),
        ),
      ),
    );
  }

  Card _endHourTextField() {
    void submit([String? value]) async {
      value ??= _endHourController.text.trim();
      if (_endHourPrevious == value) {
        _unFocus();
        return;
      }
      _endHourPrevious = value;
      int? endHour = int.tryParse(value.replaceAll(",", ".").trim());
      if (endHour == null) {
        PopupHelper.showAnimatedInfoDialog(
            title: LocaleKeys.branch_settings_view_invalid_time.tr(),
            isSuccessful: false);
        return;
      }
      try {
        BranchModel newBranch = branch.copyWith(endHour: endHour);
        await PopupHelper.showLoadingWhile(() async => await ref
            .read(ProviderManager.branchManagerProvider)
            .editBranch(newBranch));
        await PopupHelper.showAnimatedInfoDialog(
            title:
                LocaleKeys.branch_settings_view_default_end_hour_updated.tr(),
            isSuccessful: true);
      } catch (e) {
        PopupHelper.showAnimatedInfoDialog(
            title: e.toString(), isSuccessful: false);
      } finally {
        _unFocus();
      }
    }

    return Card(
      child: TextField(
        controller: _endHourController,
        keyboardType: TextInputType.number,
        onSubmitted: submit,
        decoration: InputDecoration(
          labelText:
              LocaleKeys.branch_settings_view_default_end_hour_label.tr(),
          border: InputBorder.none,
          icon: const Icon(Icons.timer),
          suffixIcon:
              IconButton(onPressed: submit, icon: const Icon(Icons.check)),
        ),
      ),
    );
  }

  void _deleteBranch() async {
    PopupHelper.showOkCancelDialog(
        title: LocaleKeys.general_attention.tr(),
        content: LocaleKeys.branch_settings_view_delete_branch_content.tr(),
        onOk: () {
          try {
            PopupHelper.showLoadingWhile(() async => await ref
                .read(ProviderManager.branchManagerProvider)
                .deleteBranch(branch)).then((value) {
              NavigationService.toPageAndRemoveUntil(const HomeView());
            });
          } catch (e) {
            PopupHelper.showAnimatedInfoDialog(
                title: e.toString(), isSuccessful: false);
          }
        });
  }

  Future<void> _unFocus() {
    return Future.delayed(
        const Duration(seconds: 1), () => FocusScope.of(context).unfocus());
  }

  PreferredSizeWidget _appBar() {
    return AppBar(title: Text(branch.name));
  }
}
