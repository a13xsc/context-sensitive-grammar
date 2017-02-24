#!/bin/bash

args=('--is-void' '--has-e' '--useless-nonterminals')

echo "Yes" > yes.out
echo "No" > no.out
touch empty.out
echo "Argument error" > argument.err
echo "Syntax error" > syntax.err
echo "Semantic error" > semantic.err
touch empty.err

echo "5 g01.in --who-am-I empty.out argument.err"
echo "5 g01.in wat? empty.out argument.err"

for i in `seq 1 50`; do
    echo "1 syn`printf '%02d' $i`.in ${args[$(($i % 3))]} empty.out syntax.err"
done
for i in `seq 1 10`; do
    echo "4 sem`printf '%02d' $i`.in ${args[$(($i % 3))]} empty.out semantic.err"
done
