paths = """
dev.azure.com/jeragm/
dev.azure.com/edfenergyna
dev.azure.com/EdfAnalytics
github.com/kubernetes-sigs/
github.com/Nordix/
github.com/OfficeDev/
github.com/pre-commit/
github.com/primefaces/
github.com/redis/
"""

paths = paths.strip().splitlines()

query = []

for p in paths:
    
    p = "and (CommandLine != \"*" + p + "*\")\n"
    query.append(p)

for i in query:
    print(i.strip())

# and (CommandLine != "*tfs.edftrading.com*")