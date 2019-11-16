baseDir = "/Users/Steve/PROJECTS/core/src/"

blacklist = ['Int', 'Float', 'Never', 'Dict', 'Set', 'String', 'divideAndConquer']

def processModule(module):
    fn = baseDir + module + ".elm"

    s = ''
    with open(fn) as f:
        for line in f:
            if 'module' in line:
                continue
            if ' )' in line:
                break

            s += line.strip()

    s = s.replace("( ", "")
    funcs = s.split(", ")
    funcs = [ f for f in funcs if '(' not in f ]
    funcs = [ f for f in funcs if 'exposing' not in f]
    funcs = [ f for f in funcs if f not in blacklist]
    for f in funcs:
        print("        " + f + module +  "Hack = " + module + "." + f)

modules = [
    "Array",
    "Basics",
    "Dict",
    "List",
    "Maybe",
    "Result",
    "Set",
    "String",
    "Tuple",
]

print('module Builtin exposing (..)')

for m in modules:
    print("import " + m)


print("""
hacks =
    let
""")

print()

for m in modules:
    processModule(m)

print("""
    in
    ()
""")
