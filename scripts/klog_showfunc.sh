#!/bin/bash
### Functions
find_GOFILE_path() {
	echo "Found the file for $GOFILE"
	GOFILE_PATH=''
	for i in $(find $CODEBASE -name $GOFILE);do # Scan all files with the given filename
		TESTLINE=$(sed "${LINENUM}q;d" $i)
		# check if klog call
		echo $TESTLINE | grep 'klog' > /dev/null
		[ $? -ne 0 ] && continue
		# extract klog content
		LOGGED=$(echo $TESTLINE | grep -o '(\".*:' | cut -c 3-)
		# check if the klog content equals to the line currently being checked
		echo $line | grep "$LOGGED" > /dev/null
		[ $? -eq 0 ] && GOFILE_PATH=$i && break
	done
}

############ Start the execution ############
# Process Args -- 
# -l: Absolute path of logfile
# -b: Absolute path of codebase
while getopts l:b: flag;
do
    case "${flag}" in
        l) LOGFILE=${OPTARG};;
        b) CODEBASE=${OPTARG};;
    esac
done

# Main
while IFS= read -r line; do
# for each logline, extract *.go:Lx and figure out its function
	GOFILE=$(echo $line | grep -o -E '(\w|_)+\.go')
	[ $? -ne 0 ] && echo '' >> $LOGFILE.anot && continue
	LINENUM=$(echo $line | grep -o -E '\.go:[0-9]+' | cut --complement -c 1-4)
	find_GOFILE_path
	[ -z $GOFILE_PATH ] && echo "Path for $GOFILE not found" && echo '' >> $LOGFILE.anot && continue
	GO_PKG=$(head -n 50 $GOFILE_PATH | grep 'package' | cut -c 9-)
	echo "package $GO_PKG: $GOFILE_PATH:L$LINENUM $(head -n $LINENUM $GOFILE_PATH | grep -E '^func ' | tail -n 1)" >> $LOGFILE.anot
done < $LOGFILE
