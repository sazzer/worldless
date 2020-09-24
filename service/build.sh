#!/bin/bash

rm -rf output/lambdas
mkdir -p output/lambdas

for module in `ls -1 lambdas`; do
    echo $module
    mkdir -p output/$module
    for lambda in `ls -1 lambdas/$module/cmd`; do
        echo === Compiling $lambda for $module ===
        GOOS=linux GOARCH=amd64 go build -o ./output/lambdas/$module/$lambda lambdas/$module/cmd/$lambda/*
    done
done

cd output/lambdas
for module in `ls -1`; do
    cd $module
    for lambda in `ls -1`; do
        echo === Packaging $lambda for $module ===
        zip $lambda.zip $lambda
    done
    cd ..
done