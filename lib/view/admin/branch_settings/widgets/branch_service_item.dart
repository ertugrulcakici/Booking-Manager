part of '../branch_settings_view.dart';

@immutable
class _BranchServiceItem extends StatelessWidget {
  final BranchServiceModel branchService;
  final String branchUid;
  const _BranchServiceItem(
      {required this.branchService, required this.branchUid});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(branchService.name),
        subtitle: Text(branchService.price.toStringAsFixed(2)),
        trailing: IconButton(
            onPressed: () {
              PopupHelper.showOkCancelDialog(
                  title:
                      LocaleKeys.branch_service_item_delete_service_title.tr(),
                  content: LocaleKeys.branch_service_item_delete_service_content
                      .tr(),
                  onOk: () async {
                    try {
                      await PopupHelper.showLoadingWhile(() async =>
                          await ProviderManager.ref
                              .read(ProviderManager.branchManagerProvider)
                              .deleteBranchService(
                                serviceUid: branchService.uid,
                                branchUid: branchUid,
                              ));
                      await PopupHelper.showAnimatedInfoDialog(
                          title: LocaleKeys
                              .branch_service_item_service_deleted_successfully
                              .tr(),
                          isSuccessful: true);
                    } catch (e) {
                      PopupHelper.showAnimatedInfoDialog(
                          title: e.toString(), isSuccessful: false);
                    }
                  });
            },
            icon: const Icon(Icons.delete)),
      ),
    );
  }
}
