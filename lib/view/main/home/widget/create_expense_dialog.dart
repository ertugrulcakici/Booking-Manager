part of "../home_view.dart";

class _CreateExpenseDialog extends ConsumerStatefulWidget {
  final BranchModel branch;
  const _CreateExpenseDialog({required this.branch, Key? key})
      : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateExpenseDialogState();
}

class _CreateExpenseDialogState extends ConsumerState<_CreateExpenseDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  num? amount;
  String? description;

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocaleKeys.commons_add_expense.tr()),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
              validator: (value) {
                if (value == null) {
                  return LocaleKeys.create_expense_dialog_select_category.tr();
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              items: widget.branch.expenseCategories
                  .map((e) => DropdownMenuItem(
                        value: e.uid,
                        child: Row(
                          children: [
                            Text(e.name),
                            if (e.description != null &&
                                e.description!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                e.description!,
                                style: Theme.of(context).textTheme.bodySmall,
                              )
                            ]
                          ],
                        ),
                      ))
                  .toList(),
              hint: const Text("Kategori seçiniz"),
            )),
            TextFormField(
              decoration: InputDecoration(
                  hintText:
                      LocaleKeys.create_expense_dialog_expense_total.tr()),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: false),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocaleKeys.commons_enter_valid_number.tr();
                }
                try {
                  num.parse(value);
                } catch (e) {
                  return LocaleKeys.commons_enter_valid_number.tr();
                }
                return null;
              },
              onSaved: (value) {
                amount = num.parse(value!);
              },
            ),
            TextFormField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    hintText: LocaleKeys.create_expense_dialog_note.tr()),
                maxLines: 3,
                onSaved: (value) {
                  description = value;
                })
          ],
        ),
      ),
      actions: [
        TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.cancel),
            label: Text(LocaleKeys.general_cancel.tr())),
        TextButton.icon(
            onPressed: _createExpense,
            icon: const Icon(Icons.save),
            label: Text(LocaleKeys.general_save.tr())),
      ],
    );
  }

  Future<void> _createExpense() async {
    {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        try {
          await PopupHelper.showLoadingWhile(() async => ref
              .read(ProviderManager.branchManagerProvider)
              .createExpense(
                  amount: amount!,
                  branchUid: widget.branch.uid,
                  categoryUid: selectedCategory!,
                  description: description!));
          PopupHelper.showAnimatedInfoDialog(
                  title: LocaleKeys.create_expense_dialog_expense_added.tr(),
                  isSuccessful: true)
              .then((value) {
            Navigator.pop(context);
          });
        } catch (e) {
          PopupHelper.showAnimatedInfoDialog(
              title: LocaleKeys.create_expense_dialog_expense_addition_error
                  .tr(args: [e.toString()]),
              isSuccessful: false);
        }
      }
    }
  }
}
