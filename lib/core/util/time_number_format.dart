class TimeNumberFormat {
  static String formatTwoDigits(int number) {
    return number.toString().length == 1 ? '0$number' : '$number';
  }

  static String getMonthName(int month) {
    const monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    if (month < 1 || month > 12) {
      throw ArgumentError('El mes dado debe ser desde el 1 al 12');
    }
    return monthNames[month - 1];
  }

  static String parseDate(DateTime date, bool withTime, bool format24) {
    String dateParsed = "${TimeNumberFormat.formatTwoDigits(date.day)}/${TimeNumberFormat.getMonthName(date.month)}/${date.year}";
    if (withTime == true) {
      if (format24 == true) {
        if (date.hour == 0) {
          dateParsed += " 12:${TimeNumberFormat.formatTwoDigits(date.minute)} AM";
        } else if (date.hour < 12) {
          dateParsed += " ${TimeNumberFormat.formatTwoDigits(date.hour)}:${TimeNumberFormat.formatTwoDigits(date.minute)} AM";
        } else if (date.hour == 12) {
          dateParsed += " 12:${TimeNumberFormat.formatTwoDigits(date.minute)} PM";
        } else {
          dateParsed += " ${TimeNumberFormat.formatTwoDigits(date.hour - 12)}:${TimeNumberFormat.formatTwoDigits(date.minute)} PM";
        }
      } else {
        dateParsed += " ${TimeNumberFormat.formatTwoDigits(date.hour)}:${TimeNumberFormat.formatTwoDigits(date.minute)}";
      }
    }
    return dateParsed;
  }
}