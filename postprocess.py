modules = [
    "Dict",
    "List",
    "Tuple",
]

with open("index2.html", "w") as f:
    for line in open("index.html"):

        for m in modules:
            line = line.replace("var $elm$core$" + m + "$", "elmCore." + m + ".")
            line = line.replace("$elm$core$" + m + "$", "elmCore." + m + ".")

        if 'REPLACE_CODE' in line:
            f.write(open("src/eval.js").read())
        else:
            f.write(line)

        if 'use strict' in line:
            f.write('var elmCore = {};\n')
            for m in modules:
                f.write("elmCore." + m + "= {};\n")

print("postprocessing completed!")
