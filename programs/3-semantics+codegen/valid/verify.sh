#!/bin/bash

IFS=
USER_OUTPUT=$(./execute.sh $1 2>&1)
EXIT_CODE=${PIPESTATUS[0]}
USER_OUTPUT=$(echo "$USER_OUTPUT" | sed -r 's/([+\-][0-9]+\.[0-9]+e[+\-])([0-9])([^0-9]|$)/\100\2\3/g' | sed -r 's/([+\-][0-9]+\.[0-9]+e[+\-])([0-9][0-9])([^0-9]|$)/\10\2\3/g')
EXPECTED_OUTPUT=$(grep -a "//~" $1 | sed 's/\/\/~//')

SHOULD_ERROR=$(grep "//!" $1 | wc -l)
SEGFAULT=$(echo "$USER_OUTPUT" | grep -i "segmentation" | wc -l) 

if [[ "$USER_OUTPUT" == "$EXPECTED_OUTPUT" || ( $SHOULD_ERROR == "1" && $EXIT_CODE != 0 && $SEGFAULT == 0 ) ]]
then
	echo ">>> User Output"
	if [ ! -z "$USER_OUTPUT" ]
	then
		echo $USER_OUTPUT
	fi
	echo ">>> Expected Output"
	echo $EXPECTED_OUTPUT
	echo -e ">>> \033[0;32m[pass]\033[0m"
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
