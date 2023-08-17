part of '../home_view.dart';

class _HomeDrawer extends ConsumerStatefulWidget {
  const _HomeDrawer();
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => __HomeDrawerState();
}

class __HomeDrawerState extends ConsumerState<_HomeDrawer> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top,
          bottom: MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _header(),
                _branches(),
              ],
            ),
            _bottomOptions()
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Column(children: [
      Center(
          child: Text(
        LocaleKeys.home_drawer_branches.tr(),
        style: Theme.of(context).textTheme.headlineLarge,
      )),
      const Divider()
    ]);
  }

  Widget _branches() {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: List.generate(
                ref
                    .watch(ProviderManager.branchManagerProvider)
                    .branches
                    .length, (index) {
              List<BranchModel> branches =
                  ref.watch(ProviderManager.branchManagerProvider).branches;
              return branches[index].ownerUid ==
                      AuthService.instance.userModel!.uid
                  ? _adminItem(branch: branches[index])
                  : _workerItem(branch: branches[index]);
            }),
          ),
        ),
      ),
    );
  }

  Widget _bottomOptions() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text(LocaleKeys.home_drawer_settings_label.tr()),
          onTap: () => NavigationService.toPage(const SettingsView()),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(LocaleKeys.home_drawer_profile_label.tr()),
          onTap: () {
            NavigationService.toPage(const ProfileView());
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(LocaleKeys.home_drawer_logout_label.tr()),
          onTap: () async {
            await AuthService.instance.signOut();
          },
        ),
      ],
    );
  }

  Widget _adminItem({required BranchModel branch}) {
    return ExpansionTile(
      title: Text(branch.name),
      leading: const Icon(Icons.business),
      children: [
        if (branch.ownerUid == AuthService.instance.userModel!.uid)
          ListTile(
            title: Text(LocaleKeys.home_drawer_general_branch_settings.tr()),
            leading: const Icon(Icons.settings),
            onTap: () {
              NavigationService.toPage(
                  BranchSettingsView(branchUid: branch.uid));
            },
          ),

        if (branch.ownerUid == AuthService.instance.userModel!.uid)
          ListTile(
            title: Text(LocaleKeys.home_drawer_workers.tr()),
            leading: const Icon(Icons.people),
            onTap: () {
              NavigationService.toPage(
                  BranchWorkersView(branchUid: branch.uid));
            },
          ),

        // if (branch.ownerUid == AuthService.instance.userModel!.uid)
        //   ListTile(
        //     title: const Text("İstatistikler"),
        //     leading: const Icon(Icons.bar_chart),
        //     onTap: () {
        //       NavigationService.toPage(
        //           BranchStatisticsView(branchUid: branch.uid));
        //     },
        //   ),

        ListTile(
          title: Text(LocaleKeys.home_drawer_expenses.tr()),
          leading: const Icon(Icons.money),
          onTap: () {
            NavigationService.toPage(BranchExpensesView(branchUid: branch.uid));
          },
        ),
        ListTile(
          title: Text(LocaleKeys.commons_add_expense.tr()),
          leading: const Icon(Icons.add),
          onTap: () {
            if (branch.expenseCategories.isEmpty) {
              PopupHelper.showAnimatedInfoDialog(
                  title: LocaleKeys.commons_expense_category_not_found.tr(),
                  isSuccessful: false);
              return;
            }
            showDialog(
                context: context,
                builder: (context) {
                  return _CreateExpenseDialog(branch: branch);
                });
          },
        )
      ],
    );
  }

  Widget _workerItem({
    required BranchModel branch,
  }) {
    return ExpansionTile(
      title: Text(branch.name),
      leading: const Icon(Icons.business),
      children: [
        ListTile(
          title: Text(LocaleKeys.commons_add_expense.tr()),
          leading: const Icon(Icons.add),
          onTap: () {
            if (branch.expenseCategories.isEmpty) {
              PopupHelper.showAnimatedInfoDialog(
                  title: LocaleKeys.commons_expense_category_not_found.tr(),
                  isSuccessful: false);
              return;
            }
            showDialog(
                context: context,
                builder: (context) {
                  return _CreateExpenseDialog(branch: branch);
                });
          },
        ),
        ListTile(
          title: Text(LocaleKeys.home_drawer_leave_branch_label.tr()),
          leading: const Icon(Icons.logout),
          onTap: () {
            PopupHelper.showOkCancelDialog(
                title: LocaleKeys.general_attention.tr(),
                content: LocaleKeys.home_drawer_leave_branch_warning.tr(),
                onOk: () async {
                  try {
                    await PopupHelper.showLoadingWhile(() async => await ref
                        .read(ProviderManager.branchManagerProvider)
                        .leaveBranch(branch.uid));

                    PopupHelper.showAnimatedInfoDialog(
                        title:
                            LocaleKeys.home_drawer_leave_branch_successful.tr(),
                        isSuccessful: true);
                  } catch (e) {
                    PopupHelper.showAnimatedInfoDialog(
                        // title: "İş yerinden ayrılırken bir hata oluştu: $e",
                        title: LocaleKeys.home_drawer_leave_branch_error.tr(),
                        isSuccessful: false);
                  }
                });
          },
        ),
      ],
    );
  }
}
