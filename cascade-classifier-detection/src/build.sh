#!/bin/bash

rm build -R
mkdir build

cd build
cmake ..

make

