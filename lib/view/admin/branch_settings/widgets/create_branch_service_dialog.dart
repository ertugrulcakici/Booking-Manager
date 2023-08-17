part of "../branch_settings_view.dart";

class _CreateBranchServiceDialog extends ConsumerStatefulWidget {
  final String branchUid;
  final BranchServiceModel? service;
  // ignore: unused_element
  const _CreateBranchServiceDialog({required this.branchUid, this.service});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateBranchServiceDialogState();
}

class _CreateBranchServiceDialogState
    extends ConsumerState<_CreateBranchServiceDialog> {
  final TextEditingController _serviceNumberController =
      TextEditingController();
  final TextEditingController _servicePriceController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.service != null) {
      _serviceNumberController.text = widget.service!.name;
      _servicePriceController.text = widget.service!.price.toStringAsFixed(2);
    }
    super.initState();
  }

  @override
  void dispose() {
    _serviceNumberController.dispose();
    _servicePriceController.dispose();
    _formKey.currentState?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.service == null
          ? LocaleKeys.commons_add_service.tr()
          : LocaleKeys.create_branch_service_dialog_edit_service.tr()),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _serviceNumberController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                  labelText: LocaleKeys
                      .create_branch_service_dialog_service_name_label
                      .tr()),
              validator: (value) {
                if (value == null || value.isEmpty || value.trim().isEmpty) {
                  return LocaleKeys.commons_non_empty_field_error.tr();
                }
                return null;
              },
            ),
            TextFormField(
              controller: _servicePriceController,
              textInputAction: TextInputAction.next,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: false),
              decoration: InputDecoration(
                  labelText: LocaleKeys
                      .create_branch_service_dialog_service_price_label
                      .tr()),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocaleKeys.commons_non_empty_field_error.tr();
                }
                if (num.tryParse(value.replaceAll(",", ".")) == null) {
                  return LocaleKeys.commons_enter_valid_number.tr();
                }
                return null;
              },
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
          onPressed: _setService,
          icon: const Icon(Icons.add),
          label: Text(LocaleKeys.general_add.tr()),
        ),
      ],
    );
  }

  void _setService() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      await PopupHelper.showLoadingWhile(() async => await ref
          .read(ProviderManager.branchManagerProvider)
          .setBranchServiceToBranch(
            branchUid: widget.branchUid,
            serviceName: _serviceNumberController.text,
            servicePrice: num.parse(
                _servicePriceController.text.replaceAll(",", ".").trim()),
            serviceUid: widget.service?.uid,
          ));
      await PopupHelper.showAnimatedInfoDialog(
              title: widget.service == null
                  ? LocaleKeys
                      .create_branch_service_dialog_service_added_successfully
                      .tr()
                  : LocaleKeys
                      .create_branch_service_dialog_service_updated_successfully
                      .tr(),
              isSuccessful: true)
          .then((value) => Navigator.of(context).pop());
    } catch (e) {
      await PopupHelper.showAnimatedInfoDialog(
          title: e.toString(), isSuccessful: false);
    }
  }
}
