#!/bin/bash

cd "$( dirname "$0" )"

for i in *.out
do
    if [ $i -nt $i.sorted ]
        then
        echo "Creating $i.sorted from $i"
        sort $i > $i.sorted
    fi
done
