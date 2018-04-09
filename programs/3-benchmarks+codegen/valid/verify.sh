#!/bin/bash

IFS=

START_TIME=`date +%s.%N`
USER_OUTPUT=$(./execute.sh $1 2>&1)
END_TIME=`date +%s.%N`

EXIT_CODE=${PIPESTATUS[0]}
USER_OUTPUT=$(echo "$USER_OUTPUT" | sed -r 's/([+\-][0-9]+\.[0-9]+e[+\-])([0-9][0-9])([^0-9]|$)/\10\2/g' | sed 's/\r//g' | sed 's/\\/\\\\/')
EXPECTED_OUTPUT=$(grep "//~" $1 | sed 's/\/\/~//' | sed 's/\r//g' | sed 's/\\/\\\\/')
EXPECTED_TIME=$(grep "//&" $1 | sed 's/\/\/&//')

SHOULD_ERROR=$(grep "//!" $1 | wc -l)
SEGFAULT=$(echo "$USER_OUTPUT" | grep -i "segmentation" | wc -l) 

if [[ "$USER_OUTPUT" == "$EXPECTED_OUTPUT" || ( $SHOULD_ERROR == "1" && $EXIT_CODE != 0 && $SEGFAULT == 0 ) ]]
then
	EXEC_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)

	echo ">>> Execution Time"
	echo "${EXEC_TIME} seconds"
	echo ">>> Expected Execution Time"
	echo $EXPECTED_TIME
	echo -e ">>> \033[0;32m[Executed]\033[0m"
	exit 0
else
	echo ">>> User Output"
	if [ ! -z "$USER_OUTPUT" ]
	then
		echo $USER_OUTPUT
	fi
	echo ">>> Expected Output"
	echo $EXPECTED_OUTPUT
	echo -e ">>> \033[0;31m[Fail]\033[0m"
	exit 1
fi
