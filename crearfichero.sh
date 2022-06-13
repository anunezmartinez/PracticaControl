#!/bin/bash
n=0; while [[ $n -lt 5 ]]; do echo "$(shuf -i 10-30 -n 1);"; n=$((n+1)); done


echo "Fichero formateado"
echo "$(shuf -i 10-30 -n 1);$(shuf -i 30-50 -n 1);" 
echo "$(seq -20 10 | shuf -n 1);$(shuf -i 10-20 -n 1);"
echo "$(shuf -i 10-30 -n 1);$(shuf -i 30-50 -n 1);$(shuf -i 30-50 -n 1);$(shuf -i 30-50 -n 1);" 
echo "$(shuf -i 10-30 -n 1);$(shuf -i 30-50 -n 1);$(shuf -i 30-50 -n 1);$(shuf -i 30-50 -n 1);" 
echo "$(shuf -i 10-30 -n 1);$(shuf -i 30-50 -n 1);$(shuf -i 30-50 -n 1);$(shuf -i 30-50 -n 1);" 
echo "$(shuf -i 10-30 -n 1);$(shuf -i 30-50 -n 1);$(shuf -i 30-50 -n 1);$(shuf -i 30-50 -n 1);" 
cat fichero1.txt
