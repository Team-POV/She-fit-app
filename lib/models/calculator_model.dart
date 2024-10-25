import 'dart:math';

class PregnancyCalculations {
  static Map<String, dynamic> calculateOvulation(
      DateTime lastPeriod, int cycleLength) {
    int ovulationDay = cycleLength - 14;
    DateTime ovulationDate = lastPeriod.add(Duration(days: ovulationDay));
    DateTime fertileStart = ovulationDate.subtract(Duration(days: 5));
    DateTime fertileEnd = ovulationDate.add(Duration(days: 1));

    return {
      'ovulationDate': ovulationDate,
      'fertileStart': fertileStart,
      'fertileEnd': fertileEnd,
    };
  }

  static Map<String, dynamic> calculateHCG(
      double initial, double finalValue, int hours) {
    double doublingTime = hours * (log(2) / log(finalValue / initial));
    bool isNormal = doublingTime >= 48 && doublingTime <= 72;

    return {
      'doublingTime': doublingTime,
      'isNormal': isNormal,
    };
  }

  static Map<String, DateTime> calculatePregnancyTest(
      DateTime lastPeriod, int cycleLength) {
    DateTime ovulation = lastPeriod.add(Duration(days: cycleLength - 14));
    DateTime earliestTest = ovulation.add(Duration(days: 10));
    DateTime mostAccurate = ovulation.add(Duration(days: 14));

    return {
      'earliestTest': earliestTest,
      'mostAccurate': mostAccurate,
    };
  }

  static List<DateTime> calculateNextPeriods(
      DateTime lastPeriod, int cycleLength, int months) {
    List<DateTime> periods = [];
    DateTime nextDate = lastPeriod;

    for (int i = 0; i < months; i++) {
      nextDate = nextDate.add(Duration(days: cycleLength));
      periods.add(nextDate);
    }

    return periods;
  }

  static Map<String, DateTime> calculateImplantation(DateTime ovulationDate) {
    return {
      'earliest': ovulationDate.add(Duration(days: 6)),
      'latest': ovulationDate.add(Duration(days: 12)),
    };
  }

  static DateTime calculateDueDate(DateTime lastPeriod) {
    return lastPeriod.add(Duration(days: 280));
  }

  static DateTime calculateIVFDueDate(DateTime retrievalDate, int transferDay) {
    return retrievalDate.add(Duration(days: transferDay == 5 ? 261 : 263));
  }

  static DateTime calculateUltrasoundDueDate(
      DateTime ultrasoundDate, double gestationalAge) {
    int daysToAdd = (280 - (gestationalAge * 7)).round();
    return ultrasoundDate.add(Duration(days: daysToAdd));
  }
}
