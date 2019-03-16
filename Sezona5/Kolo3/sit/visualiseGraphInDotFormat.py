# Visualise input in .dot format

n = int(input())

for i in range(0, n):
    # Skip empty line
    input()
    # Load numbers
    numberOfCities: int = int(input().split(' ')[0])
    stringForbiddenCities: list = input().strip().split(' ')
    forbiddenCities = [ ]
    cityPaths = [ ]
    for s in stringForbiddenCities:
        forbiddenCities.append(int(s))
    for j in range(0, numberOfCities):
        stringPaths: list = input().split(' ')
        numberOfPaths = int(stringPaths[0])
        paths = [ ]
        for k in range(0, numberOfPaths):
            num = int(stringPaths[k + 1])
            paths.append(num)
        cityPaths.append(paths)


    # Draw the graph
    print('digraph sit {')
    for j in range(0, numberOfCities):
        if j in forbiddenCities:
            print('_{0} [color=red label="{0}"];'.format(j))
        else:
            print('_{0} [label="{0}"];'.format(j))
        
    print()

    for j in range(0, len(cityPaths)):
        for k in range(0, len(cityPaths[j])):
            print('_{0} -> _{1} [label="{2}"];'.format(j, cityPaths[j][k], k+1))

    print('}')

