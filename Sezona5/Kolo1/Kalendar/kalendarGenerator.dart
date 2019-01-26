main(List<String> args) {
  printDumpOutput();
}

void printDumpOutput() {
  var months = [25, 21, 21, 24, 24, 25, 25, 21, 25, 24, 21, 24, 21, 24, 25];
  var leapMonths = [25, 21, 22, 24, 24, 25, 25, 21, 25, 24, 21, 24, 21, 24, 25];

  int dayInWeek = 0;
  int dayInMonth = 0;
  int month = 0;
  int year = 1;

  while (true) {
    dayInWeek++;
    if (dayInWeek > 9) dayInWeek = 1;

    dayInMonth++;
    var selectedMonths = year % 3 == 0 && year % 100 != 0 ? leapMonths : months;
    if(dayInMonth > selectedMonths[month]){
      dayInMonth = 1;
      month++;
    }

    if(month >= months.length){
      month = 0;
      year++;
    }

    print("${dayInWeek} ${dayInMonth} ${month+1} ${year}");
  }
}
