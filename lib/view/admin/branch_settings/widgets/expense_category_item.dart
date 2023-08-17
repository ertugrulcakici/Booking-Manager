part of '../branch_settings_view.dart';

class _ExpenseCategoryItem extends StatelessWidget {
  final ExpenseCategoryModel expenseCategory;
  final String branchUid;
  const _ExpenseCategoryItem(
      {required this.expenseCategory, required this.branchUid});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(expenseCategory.name),
        subtitle: expenseCategory.description != null &&
                expenseCategory.description!.isNotEmpty
            ? Text(expenseCategory.description!)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                onPressed: () {
                  PopupHelper.showOkCancelDialog(
                      title: LocaleKeys
                          .expanse_category_item_delete_expense_category_title
                          .tr(),
                      content: LocaleKeys
                          .expanse_category_item_delete_expense_category_content
                          .tr(),
                      onOk: () async {
                        try {
                          await ProviderManager.ref
                              .read(ProviderManager.branchManagerProvider)
                              .deleteExpenseCategory(
                                categoryUid: expenseCategory.uid,
                                branchUid: branchUid,
                              );
                          await PopupHelper.showAnimatedInfoDialog(
                              title: LocaleKeys
                                  .expanse_category_item_expense_category_deleted_successfully
                                  .tr(),
                              isSuccessful: true);
                        } catch (e) {
                          PopupHelper.showAnimatedInfoDialog(
                              title: e.toString(), isSuccessful: false);
                        }
                      });
                },
                icon: const Icon(Icons.delete))
          ],
        ),
      ),
    );
  }
}
