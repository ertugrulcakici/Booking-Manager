import 'package:bookingmanager/product/models/session_model.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

final class CalendarSessionSource extends CalendarDataSource {
  final List<SessionModel> sessions = List.empty(growable: true);
  CalendarSessionSource();

  void deleteAppointment(String id) {
    final index = appointments!.indexWhere((element) => element.id == id);
    if (index != -1) {
      appointments!.removeAt(index);
    }
    notifyListeners(CalendarDataSourceAction.remove, appointments!);
  }

  Future<void> reFill(List<SessionModel> source) async {
    sessions.clear();
    sessions.addAll(source);
    appointments = List.empty(growable: true);

    if (sessions.isNotEmpty) {
      for (var session in sessions) {
        appointments!.add(await session.toAppointment());
      }
    }
    notifyListeners(CalendarDataSourceAction.reset, appointments!);
  }
}
