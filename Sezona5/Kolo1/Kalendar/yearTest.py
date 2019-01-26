
BFyear = 1
months = [25, 21, 21, 24, 24, 25, 25, 21, 25, 24, 21, 24, 21, 24, 25]
leapMonths = [ 25, 21, 22, 24, 24, 25, 25, 21, 25, 24, 21, 24, 21, 24, 25 ]
dayInMonth = 0
month = 0

for day in range(1, 100):
    # Bruteforce
    dayInMonth += 1
    if BFyear % 3 == 0 and BFyear % 100 != 0:
        selectedMonths = leapMonths
    else:
        selectedMonths = months
    if dayInMonth > selectedMonths[month]:
        dayInMonth = 1
        month += 1
    
    if month >= len(selectedMonths):
        month = 0
        BFyear += 1

    DaysPerYear = 350
    DaysPer3Years = 350 * 3 + 1
    DaysPer300Years = DaysPer3Years * 100 - 1

    days = day
    y300 = days // DaysPer300Years
    days -= y300 * DaysPer300Years
    y3 = days // DaysPer3Years
    if y3  == 100:
        y3 = 99
    days -= y3 * DaysPer3Years
    y1 = days // DaysPerYear
    if y1 == 3:
        y1 = 2
    days -= y1 * DaysPerYear   
    if days == 0:
        y1 -= 1
    
    year = y300 * 300 + y3 * 3 + y1 + 1

    print(year)
    if year != BFyear:
        print(str(year) + ' != ' + str(BFyear) + ' (' + str(day) + ')')
        print(days)
