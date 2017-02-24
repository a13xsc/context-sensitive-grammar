#!/bin/bash

DIR=`dirname $0`

rm $DIR/tests $DIR/gen.log $DIR/g*.in $DIR/*.out $DIR/*.out.sorted $DIR/*.err &> /dev/null
