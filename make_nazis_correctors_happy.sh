#!/bin/bash

Makefile_Path=$1														# get_makefile_path
SRC_Wildcard=$2															# get_srcs_path

SRC="SRC ="																# init_src
VPATH="VPATH = "														# init_vpath
RULES="\$(DIR_SRC)"														# init_rules

for file in $(echo $SRC_Wildcard | sed "s/+/\*/g"); do					# get_all_srcs_without_the_dir
	SRC+=" "
	CURR_SRC=$(basename $file)
	if [ $(((${#SRC}) + (${#CURR_SRC}))) -gt "79" ]; then
		SRC+='\\\n'
	fi
	SRC+=$CURR_SRC
done

SRC_Wildcard=${SRC_Wildcard%????}										# remove_end_'*/%c'

for file in $(echo $SRC_Wildcard | sed "s/+/\*/g"); do					# replace_'+'_by_'*'
	if [ "$VPATH" != "VPATH = " ]; then									# get_all_vpath_and_sep_by_':'
		VPATH+="\\:"
	fi
	VPATH+="$file"
done

for i in `seq 1 $(echo $SRC_Wildcard | grep -o "+" | wc -l)`; do		# number_of_'+'
	RULES+="\/\*"														# get_rules_to_replace
done

RULES+="\/%.c"															# get_rules_to_replace

test='\\\/'
VPATH=$(echo $VPATH | sed "s/\//$test/g")								# parse_slash_in_VPATH_for_sed
sed -i -e "s/SRC\ =\ \$(wildcard\ \$(DIR_SRC)\/\*\/\*.c)/$SRC/g" $Makefile_Path	# replace_wildcard_src_by_srcs
sed -i -e "s/VPATH\ =/$VPATH/g" $Makefile_Path							# replace_VPATH_by_all_srcs_subdirs
sed -i -e "s/$RULES/%.c/g" $Makefile_Path								# replace_wildcard/%.c_by_%.c