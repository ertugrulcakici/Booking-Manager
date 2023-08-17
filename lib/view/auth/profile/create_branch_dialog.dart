part of "profile_view.dart";

class _CreateBranchDialog extends ConsumerStatefulWidget {
  const _CreateBranchDialog();
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateBranchDialogState();
}

class _CreateBranchDialogState extends ConsumerState<_CreateBranchDialog> {
  final _formKey = GlobalKey<FormState>();
  String _branchName = "";

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty || value.trim().isEmpty) {
              return LocaleKeys.commons_non_empty_field_error.tr();
            }
            return null;
          },
          decoration: InputDecoration(
              labelText:
                  LocaleKeys.create_branch_dialog_branch_name_label.tr()),
          onSaved: (value) {
            _branchName = value!;
          },
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(LocaleKeys.general_cancel.tr())),
        TextButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                _formKey.currentState!.save();
                _branchName = _branchName.trim();
                try {
                  await ref
                      .read(ProviderManager.branchManagerProvider)
                      .createBranch(_branchName);
                  PopupHelper.showAnimatedInfoDialog(
                          title: LocaleKeys
                              .create_branch_dialog_branch_created_successfully
                              .tr(),
                          isSuccessful: true)
                      .then((value) {
                    Navigator.pop(context);
                  });
                } catch (e) {
                  PopupHelper.showAnimatedInfoDialog(
                      title: LocaleKeys
                          .create_branch_dialog_branch_creation_failed
                          .tr(),
                      isSuccessful: false);
                }
                // Navigator.pop(context);
              }
            },
            child: Text(LocaleKeys.create_branch_dialog_create.tr())),
      ],
      title: Text(LocaleKeys.create_branch_dialog_creating_a_new_branch.tr()),
    );
  }
}
