#!/bin/bash

DIR=`dirname $0`

REQ_LIST=$DIR/reqs
TEST_LIST=$DIR/tests
FIXED_SCRIPT=$DIR/fixed.sh
VAR_SCRIPT=$DIR/var.py
LOG_FILE=$DIR/gen.log
index=0

rm $TEST_LIST $LOG_FILE &> /dev/null
$FIXED_SCRIPT > $TEST_LIST

while read test_case
do
	# Parse the components of the line
    count=$(echo $test_case | cut -d' ' -f 1)
	useful=$(($(echo $test_case | cut -d' ' -f 2) * (1 + $RANDOM % 20)))
	useless=$(($(echo $test_case | cut -d' ' -f 3) * (1 + $RANDOM % 20)))
	terminals=$(($(echo $test_case | cut -d' ' -f 4) * (1 + $RANDOM % 20)))
    rules=$(($useful + $(echo $test_case | cut -d' ' -f 5) * (1 + $RANDOM % 20)))
    ltype=$(echo $test_case | cut -d' ' -f 6)

    echo $count $useful $useless $terminals $rules $ltype >> $LOG_FILE
    for i in `seq $count`; do
        index=$(($index + 1))
        echo "python $VAR_SCRIPT $useful $useless $terminals $rules $(($i != 1)) $ltype \"$DIR\" g`printf '%02d' $index`" >> $LOG_FILE
        python "$VAR_SCRIPT" $useful $useless $terminals $rules $(($i != 1)) $ltype "$DIR/" "g`printf '%02d' $index`" >> $TEST_LIST
    done

done < $REQ_LIST
