#!/bin/bash
rm fichero1.txt
n=0; while [[ $n -lt 4 ]]; do echo -n "$(shuf -i 10-30 -n 1);" >> fichero1.txt; n=$((n+1)); done
echo "">>fichero1.txt
echo "$(seq -20 10 | shuf -n 1);$(shuf -i 10-20 -n 1);" >> fichero1.txt


p=0; while [[ $p -lt 4 ]]; do 
    e=0; while [[ $e -lt 4 ]];do
        echo -n "$(shuf -i 10-30 -n 1);" >> fichero1.txt;
        e=$((e+1));
    done
    p=$((p+1));
    echo "">>fichero1.txt
done
cat fichero1.txt
