import 'dart:io';

main(List<String> args) {
  int inputs = int.parse(stdin.readLineSync());
  for (var i = 0; i < inputs; i++) {
    print(getNewCalendarDate(
        parseFromCzechStringToDateTime(stdin.readLineSync())));
  }
}

String getNewCalendarDate(DateTime inputDate) {
  var settings = Settings.preset();

  // Days since our Glorious Leader
  var daysSinceDayZero = getDaysSinceDayZero(inputDate, settings);

  // Day in week in calender of our Glorious Leader
  var dayInWeek = getDayInWeek(settings, daysSinceDayZero);

  // Years after our Glorious Leader was born
  var years = getYearsSinceDayZero(settings, daysSinceDayZero);

  // How many days were in current year
  var daysInCurrentYear =
      getDaysInCurrentYear(settings, daysSinceDayZero, years /*, inputDate*/);

  var monthCalculationResult =
      getCurrentMonth(settings, daysInCurrentYear, years);

  return "${dayInWeek + 1} ${monthCalculationResult.daysInMonth} ${monthCalculationResult.month + 1} ${years}";
}

/// "27 2 2012" -> 2012-02-27 (DateTime)
DateTime parseFromCzechStringToDateTime(String input) {
  var parsedDateString = input.split(' ').reversed.toList();
  if (parsedDateString[1].length == 1)
    parsedDateString[1] = '0' + parsedDateString[1];
  if (parsedDateString[2].length == 1)
    parsedDateString[2] = '0' + parsedDateString[2];
  var finallyParsedDateString = parsedDateString.join('-');
  return DateTime.parse(finallyParsedDateString);
}

/// Get number of days since our Glorious Leader was born
int getDaysSinceDayZero(DateTime date, Settings settings) {
  var deltaDate = date.difference(settings.dayZero);
  return deltaDate.inDays;
}

int getDayInWeek(Settings settings, int daysSinceDayZero) {
  return daysSinceDayZero % settings.daysInWeek;
}

int getDaysInCurrentYear(Settings settings, int daysSinceDayZero, int year) {
  // Days in previous years:
  // days in previous years (doesn't matter if they are leap) +
  // leap days in previous years
  int previousDays = (year - 1) * settings.daysInYear +
      (((year - 1) ~/ settings.leapYears) * settings.leapDaysPerYear -
              ((year - 1) ~/ (settings.leapYears * settings.notLeapYears))) *
          settings.leapDaysPerYear;
  return daysSinceDayZero - previousDays;
}

int getYearsSinceDayZero(Settings settings, int daysSinceDayZero) {
  // Days per leap cycle, by default 3 years
  int daysPerLeapCycle =
      settings.daysInYear * settings.leapYears + settings.leapDaysPerYear;
  // With default settings: 300 years (300th year is the first leap years exception)
  int daysPerCompleteLeapCycle =
      daysPerLeapCycle * settings.notLeapYears - settings.leapDaysPerYear;

  // It's easier to start from day 1 than day 0
  int days = daysSinceDayZero + 1;

  // How many complete leap cycles are there
  int completeLeapCycles = days ~/ daysPerCompleteLeapCycle;
  days -= completeLeapCycles * daysPerCompleteLeapCycle;
  // How many leap cycles are there
  int leapCycles = days ~/ daysPerLeapCycle;
  // We need to offset because last leap-cycle period has an extra day
  if (leapCycles == settings.notLeapYears) leapCycles--;
  days -= leapCycles * daysPerLeapCycle;
  // How many normal years are there
  int years = days ~/ settings.daysInYear;
  // We need to offset because leap year has an extra day
  if (years == settings.leapYears) years--;
  days -= years * settings.daysInYear;

  // Because 0th day doesn't exist - this is actually previous year!
  if (days == 0) years--;

  // Return sum of years
  int result =
      completeLeapCycles * (settings.leapYears * settings.notLeapYears) +
          leapCycles * settings.leapYears +
          years +
          1; // +1 because day zero (20.8.1984) is year 1

  // Previous lines ignore negative numbers. We should fix its
  if (daysSinceDayZero < 0 && result != 0) {
    result *= -1;
    result += 1;
  }

  return result;
}

MonthCalculationResult getCurrentMonth(
    Settings settings, int daysInCurrentYear, int year) {
  // Use either normal months or leap months
  var months = settings.months;
  if (year % settings.leapYears == 0 && year % settings.notLeapYears != 0) {
    months = settings.leapMonths;
    daysInCurrentYear =
        daysInCurrentYear % (settings.leapDaysPerYear + settings.daysInYear);
  } else {
    daysInCurrentYear = daysInCurrentYear % settings.daysInYear;
  }
  // We go through remaining days in this year until we run out of days
  int daysRemaining = daysInCurrentYear;
  int selectedMonth = -1;
  for (var i = 0; i < months.length; i++) {
    if (daysRemaining < months[i]) {
      selectedMonth = i;
      break;
    }
    daysRemaining -= months[i];
  }

  return MonthCalculationResult(selectedMonth, daysRemaining + 1);
}

/// I need this because one of the methods returns two values I'm interested in
class MonthCalculationResult {
  int month, daysInMonth;
  MonthCalculationResult(this.month, this.daysInMonth);
}

class Settings {
  /// Default: 9
  int daysInWeek;

  /// Default: 20.8.1984
  DateTime dayZero;

  /// Default: 350
  int daysInYear;

  /// Default: 3
  int leapYears;

  /// Default: 100
  int notLeapYears;

  /// Default: [25, 21, 21, 24, 24, 25, 25, 21, 25, 24, 21, 24, 21, 24, 25]
  List<int> months;

  /// Default: [25, 21, 22, 24, 24, 25, 25, 21, 25, 24, 21, 24, 21, 24, 25]
  List<int> leapMonths;

  /// Default: 1
  int leapDaysPerYear;

  Settings.preset() {
    this.daysInWeek = 9;
    this.daysInYear = 350;
    this.leapYears = 3;
    this.notLeapYears = 100;
    this.dayZero = DateTime(1984, 8, 20);
    this.months = [25, 21, 21, 24, 24, 25, 25, 21, 25, 24, 21, 24, 21, 24, 25];
    this.leapMonths = [
      25,
      21,
      22,
      24,
      24,
      25,
      25,
      21,
      25,
      24,
      21,
      24,
      21,
      24,
      25
    ];
    leapDaysPerYear = 0;
    for (var i = 0; i < months.length; i++) {
      leapDaysPerYear += leapMonths[i] - months[i];
    }
  }

  Settings(this.daysInWeek, this.daysInYear, this.leapYears, this.notLeapYears,
      this.dayZero, this.months, this.leapMonths) {
    leapDaysPerYear = 0;
    for (var i = 0; i < months.length; i++) {
      leapDaysPerYear += leapMonths[i] - months[i];
    }
  }
}

num max(num a, num b) => a >= b ? a : b;
