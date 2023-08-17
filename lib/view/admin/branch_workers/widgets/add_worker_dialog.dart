part of "../branch_workers_view.dart";

class _AddWorkerDialog extends ConsumerStatefulWidget {
  final String branchUid;
  const _AddWorkerDialog({required this.branchUid});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddWorkerDialogState();
}

class _AddWorkerDialogState extends ConsumerState<_AddWorkerDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocaleKeys.add_workers_dialog_add_worker_title.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autocorrect: false,
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                labelText:
                    LocaleKeys.add_workers_dialog_worker_mail_label.tr()),
            onSubmitted: (_) => _addWorker(),
          ),
        ],
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
          onPressed: _addWorker,
          icon: const Icon(Icons.add),
          label: Text(LocaleKeys.general_add.tr()),
        ),
      ],
    );
  }

  void _addWorker() async {
    try {
      await PopupHelper.showLoadingWhile(() async => await ref
          .read(ProviderManager.branchManagerProvider)
          .addWorkerToBranch(
              branchUid: widget.branchUid, userMail: _controller.text));
      NavigationService.back();
    } catch (e) {
      await PopupHelper.showAnimatedInfoDialog(
          title: e.toString(), isSuccessful: false);
    }
  }
}
