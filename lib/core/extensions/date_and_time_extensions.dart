extension DateTimeExtension1 on DateTime {
  DateTime get dayBeginning => DateTime(year, month, day, 0, 0, 0);

  DateTime get dayEnding => DateTime(year, month, day + 1);

  String get formattedDate {
    String day = this.day.toString();
    String month = this.month.toString();
    String year = this.year.toString();

    if (this.day < 10) {
      day = "0$day";
    }

    if (this.month < 10) {
      month = "0$month";
    }

    return "$day/$month/$year";
  }

  String get formattedTime {
    String hour = this.hour.toString();
    String minute = this.minute.toString();

    if (this.hour < 10) {
      hour = "0$hour";
    }

    if (this.minute < 10) {
      minute = "0$minute";
    }

    return "$hour:$minute";
  }

  String get formattedDateTime {
    String day = this.day.toString();
    String month = this.month.toString();
    String year = this.year.toString();
    String hour = this.hour.toString();
    String minute = this.minute.toString();

    if (this.day < 10) {
      day = "0$day";
    }

    if (this.month < 10) {
      month = "0$month";
    }

    if (this.hour < 10) {
      hour = "0$hour";
    }

    if (this.minute < 10) {
      minute = "0$minute";
    }

    return "$day/$month/$year $hour:$minute";
  }
}
