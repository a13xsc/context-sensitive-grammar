#!/bin/bash
# credits to AI CG :D
TEST_DIR=test
TEST_LIST=$TEST_DIR/tests
INPUT_FILE="grammar"

# Compile student homework
make build

# Sort files for the first time
$TEST_DIR/sort.sh

# Run tests
score=0
total_score=0

while read test_case
do
	# Parse the components of the line
	weight="$(echo $test_case | cut -d' ' -f 1)"
	input="$(echo $test_case | cut -d' ' -f 2)"
	arg="$(echo $test_case | cut -d' ' -f 3)"
	toutput="$(echo $test_case | cut -d' ' -f 4)"
    output="$input.$toutput"
    terror="$(echo $test_case | cut -d' ' -f 5)"
    error="$input.$terror"
    echo $input $arg $toutput

    #create a link to the current test file
    rm $INPUT_FILE $output $error &> /dev/null
    ln -s -T "$TEST_DIR/$input" $INPUT_FILE

	# Run the student homework
	make run arg=$arg > $output 2> $error
    cat $output | sed 1d | sort > "$output.sorted"

	# Update scores
	total_score=$[$total_score + $weight]
    diff -bBq "$output.sorted" "$TEST_DIR/$toutput.sorted" &> /dev/null &&
        diff -bBq "$error" "$TEST_DIR/$terror" &> /dev/null
    if [ $? -eq 0 ]
    then echo -e "\e[32mPASSED\e[0m Test ($input,$arg). You won: $weight"; score=$[$score + $weight]; rm $output "$output.sorted" $error
		else
            echo -e "\e[31mFAILED\e[0m Test ($input,$arg). You failed to win: $weight"
            echo " failed standard output -> $output"
            echo " sorted failed standard output -> $output.sorted"
            echo " official standard output -> $TEST_DIR/$toutput.sorted"
            echo " failed error output -> $error"
            echo " official error output -> $TEST_DIR/$terror"
	fi
done < $TEST_LIST

rm $INPUT_FILE &> /dev/null
make clean

grade=$[$score * 100 / $total_score]
echo "Score: " $grade " out of 100"
