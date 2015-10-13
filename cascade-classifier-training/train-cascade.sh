#!/bin/bash

if [ "$1" == "" -o "$2" == "" -o "$3" == "" -o "$4" == "" ]; then
   printf "This utility will train cascade and create one xml for each step in results dir\n"
   printf "   Usage: $0 [vecfile containing positive images] [negative images dir] [width of positive images in vecfile] [height of positive images in vecfile]\n"
   printf "   Example: $0 vecfile.vec samples-negative 133 32\n"
   exit 1
fi

echo "Will start training..."

set -x

#hack for gathering the number of images in vector
test=$( { opencv_createsamples -vec $1 -w 9999 -h 9998; } 2>&1 )
#echo $test
nrpos=$(echo $test | awk '{print $22}' | sed 's/[^0-9]*//g')

echo "Vector file number of images: $nrpos"

mkdir results

ls $2 > $2/negative.txt

#execute from inside negatives dir due to a bug
cd $2

for i in `seq 1 20`;
do
   echo "PERFORMING TRAINING (STAGE $i)..."
   opencv_traincascade -data ../results -vec ../$1 -bg negative.txt -minHitRate 0.99 -numThreads 4 -numPos $(($nrpos * 70 / 100)) -numNeg $(($nrpos * 60 / 100)) -featureType LBP -numStages $i -w $3 -h $4
   cp results/cascade.xml results/cascade-step${i}.xml
   echo "CREATED CASCADE XML FILE FOR STAGE $i"
done

