part of "../branch_settings_view.dart";

class _CreateExpenseCategoryDialog extends ConsumerStatefulWidget {
  final String branchUid;
  final ExpenseCategoryModel? category;
  // ignore: unused_element
  const _CreateExpenseCategoryDialog({required this.branchUid, this.category});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateExpenseCategoryDialogState();
}

class _CreateExpenseCategoryDialogState
    extends ConsumerState<_CreateExpenseCategoryDialog> {
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _categoryDescriptionController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.category != null) {
      _categoryNameController.text = widget.category!.name;
    }
    super.initState();
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _categoryDescriptionController.dispose();
    _formKey.currentState?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null
          ? LocaleKeys.commons_add_expense_category.tr()
          : LocaleKeys.create_expense_category_dialog_edit_expense_category
              .tr()),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _categoryNameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                  labelText: LocaleKeys
                      .create_expense_category_dialog_category_name_label
                      .tr()),
              validator: (value) {
                if (value == null || value.isEmpty || value.trim().isEmpty) {
                  return LocaleKeys.commons_non_empty_field_error.tr();
                }
                return null;
              },
            ),
            TextFormField(
              controller: _categoryDescriptionController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                  labelText: LocaleKeys
                      .create_expense_category_dialog_category_description_label
                      .tr(),
                  hintText: LocaleKeys
                      .create_expense_category_dialog_category_description_hint
                      .tr()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.cancel),
          label: Text(LocaleKeys.general_cancel.tr()),
        ),
        TextButton.icon(
          onPressed: _setExpenseCategory,
          icon: const Icon(Icons.add),
          label: Text(LocaleKeys.general_add.tr()),
        ),
      ],
    );
  }

  void _setExpenseCategory() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      await PopupHelper.showLoadingWhile(() async => await ref
          .read(ProviderManager.branchManagerProvider)
          .setExpenseCategory(
            branchUid: widget.branchUid,
            categoryUid: widget.category?.uid,
            categoryName: _categoryNameController.text,
            categoryDescription: _categoryDescriptionController.text.isEmpty
                ? null
                : _categoryDescriptionController.text,
          ));
      await PopupHelper.showAnimatedInfoDialog(
          title: widget.category == null
              ? LocaleKeys
                  .create_expense_category_dialog_expense_category_added_successfully
                  .tr()
              : LocaleKeys
                  .create_expense_category_dialog_expense_category_updated_successfully
                  .tr(),
          isSuccessful: true);
      NavigationService.back();
    } catch (e) {
      await PopupHelper.showAnimatedInfoDialog(
          title: e.toString(), isSuccessful: false);
    }
  }
}
