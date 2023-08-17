import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../product/models/branch_model.dart';
import '../../../product/providers/provider_manager.dart';

class BranchStatisticsView extends ConsumerStatefulWidget {
  final String branchUid;
  const BranchStatisticsView({super.key, required this.branchUid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BranchStatisticsViewState();
}

class _BranchStatisticsViewState extends ConsumerState<BranchStatisticsView> {
  BranchModel get _branch => ref
      .watch(ProviderManager.branchManagerProvider)
      .getBranch(widget.branchUid)!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Statistics of ${_branch.name}"),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        Text("Statistics of ${_branch.name}"),
      ],
    );
  }
}
