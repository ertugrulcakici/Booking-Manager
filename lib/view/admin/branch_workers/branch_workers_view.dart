import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/navigation/navigation_service.dart';
import '../../../core/utils/popup_helper.dart';
import '../../../product/models/branch_model.dart';
import '../../../product/models/user_model.dart';
import '../../../product/providers/provider_manager.dart';

part "widgets/add_worker_dialog.dart";

@immutable
class BranchWorkersView extends ConsumerStatefulWidget {
  final String branchUid;
  const BranchWorkersView({super.key, required this.branchUid});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BranchWorkersState();
}

class _BranchWorkersState extends ConsumerState<BranchWorkersView> {
  BranchModel get _branch => ref
      .watch(ProviderManager.branchManagerProvider)
      .getBranch(widget.branchUid)!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(LocaleKeys.branch_workers_view_branch_workers
              .tr(args: [_branch.name]))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) =>
                  _AddWorkerDialog(branchUid: widget.branchUid));
        },
        child: const Icon(Icons.add),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_branch.workersUids.isEmpty) {
      return Center(
          child: Text(LocaleKeys.branch_workers_view_worker_not_found.tr()));
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _branch.workersUids.length,
      itemBuilder: (context, index) {
        return _userItemTile(index);
      },
    );
  }

  FutureBuilder<UserModel> _userItemTile(int index) {
    return FutureBuilder<UserModel>(
      future: ref.watch(ProviderManager.branchManagerProvider).getUser(
          branchUid: widget.branchUid, userUid: _branch.workersUids[index]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final UserModel worker = snapshot.data!;
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(worker.displayName),
            trailing: InkWell(
                onTap: () async {
                  PopupHelper.showOkCancelDialog(
                      title: LocaleKeys.branch_workers_view_delete_worker_title
                          .tr(),
                      content: "",
                      onOk: () async {
                        try {
                          await PopupHelper.showLoadingWhile(() async =>
                              await ref
                                  .read(ProviderManager.branchManagerProvider)
                                  .deleteWorkerFromBranch(
                                      branchUid: widget.branchUid,
                                      userUid: worker.uid));
                          PopupHelper.showAnimatedInfoDialog(
                              title: LocaleKeys
                                  .branch_workers_view_user_deleted_successfully
                                  .tr(),
                              isSuccessful: true);
                        } catch (e) {
                          PopupHelper.showAnimatedInfoDialog(
                              title: LocaleKeys
                                  .branch_workers_view_user_delete_error
                                  .tr(),
                              isSuccessful: false);
                        }
                      });
                },
                child: const Icon(Icons.delete)),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
