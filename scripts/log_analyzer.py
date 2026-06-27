from collections import Counter

log_file="../logs/system_logs.log"


keywords = ["error","failed","critical","warning"]

counter = Counter()

with open(log_file,'r',errors="ignore") as f:
    for line in f:
      #  print(line)
        line=line.lower()

        for word in keywords:
             if word in line:
                counter[word] += 1
print("System log Summary")
print(counter.items()) 

for k,v in counter.items():
    print(k,":",v)
