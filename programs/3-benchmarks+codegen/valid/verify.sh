#!/bin/bash

IFS=

START_TIME=`date +%s.%N`
USER_OUTPUT=$(timeout 2m ./execute.sh $1 2>&1)
EXIT_CODE=${PIPESTATUS[0]}
END_TIME=`date +%s.%N`

EXEC_TIME=$(echo "$END_TIME - $START_TIME" | bc -l)
EXPECTED_TIME=$(grep -a "//&" $1 | sed 's/\/\/&//' | sed 's/^/ /')

if [[ $EXIT_CODE == 124 ]]
then
	echo ">>> Execution Time"
	echo " Exceeds ${EXEC_TIME} seconds"
	echo ">>> Expected Execution Time"
	echo $EXPECTED_TIME
	echo -e ">>> \033[0;31m[timeout]\033[0m"
	exit 1
fi

USER_OUTPUT=$(echo "$USER_OUTPUT" | sed -r 's/([+\-][0-9]+\.[0-9]+e[+\-])([0-9])([^0-9]|$)/\100\2\3/g' | sed -r 's/([+\-][0-9]+\.[0-9]+e[+\-])([0-9][0-9])([^0-9]|$)/\10\2\3/g' | sed 's/\\/\\\\/')
EXPECTED_OUTPUT=$(grep -a "//~" $1 | sed 's/\/\/~//' | sed 's/\\/\\\\/')

SHOULD_ERROR=$(grep "//!" $1 | wc -l)
SEGFAULT=$(echo "$USER_OUTPUT" | grep -i "segmentation" | wc -l) 

if [[ "$USER_OUTPUT" == "$EXPECTED_OUTPUT" || ( $SHOULD_ERROR == "1" && $EXIT_CODE != 0 && $SEGFAULT == 0 ) ]]
then
	echo ">>> Execution Time"
	echo "${EXEC_TIME} seconds"
	echo ">>> Expected Execution Time"
	echo $EXPECTED_TIME
	echo -e ">>> \033[0;32m[executed]\033[0m"
	exit 0
else
	echo ">>> User Output"
	if [ ! -z "$USER_OUTPUT" ]
	then
		echo $USER_OUTPUT
	fi
	echo ">>> Expected Output"
	echo $EXPECTED_OUTPUT
	echo -e ">>> \033[0;31m[fail]\033[0m"
	exit 1
fi
