# Random file generator -- based on Random Word Generator 
# from https://linuxconfig.org/random-word-generator. 
# Generate a number of files set via 1st script arg, with random sizes ranging from 0 to 3.2GB.
# The file content is filled from /dev/urandom.

sudo apt-get install -y wamerican
X=0
ALL_NON_RANDOM_WORDS=/usr/share/dict/words
PREFIX=~/blobfuse 
# total number of non-random words available 
non_random_words=`cat $ALL_NON_RANDOM_WORDS | wc -l`  
# while loop to generate random words  
# number of random generated words depends on supplied argument 
while [ "$X" -lt "$1" ] 
do 
random_number=`od -N3 -An -i /dev/urandom | awk -v f=0 -v r="$non_random_words" '{printf "%i\n", f + r * $1 / 16777216}'` 
FILENAME=$(sed `echo $random_number`"q;d" $ALL_NON_RANDOM_WORDS)
dd if=/dev/urandom of=$PREFIX/$FILENAME count=$(($random_number * 100000 / $non_random_words)) bs=32k
let "X = X + 1" 
done