### TODO: month and day in month doesn't work
#					properly (4k example) with the commented code
#
#					month and day in month doesn't work
#					properly (3k and 4k example) with current code

daysInWeek = 9
dayZero = 461808000
daysInYear = 350
leapYears = 3
leapYearsNot = 100
months = [ 25, 21, 21, 24, 24, 25, 25, 21, 25, 24, 21, 24, 21, 24, 25 ]

print('Input UNIX datetime')

unixTime = int(input())

daysSinceDay0 = int((unixTime-dayZero)/86400)

print('Days since our glorious Leader:')
print(daysSinceDay0)

week = daysSinceDay0 % daysInWeek

print('Current week in year:')
print(week + 1)

yearsNoLeap = int((daysSinceDay0)/daysInYear)+1
totalLeapDaysPerYears = int(yearsNoLeap/leapYears)-int(yearsNoLeap/leapYearsNot)
totalYears = int((daysSinceDay0-totalLeapDaysPerYears)/daysInYear)+1

print('Years since our glorious Leader was born:')
print(totalYears)

daysInThisYear = daysSinceDay0 % daysInYear
#leap days from year 0 to now
# TODO: this will break with negative value
for i in range(0, totalYears):
	if i % 3 == 0 and i % 100 != 0:
		daysInThisYear += 1
if (totalYears % 3 == 0 and i % 100 != 0 and
		daysInThisYear > months[0] + months[1]):
		daysInThisYear += 1
# TODO: What will hapen if there are >350 leap days?
daysInThisYear = daysInThisYear % (daysInYear + 1)

# if current year is leap
#if totalYears % leapYears == 0 and totalYears % leapYearsNot != 0:
#	daysInThisYear = daysSinceDay0 % (daysInYear+1)
#else:
#	daysInThisYear = daysSinceDay0 % daysInYear

daysLeftForMonthsCounter = daysInThisYear
print('DEBUG: ' + str(daysLeftForMonthsCounter))
month = 0
dayInMonth = 0
for i in range(0, len(months)):
	month = months[i]
	if (totalYears % 3 == 0 and totalYears % 100 != 0 and
			i == 2):
		month += 1
	if(daysLeftForMonthsCounter <= month):
		month = i
		dayInMonth = daysLeftForMonthsCounter
		break
	daysLeftForMonthsCounter -= month

print('Month in year of our glorious Leader:')
print(month+1)

print('Day of month of our glorious Leader:')
print(dayInMonth+1)
