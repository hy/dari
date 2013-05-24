import json
import random
import sys
import csv
 
class DataSet(list):
    #list must be sorted
    def pct(self,key):
        res = self[int(key * len(self)/100)]
        return round(res,3)

def createRandomData():
    options = []

    if len(sys.argv) < 3:
        series_names.extend(["Laptops", "Desktops", "Servers"])
        #series_names.extend(["Series 1"])
    else:
        series_names.extend(sys.argv[1:len(sys.argv)])


    array_data = [DataSet() for k in series_names]

    count = 1000
    random_stats = [(10, 5), (8, 7), (10, 7)]
    for i in range(count):
            for j in range(len(series_names)):
                mu,sigma = random_stats[j]
                array_data[j].append(random.normalvariate(mu,sigma))
    return array_data


           

maximums = []
minimums = []
array_info = []
series_names = []
arr_out = []

def readData():

    array_data = []
    sample_name = []
    if len(sys.argv) < 2:
        sample_name.extend(["Laptops", "Desktops", "Servers"])
    else:
        sample_name.extend(sys.argv[1:len(sys.argv)])

    with open('public/data.csv', newline='') as f:
        reader = csv.reader(f)
        for row in reader:
            array_data.append(DataSet([float(x) for x in row]))
            series_names.append("unnamed series")

    return array_data


           
for idx,arr in enumerate(readData()):
    arr.sort()
    maximums.append(arr[len(arr)-1])
    minimums.append(arr[0])
    arr_out.append(arr)
    array_info.append({"name": series_names[idx],"p5": arr.pct(5), "p95": arr.pct(95), "mean": round(sum(arr)/len(arr),3), "median": arr.pct(50)})

result = {'arrays': arr_out, 'series_names': series_names, 'max': max(maximums), 'min': min(minimums), 'array_info': array_info}
out = json.dumps(result)


print(out, end='')
