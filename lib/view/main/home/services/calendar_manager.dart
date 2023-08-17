part of '../home_notifier.dart';

mixin _CalendarManager {
  final CalendarSessionSource _sessionSource = CalendarSessionSource();
  CalendarSessionSource get sessionSource => _sessionSource;

  Future<void> reFillSessions(List<SessionModel> sessions) async {
    await _sessionSource.reFill(sessions);
  }
}
