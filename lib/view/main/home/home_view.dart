import 'dart:developer';

import 'package:bookingmanager/core/extensions/date_and_time_extensions.dart';
import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:bookingmanager/core/utils/popup_helper.dart';
import 'package:bookingmanager/product/models/session_model.dart';
import 'package:bookingmanager/product/models/user_model.dart';
import 'package:bookingmanager/product/providers/provider_manager.dart';
import 'package:bookingmanager/view/main/day_statistics/day_statistics_view.dart';
import 'package:bookingmanager/view/main/home/home_notifier.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../core/services/firebase/auth/auth_service.dart';
import '../../../core/services/navigation/navigation_service.dart';
import '../../../product/models/branch_model.dart';
import '../../../product/widgets/profile_picture_widget.dart';
import '../../admin/branch_expenses/branch_expenses_view.dart';
import '../../admin/branch_settings/branch_settings_view.dart';
import '../../admin/branch_workers/branch_workers_view.dart';
import '../../auth/profile/profile_view.dart';
import '../../settings/settings_view.dart';

part 'widget/create_expense_dialog.dart';
part 'widget/home_drawer.dart';
part 'widget/set_session_dialog.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final AutoDisposeChangeNotifierProvider<HomeNotifier> _homeProvider =
      ChangeNotifierProvider.autoDispose<HomeNotifier>((ref) => HomeNotifier());

  bool listenersStarted = false;
  @override
  void initState() {
    startListeners();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _fab(),
      appBar: _appBar(),
      drawer: const _HomeDrawer(),
      body: _body(),
    );
  }

  AppBar? _appBar() {
    // if (ref.watch(_homeProvider).isLoading) {
    //   return null;
    // }

    List<Widget> actions = [];
    if (ref.watch(_homeProvider).selectedBranch != null) {
      // actions.add(IconButton(
      //     onPressed: () {}, icon: const Icon(Icons.filter_alt_outlined)));

      if (AuthService.instance.userModel!.uid ==
          ref.watch(_homeProvider).selectedBranch?.ownerUid) {
        actions.add(IconButton(
            onPressed: () {
              NavigationService.toPage(DayStatisticsView(
                  selectedDate: ref.watch(_homeProvider).selectedDate,
                  branchModel: ref.watch(_homeProvider).selectedBranch!));
            },
            icon: const Icon(Icons.bar_chart)));
      }
    }

    return AppBar(
        centerTitle: true,
        actions: actions,
        title: DropdownButtonHideUnderline(
            child: DropdownButton<BranchModel>(
          isExpanded: true,
          alignment: Alignment.center,
          hint: Center(child: Text(LocaleKeys.home_branches_empty.tr())),
          value: ref.watch(_homeProvider).selectedBranch,
          onChanged: (value) {
            if (value == null) return;
            if (value.uid == ref.read(_homeProvider).selectedBranch?.uid) {
              return;
            }
            ref.read(_homeProvider).selectedBranch = value;
          },
          items: ref
              .watch(ProviderManager.branchManagerProvider)
              .branches
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.name, textAlign: TextAlign.center),
                  ))
              .toList(),
        )));
  }

  Widget _body() {
    if (AuthService.instance.userModel!.workersOf.isEmpty &&
        AuthService.instance.userModel!.ownersOf.isEmpty) {
      return Center(
          child: Text(LocaleKeys.home_create_branch_instruction.tr()));
    }
    if (ref.watch(_homeProvider).isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ref.watch(_homeProvider).selectedBranch == null) {
      return Center(
          child: Text(LocaleKeys.home_create_branch_instruction.tr(),
              textAlign: TextAlign.center));
    }
    return SfCalendar(
      allowViewNavigation: true,
      showTodayButton: true,
      showNavigationArrow: true,
      showDatePickerButton: true,
      loadMoreWidgetBuilder: (context, date) {
        if (ref.watch(ProviderManager.sessionsFetching)) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const SizedBox();
        }
      },
      timeSlotViewSettings: TimeSlotViewSettings(
        timeIntervalHeight: ref.watch(_homeProvider).timeIntervalHeight,
        timeInterval: Duration(
            minutes: ref
                .watch(_homeProvider)
                .selectedBranch!
                .defaultDurationInMinute),
        timeFormat: 'HH:mm',
        startHour:
            ref.watch(_homeProvider).selectedBranch!.startHour.toDouble(),
        endHour: ref.watch(_homeProvider).selectedBranch!.endHour.toDouble(),
      ),
      dataSource: ref.watch(_homeProvider).sessionSource,
      view: CalendarView.day,
      initialSelectedDate: ref.watch(_homeProvider).selectedDate.dayBeginning,
      initialDisplayDate: ref.watch(_homeProvider).selectedDate.dayBeginning,
      onDragStart: (appointmentDragStartDetails) {
        final session = ref
            .watch(_homeProvider)
            .sessionSource
            .sessions
            .firstWhere((element) =>
                element.uid ==
                (appointmentDragStartDetails.appointment as Appointment).id);
        ref.read(_homeProvider).draggingSession = session;
      },
      onDragEnd: (appointmentDragEndDetails) async {
        SessionModel newSession = ref
            .watch(_homeProvider)
            .draggingSession!
            .copyWith(
              startTime: (appointmentDragEndDetails.appointment as Appointment)
                  .startTime,
              endTime: (appointmentDragEndDetails.appointment as Appointment)
                  .endTime,
              lastModifiedByUid: AuthService.instance.userModel!.uid,
            );
        try {
          await PopupHelper.showLoadingWhile(() async => await ref
              .read(ProviderManager.sessionManagerProvider.notifier)
              .updateSession(newSession));
          PopupHelper.showAnimatedInfoDialog(
              title: LocaleKeys.home_session_updated.tr(), isSuccessful: true);
        } catch (e) {
          PopupHelper.showAnimatedInfoDialog(
              title: e.toString(), isSuccessful: false);
        } finally {
          ref.read(_homeProvider).draggingSession = null;
        }
      },
      onTap: (calendarTapDetails) {
        if (calendarTapDetails.date != null) {
          ref.read(_homeProvider).selectedTime = calendarTapDetails.date!;
        }
        if (calendarTapDetails.appointments?.isNotEmpty ?? false) {
          _showSetSessionDialog(ref
              .watch(_homeProvider)
              .sessionSource
              .sessions
              .firstWhere((element) =>
                  element.uid ==
                  (calendarTapDetails.appointments!.first as Appointment).id));
        }
      },
      onViewChanged: (viewChangedDetails) {
        final visibleDate = viewChangedDetails.visibleDates.first;
        ref.read(_homeProvider).selectedDate = visibleDate;
      },
      allowDragAndDrop: true,
      dragAndDropSettings:
          const DragAndDropSettings(allowNavigation: true, allowScroll: true),
    );
  }

  void _showSetSessionDialog([SessionModel? session]) async {
    showModalBottomSheet(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return _SetSessionDialog(
              provider: _homeProvider,
              session: session,
              selectedTime: ref.watch(_homeProvider).selectedTime,
              branch: ref.watch(_homeProvider).selectedBranch!);
        });
  }

  Widget? _fab() {
    if (ref.watch(_homeProvider).selectedBranch != null) {
      return FloatingActionButton(
        onPressed: () => _showSetSessionDialog(),
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  void startListeners() {
    if (listenersStarted) {
      return;
    }
    listenersStarted = true;
    ref.listenManual(ProviderManager.sessionManagerProvider, (previous, next) {
      ref
          .read(_homeProvider)
          .reFillSessions(ref.read(ProviderManager.sessionManagerProvider));
    });

    ref.listenManual(ProviderManager.branchManagerProvider, (previous, next) {
      if (next.branches.isEmpty) {
        ref.read(_homeProvider).selectedBranch = null;
      } else {
        ref.read(_homeProvider).selectedBranch = next.branches.first;
      }
      ref.read(_homeProvider).isLoading = false;
    });

    // AuthService.instance.userDocStream!
    //     .asBroadcastStream()
    //     .listen((event) async {
    //   try {
    //     ref.read(_homeProvider).isLoading = true;
    //     await ProviderManager.branchManager.toggleListener();
    //   } finally {
    //     ref.read(_homeProvider).isLoading = false;
    //   }
    // });
  }
}
