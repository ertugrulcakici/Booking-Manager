import 'package:bookingmanager/core/extensions/date_and_time_extensions.dart';
import 'package:bookingmanager/product/mixins/loading_notifier_mixin.dart';
import 'package:flutter/material.dart';

import '../../../product/models/branch_model.dart';
import '../../../product/models/session_model.dart';
import '../../../product/providers/provider_manager.dart';
import 'model/calendar_session_source.dart';

part 'services/calendar_manager.dart';

class HomeNotifier extends ChangeNotifier
    with _CalendarManager, LoadingNotifierMixin {
  BranchModel? _selectedBranch;
  BranchModel? get selectedBranch => _selectedBranch;
  set selectedBranch(BranchModel? value) {
    _selectedBranch = value;
    if (_selectedBranch != null) {
      ProviderManager.ref
          .read(ProviderManager.sessionManagerProvider.notifier)
          .toggleListener(
              dayBeginning: _selectedDate.dayBeginning,
              dayEnding: _selectedDate.dayEnding,
              branchUid: _selectedBranch!.uid);
    }
    notifyListeners();
  }

  SessionModel? _draggingSession;
  SessionModel? get draggingSession => _draggingSession;
  set draggingSession(SessionModel? value) {
    _draggingSession = value;
    notifyListeners();
  }

  // this will be renewed depends on feedbacks
  double get timeIntervalHeight => 150;
  // ((selectedBranch!.endHour - selectedBranch!.startHour) *
  //             60 /
  //             selectedBranch!.defaultDurationInMinute) >
  //         30
  //     ? 100
  //     : 150;

  HomeNotifier();

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  set selectedDate(DateTime value) {
    _selectedDate = value;

    ProviderManager.ref
        .read(ProviderManager.sessionManagerProvider.notifier)
        .toggleListener(
            dayBeginning: value,
            dayEnding: value.dayEnding,
            branchUid: selectedBranch!.uid);
  }

  DateTime _selectedTime = DateTime.now();
  DateTime get selectedTime => _selectedTime;
  set selectedTime(DateTime value) {
    _selectedTime = value;
    notifyListeners();
  }
}
