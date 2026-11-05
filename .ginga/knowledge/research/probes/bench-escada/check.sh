#!/bin/bash
# uso: check.sh <dir> <A|B|C>  -> imprime: ok=<0|1> tests=<passou>/<total> md5=<intacto|ALTERADO> struct=<ok|FALHA|->
d=$1; t=$2; cd "$d" || exit 1
total=$(cat expected_total)
python3 -m unittest -v > ver.txt 2>&1
npass=$(grep -c ' \.\.\. ok$' ver.txt); ranok=$(tail -3 ver.txt | grep -c '^OK')
md5sum -c protected.md5 >/dev/null 2>&1 && md5=intacto || md5=ALTERADO
st=-
if [ "$t" = C ]; then
  st=$(python3 -I - <<'Q'
import ast
try:
    src=open("orders.py").read(); tree=ast.parse(src)
    fs=[n for n in ast.walk(tree) if isinstance(n,(ast.FunctionDef,ast.AsyncFunctionDef))]
    names={f.name for f in fs}
    big=[f.name for f in fs if f.end_lineno-f.lineno+1>25]
    ok="process_orders" in names and len(fs)>=4 and not big
    print("ok" if ok else "FALHA")
except Exception: print("FALHA")
Q
)
fi
ok=0; [ $ranok = 1 ] && [ $md5 = intacto ] && { [ $st = - ] || [ $st = ok ]; } && ok=1
echo "ok=$ok tests=$npass/$total md5=$md5 struct=$st"
