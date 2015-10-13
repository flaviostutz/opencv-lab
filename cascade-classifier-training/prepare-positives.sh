#!/bin/bash

set -e

if [ "$1" == "" -o "$2" == "" -o "$3" == "" -o "$4" == "" -o "$5" == "" -o "$6" == "" -o "$7" == "" -o "$8" == "" -o "$9" == "" ]; then
  printf "This utility will create a vecfile containing images after performing angle and luminosity variations on a bunch of positive images. \nFor each image in source images dir, it will random rotate, with random backgrounds (from negatives dir) and apply random luminosity, generating N new samples. All resulting images will be written to vecfile.\n"
  printf "   Usage: $0 [source positive images dir] [negative images dir] [destination vecfile] [positive images width] [positive images height] [number of variations per positive image] [max random angle variation on x] [max random angle variation on y] [max random angle variation on z]\n"
  printf "   Example: $0 samples-positive samples-negative vecfile.vec 35 23 4 0.25 0.25 0.12\n"  
exit 1
fi

#prepare dirs
rm tmp-positive -R
mkdir tmp-positive

#generate negative.txt
ls $2 > $2/negative.txt

for f in $1/*
do
   filename=$(basename $f)
   fname=${filename%.*}
   posdir=tmp-positive/$fname
   echo "Processing $fname..."
   opencv_createsamples -img $f -bg $2/negative.txt -info $posdir/positive.txt -num $6 -w $4 -h $5 -bgcolor 255 -bgthresh 0 -maxxangle $7 -maxyangle $8 -maxzangle $9
   awk '{print "'"$fname"'/" $0}' $posdir/positive.txt >> tmp-positive/positive.txt
done

nr_imgs=$(wc -l tmp-positive/positive.txt | awk '{print $1}')
cd tmp-positive

vec=$3
if [[ ! $3 == /* ]]; then
   vec=../$3
fi

opencv_createsamples -info positive.txt -bg $2/negative.txt -vec $vec -num $nr_imgs -w $4 -h $5

