
tests = int(input())
for i in range(0, tests):
    line = input()
    inputs = int(line.split(' ')[0])
    questions = int(line.split(' ')[1])
    numbers = [ int(obj) for obj in input().split(' ') ]
    
    for j in range(0, questions):
        line = input()
        intervalFrom = int(line.split(' ')[0])
        intervalTo = int(line.split(' ')[1])

        minValue = 2147483647
        maxValue = -2147483647
        maxIndex = -1
        xor = 0

        for index in range(intervalFrom, intervalTo + 1):
            numberValue = numbers[index]
            if numberValue < minValue:
                minValue = numberValue
            if numberValue > maxValue:
                maxValue = numberValue
                maxIndex = index
            xor = xor ^ numberValue
        
        print(minValue)
        print(maxIndex)
        print(xor)